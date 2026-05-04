from datetime import timedelta
from io import StringIO

from django.core.management import call_command
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from .models import (
    Appointment,
    AvailabilitySlot,
    DoctorProfile,
    Notification,
    PatientProfile,
    Speciality,
    User,
)


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


class AppointmentWorkflowTests(APITestCase):
    def setUp(self):
        self.speciality = Speciality.objects.create(name="Dermatologie")
        self.patient_user = User.objects.create_user(
            username="patient2",
            email="patient2@example.com",
            password="Testpass123!",
            role=User.Roles.PATIENT,
            first_name="Sara",
            last_name="Benali",
        )
        self.patient = PatientProfile.objects.create(user=self.patient_user)

        self.doctor_user = User.objects.create_user(
            username="doctor2",
            email="doctor2@example.com",
            password="Testpass123!",
            role=User.Roles.DOCTOR,
            first_name="Karim",
            last_name="Alaoui",
        )
        self.doctor = DoctorProfile.objects.create(
            user=self.doctor_user,
            speciality=self.speciality,
            license_number="LIC-002",
        )

        self.patient_token = Token.objects.create(user=self.patient_user)
        self.doctor_token = Token.objects.create(user=self.doctor_user)

    def _authenticate(self, token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _create_appointment(self, status_value="PENDING", date_value=None):
        return Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            date=date_value or timezone.now() + timedelta(days=1),
            status=status_value,
        )

    def test_create_appointment_notifies_doctor(self):
        appointment_date = timezone.now() + timedelta(days=2)
        AvailabilitySlot.objects.create(
            doctor=self.doctor,
            day_of_week=appointment_date.weekday(),
            start_time=appointment_date.time().replace(second=0, microsecond=0),
            end_time=(appointment_date + timedelta(minutes=30)).time().replace(second=0, microsecond=0),
        )
        self._authenticate(self.patient_token)

        response = self.client.post(
            reverse("appointment-list"),
            {
                "doctor": self.doctor.id,
                "date": appointment_date.isoformat(),
                "reason": "Consultation",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(
            Notification.objects.filter(
                user=self.doctor_user,
                title="Nouvelle demande de rendez-vous",
            ).exists()
        )

    def test_doctor_refuses_with_reason(self):
        appointment = self._create_appointment()
        self._authenticate(self.doctor_token)

        response = self.client.post(
            reverse("appointment-refuse", args=[appointment.id]),
            {"reason": "Indisponible"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        appointment.refresh_from_db()
        self.assertEqual(appointment.status, "REFUSED")
        self.assertEqual(appointment.refusal_reason, "Indisponible")

    def test_patient_cancels_with_reason(self):
        appointment = self._create_appointment(status_value="CONFIRMED")
        self._authenticate(self.patient_token)

        response = self.client.post(
            reverse("appointment-cancel", args=[appointment.id]),
            {"reason": "Empêchement"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        appointment.refresh_from_db()
        self.assertEqual(appointment.status, "CANCELLED")
        self.assertEqual(appointment.cancel_reason, "Empêchement")

    def test_reminder_command_sends_once(self):
        appointment = self._create_appointment(
            status_value="CONFIRMED",
            date_value=timezone.now() + timedelta(hours=2),
        )

        call_command("send_appointment_reminders", stdout=StringIO())
        appointment.refresh_from_db()

        self.assertTrue(appointment.reminder_sent)
        self.assertEqual(
            Notification.objects.filter(title="Rappel de rendez-vous").count(),
            2,
        )

        call_command("send_appointment_reminders", stdout=StringIO())
        self.assertEqual(
            Notification.objects.filter(title="Rappel de rendez-vous").count(),
            2,
        )
