from datetime import timedelta

from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from .models import Appointment, Conversation, DoctorProfile, PatientProfile, Speciality, User


class ConversationAccessTests(APITestCase):
    def setUp(self):
        self.speciality = Speciality.objects.create(name="Cardiologie")

        self.patient_user = User.objects.create_user(
            username="patient1",
            email="patient@example.com",
            password="Testpass123!",
            role=User.Roles.PATIENT,
        )
        self.patient = PatientProfile.objects.create(user=self.patient_user)

        self.doctor_user = User.objects.create_user(
            username="doctor1",
            email="doctor@example.com",
            password="Testpass123!",
            role=User.Roles.DOCTOR,
        )
        self.doctor = DoctorProfile.objects.create(
            user=self.doctor_user,
            speciality=self.speciality,
            license_number="LIC-001",
        )

        self.patient_token = Token.objects.create(user=self.patient_user)
        self.doctor_token = Token.objects.create(user=self.doctor_user)

    def _authenticate(self, token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _create_appointment(self, status_value):
        return Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            date=timezone.now() + timedelta(days=1),
            status=status_value,
        )

    def test_patient_cannot_start_conversation_with_refused_appointment(self):
        self._create_appointment("REFUSED")
        self._authenticate(self.patient_token)

        response = self.client.post(
            reverse("conversation-start"),
            {"doctor_id": self.doctor.id},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_patient_can_start_conversation_with_pending_appointment(self):
        self._create_appointment("PENDING")
        self._authenticate(self.patient_token)

        response = self.client.post(
            reverse("conversation-start"),
            {"doctor_id": self.doctor.id},
            format="json",
        )

        self.assertIn(
            response.status_code,
            {status.HTTP_200_OK, status.HTTP_201_CREATED},
        )
        self.assertEqual(response.data["doctor"], self.doctor.id)
        self.assertEqual(response.data["patient"], self.patient.id)

    def test_doctor_contacts_only_include_patients_with_allowed_appointments(self):
        self._create_appointment("REFUSED")
        self._authenticate(self.doctor_token)

        response = self.client.get(reverse("conversation-contacts"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, [])

        Appointment.objects.all().delete()
        self._create_appointment("PENDING")

        response = self.client.get(reverse("conversation-contacts"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["id"], self.patient.id)

    def test_patient_can_send_message_with_attachment(self):
        self._create_appointment("CONFIRMED")
        conversation = Conversation.objects.create(
            patient=self.patient,
            doctor=self.doctor,
        )
        self._authenticate(self.patient_token)

        attachment = SimpleUploadedFile(
            "analyse.pdf",
            b"%PDF-1.4 test",
            content_type="application/pdf",
        )
        response = self.client.post(
            reverse("conversation-send", args=[conversation.id]),
            {"content": "Voici mon document", "file": attachment},
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(len(response.data["attachments"]), 1)
        self.assertEqual(response.data["attachments"][0]["file_name"], "analyse.pdf")

    def test_patient_cannot_send_unsupported_attachment(self):
        self._create_appointment("CONFIRMED")
        conversation = Conversation.objects.create(
            patient=self.patient,
            doctor=self.doctor,
        )
        self._authenticate(self.patient_token)

        attachment = SimpleUploadedFile(
            "script.exe",
            b"fake-binary",
            content_type="application/octet-stream",
        )
        response = self.client.post(
            reverse("conversation-send", args=[conversation.id]),
            {"content": "test", "file": attachment},
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("file", response.data)
