from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from rest_framework import serializers

from .models import (
    Appointment,
    Conversation,
    DoctorProfile,
    Message,
    MessageAttachment,
    MedicalDocument,
    MedicalRecord,
    Notification,
    PatientProfile,
    User,
)


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "email",
            "first_name",
            "last_name",
            "phone",
            "role",
            "password",
            "is_active",
            "date_of_birth",
            "address",
        ]
        extra_kwargs = {
            "password": {"write_only": True},
            "is_active": {"read_only": True},
        }

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        user = super().create(validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop("password", None)
        user = super().update(instance, validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user


class PatientProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = PatientProfile
        fields = [
            "id",
            "user",
            "blood_type",
            "allergies",
            "emergency_contact",
            "emergency_phone",
            "height",
            "weight",
        ]
        read_only_fields = ["id"]

    def create(self, validated_data):
        user_data = validated_data.pop("user")
        password = user_data.pop("password", None)
        user = User.objects.create(**user_data)
        if password:
            user.set_password(password)
            user.save()
        return PatientProfile.objects.create(user=user, **validated_data)


class DoctorProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    speciality_name = serializers.CharField(source="speciality.name", read_only=True)

    class Meta:
        model = DoctorProfile
        fields = [
            "id",
            "user",
            "speciality",
            "speciality_name",
            "license_number",
            "city",
            "location",
            "years_of_experience",
            "consultation_fee",
            "is_available",
            "bio",
        ]
        read_only_fields = ["id"]


class RegisterPatientSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=True)
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)
    first_name = serializers.CharField(max_length=30, required=False, allow_blank=True, allow_null=True)
    last_name = serializers.CharField(max_length=150, required=False, allow_blank=True, allow_null=True)
    phone = serializers.CharField(max_length=20, required=False, allow_blank=True, allow_null=True)
    blood_type = serializers.CharField(max_length=10, required=False, allow_blank=True, allow_null=True)
    allergies = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    emergency_contact = serializers.CharField(max_length=100, required=False, allow_blank=True, allow_null=True)
    emergency_phone = serializers.CharField(max_length=20, required=False, allow_blank=True, allow_null=True)

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Cet email est déjà utilisé.")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est déjà pris.")
        return value

    def create(self, validated_data):
        blood_type = validated_data.pop("blood_type", "")
        allergies = validated_data.pop("allergies", "")
        emergency_contact = validated_data.pop("emergency_contact", "")
        emergency_phone = validated_data.pop("emergency_phone", "")
        password = validated_data.pop("password")

        user = User.objects.create(
            **validated_data,
            role=User.Roles.PATIENT,
            is_active=True,
        )
        user.set_password(password)
        user.save()

        return PatientProfile.objects.create(
            user=user,
            blood_type=blood_type or None,
            allergies=allergies or None,
            emergency_contact=emergency_contact or None,
            emergency_phone=emergency_phone or None,
        )


class RegisterDoctorSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=True)
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)
    first_name = serializers.CharField(max_length=30, required=False, allow_blank=True, allow_null=True)
    last_name = serializers.CharField(max_length=150, required=False, allow_blank=True, allow_null=True)
    phone = serializers.CharField(max_length=20, required=False, allow_blank=True, allow_null=True)
    license_number = serializers.CharField(max_length=50, required=True)
    specialty = serializers.CharField(required=True)
    address = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    city = serializers.CharField(max_length=100, required=False, allow_blank=True, allow_null=True)
    location = serializers.CharField(max_length=200, required=False, allow_blank=True, allow_null=True)
    bio = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    consultation_fee = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, default=0)

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Cet email est déjà utilisé.")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est déjà pris.")
        return value

    def validate_license_number(self, value):
        if DoctorProfile.objects.filter(license_number=value).exists():
            raise serializers.ValidationError("Ce numéro de licence est déjà utilisé.")
        return value

    def create(self, validated_data):
        from .models import Speciality

        license_number = validated_data.pop("license_number")
        specialty_name = validated_data.pop("specialty")
        address = validated_data.pop("address", "")
        city = validated_data.pop("city", "")
        location = validated_data.pop("location", "")
        bio = validated_data.pop("bio", "")
        consultation_fee = validated_data.pop("consultation_fee", 0)
        password = validated_data.pop("password")

        user = User.objects.create(
            **validated_data,
            address=address,
            role=User.Roles.DOCTOR,
            is_active=True,
        )
        user.set_password(password)
        user.save()

        speciality_obj, _ = Speciality.objects.get_or_create(
            name=specialty_name,
            defaults={"description": f"Spécialité : {specialty_name}"},
        )

        return DoctorProfile.objects.create(
            user=user,
            speciality=speciality_obj,
            license_number=license_number,
            city=city,
            location=location,
            bio=bio,
            consultation_fee=consultation_fee,
        )


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError("Identifiants incorrects.")

        if not user.check_password(password):
            raise serializers.ValidationError("Identifiants incorrects.")
        if not user.is_active:
            raise serializers.ValidationError("Ce compte est désactivé.")

        data["user"] = user
        return data


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source="doctor.user.get_full_name", read_only=True)
    patient_name = serializers.CharField(source="patient.user.get_full_name", read_only=True)
    specialty = serializers.CharField(source="doctor.speciality.name", read_only=True)

    class Meta:
        model = Appointment
        fields = [
            "id",
            "doctor",
            "patient",
            "doctor_name",
            "patient_name",
            "specialty",
            "date",
            "duration",
            "status",
            "reason",
            "refusal_reason",
            "notes_patient",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "doctor",
            "patient",
            "status",
            "created_at",
            "notes_patient",
            "refusal_reason",
        ]


class MedicalDocumentSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source="doctor.user.get_full_name", read_only=True, allow_null=True)
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = MedicalDocument
        fields = [
            "id",
            "title",
            "document_type",
            "description",
            "file",
            "file_url",
            "doctor",
            "doctor_name",
            "uploaded_by",
            "created_at",
        ]
        read_only_fields = ["id", "created_at", "doctor_name", "file_url"]

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get("request")
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None


class MedicalRecordSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source="doctor.user.get_full_name", read_only=True)

    class Meta:
        model = MedicalRecord
        fields = [
            "id",
            "patient",
            "doctor",
            "doctor_name",
            "title",
            "description",
            "diagnosis",
            "treatment",
            "record_date",
            "created_at",
        ]
        read_only_fields = ["id", "doctor", "created_at", "record_date"]


class CreateAppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appointment
        fields = ["doctor", "date", "reason"]

    def validate(self, data):
        from .services import AppointmentValidationService
        import logging

        logger = logging.getLogger(__name__)
        doctor = data["doctor"]
        date = data["date"]

        logger.warning(
            f"[DEBUG] CreateAppointment validate: doctor={doctor}, date={date}, type={type(date)}, is_naive={timezone.is_naive(date) if hasattr(date, 'tzinfo') else 'N/A'}"
        )

        is_valid_time, message = AppointmentValidationService.validate_appointment_retention(date)
        if not is_valid_time:
            logger.warning(f"[DEBUG] validate_appointment_retention FAILED: {message}")
            raise serializers.ValidationError(message)

        normalized_date = date
        if timezone.is_naive(normalized_date):
            normalized_date = timezone.make_aware(
                normalized_date,
                timezone.get_current_timezone(),
            )

        available_slots = AppointmentValidationService.get_available_slots(
            doctor,
            normalized_date.date(),
        )
        requested_slot = normalized_date.replace(second=0, microsecond=0)

        logger.warning(f"[DEBUG] normalized_date={normalized_date}, requested_slot={requested_slot}")
        logger.warning(f"[DEBUG] available_slots={available_slots}")
        logger.warning(f"[DEBUG] target_date={normalized_date.date()}, weekday={normalized_date.date().weekday()}")

        slot_exists = any(
            slot.replace(second=0, microsecond=0) == requested_slot
            for slot in available_slots
        )
        if not slot_exists:
            logger.warning(
                f"[DEBUG] SLOT NOT FOUND! requested={requested_slot} not in {[s.replace(second=0, microsecond=0) for s in available_slots]}"
            )
            raise serializers.ValidationError(
                "Ce créneau n'est plus disponible. Veuillez actualiser les horaires."
            )

        return data

    def create(self, validated_data):
        return super().create(validated_data)


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "title", "message", "date", "type"]


class MessageAttachmentSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = MessageAttachment
        fields = [
            "id",
            "file",
            "file_url",
            "file_name",
            "file_type",
            "file_size",
            "uploaded_at",
        ]
        read_only_fields = fields

    def get_file_url(self, obj):
        request = self.context.get("request")
        if request:
            return request.build_absolute_uri(obj.file.url)
        return obj.file.url


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source="sender.get_full_name", read_only=True)
    sender_role = serializers.CharField(source="sender.role", read_only=True)
    is_mine = serializers.SerializerMethodField()
    attachments = MessageAttachmentSerializer(many=True, read_only=True)
    has_attachments = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            "id",
            "conversation",
            "sender",
            "sender_name",
            "sender_role",
            "content",
            "is_read",
            "created_at",
            "is_mine",
            "attachments",
            "has_attachments",
        ]
        read_only_fields = [
            "id",
            "conversation",
            "sender",
            "sender_name",
            "sender_role",
            "content",
            "is_read",
            "created_at",
            "is_mine",
            "attachments",
            "has_attachments",
        ]

    def get_is_mine(self, obj):
        request = self.context.get("request")
        return bool(request and request.user == obj.sender)

    def get_has_attachments(self, obj):
        return obj.attachments.exists()


class SendMessageSerializer(serializers.Serializer):
    content = serializers.CharField(
        required=False,
        allow_blank=True,
        trim_whitespace=True,
    )

    def validate_content(self, value):
        return value.strip()

    def validate(self, attrs):
        content = attrs.get("content", "").strip()
        has_file = bool(self.context.get("has_file"))
        if not content and not has_file:
            raise serializers.ValidationError("Le message ne peut pas être vide.")
        attrs["content"] = content
        return attrs


class StartConversationSerializer(serializers.Serializer):
    doctor_id = serializers.IntegerField(required=False)
    patient_id = serializers.IntegerField(required=False)

    def validate(self, attrs):
        request = self.context["request"]
        user = request.user

        if user.is_patient():
            doctor_id = attrs.get("doctor_id")
            if not doctor_id:
                raise serializers.ValidationError({"doctor_id": "ID du médecin requis."})
            attrs["doctor"] = serializers.PrimaryKeyRelatedField(
                queryset=DoctorProfile.objects.all()
            ).to_internal_value(doctor_id)
        elif user.is_doctor():
            patient_id = attrs.get("patient_id")
            if not patient_id:
                raise serializers.ValidationError({"patient_id": "ID du patient requis."})
            attrs["patient"] = serializers.PrimaryKeyRelatedField(
                queryset=PatientProfile.objects.all()
            ).to_internal_value(patient_id)
        else:
            raise serializers.ValidationError("Action non autorisée.")

        return attrs


class ConversationSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source="patient.user.get_full_name", read_only=True)
    doctor_name = serializers.CharField(source="doctor.user.get_full_name", read_only=True)
    counterpart_name = serializers.SerializerMethodField()
    counterpart_role = serializers.SerializerMethodField()
    counterpart_id = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    last_message_at = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            "id",
            "patient",
            "doctor",
            "patient_name",
            "doctor_name",
            "counterpart_name",
            "counterpart_role",
            "counterpart_id",
            "last_message",
            "last_message_at",
            "unread_count",
            "updated_at",
        ]
        read_only_fields = fields

    def _get_counterpart(self, obj):
        request = self.context.get("request")
        if request and request.user.is_doctor():
            return obj.patient, "PATIENT"
        return obj.doctor, "DOCTOR"

    def get_counterpart_name(self, obj):
        counterpart, role = self._get_counterpart(obj)
        if role == "DOCTOR":
            return f"Dr. {counterpart.user.get_full_name()}".strip()
        return counterpart.user.get_full_name()

    def get_counterpart_role(self, obj):
        return self._get_counterpart(obj)[1]

    def get_counterpart_id(self, obj):
        return self._get_counterpart(obj)[0].id

    def get_last_message(self, obj):
        last_message = getattr(obj, "last_message_cached", None)
        if last_message is None:
            last_message = obj.messages.order_by("-created_at").first()
        return last_message.content if last_message else ""

    def get_last_message_at(self, obj):
        last_message = getattr(obj, "last_message_cached", None)
        if last_message is None:
            last_message = obj.messages.order_by("-created_at").first()
        return last_message.created_at if last_message else obj.updated_at

    def get_unread_count(self, obj):
        request = self.context.get("request")
        if not request:
            return 0
        return obj.messages.filter(is_read=False).exclude(sender=request.user).count()


class PatientDashboardSerializer(serializers.Serializer):
    user_info = serializers.SerializerMethodField()
    patient_profile = serializers.SerializerMethodField()
    next_appointment = serializers.SerializerMethodField()
    unread_messages_count = serializers.SerializerMethodField()
    new_documents_count = serializers.SerializerMethodField()
    recent_notifications = serializers.SerializerMethodField()

    def get_user_info(self, obj):
        return {
            "first_name": obj.first_name,
            "last_name": obj.last_name,
            "email": obj.email,
            "phone": obj.phone,
        }

    def get_patient_profile(self, obj):
        try:
            profile = obj.patientprofile
            return {
                "blood_type": profile.blood_type,
                "allergies": profile.allergies,
                "emergency_contact": profile.emergency_contact,
                "emergency_phone": profile.emergency_phone,
            }
        except PatientProfile.DoesNotExist:
            return None

    def get_next_appointment(self, obj):
        try:
            profile = obj.patientprofile
            next_appt = Appointment.objects.filter(
                patient=profile,
                date__gte=timezone.now(),
                status="CONFIRMED",
            ).order_by("date").first()
            if not next_appt:
                next_appt = Appointment.objects.filter(
                    patient=profile,
                    date__gte=timezone.now(),
                    status="PENDING",
                ).order_by("date").first()
            if next_appt:
                return AppointmentSerializer(next_appt).data
            return None
        except PatientProfile.DoesNotExist:
            return None

    def get_new_documents_count(self, obj):
        try:
            profile = obj.patientprofile
            week_ago = timezone.now() - timezone.timedelta(days=7)
            return MedicalDocument.objects.filter(patient=profile, created_at__gte=week_ago).count()
        except PatientProfile.DoesNotExist:
            return 0

    def get_recent_notifications(self, obj):
        notifications = Notification.objects.filter(user=obj).order_by("-date")[:5]
        return NotificationSerializer(notifications, many=True).data

    def get_unread_messages_count(self, obj):
        try:
            profile = obj.patientprofile
        except PatientProfile.DoesNotExist:
            return 0

        return Message.objects.filter(
            conversation__patient=profile,
            is_read=False,
        ).exclude(sender=obj).count()
