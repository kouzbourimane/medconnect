from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class User(AbstractUser):
    class Roles(models.TextChoices):
        PATIENT = "PATIENT", "Patient"
        DOCTOR = "DOCTOR", "Médecin"
        AGENT = "AGENT", "Agent administratif"
        SUPERADMIN = "SUPERADMIN", "Super administrateur"

    phone = models.CharField(max_length=20, blank=True, null=True)
    role = models.CharField(max_length=20, choices=Roles.choices, default=Roles.PATIENT)
    date_of_birth = models.DateField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"

    def is_patient(self):
        return self.role == self.Roles.PATIENT

    def is_doctor(self):
        return self.role == self.Roles.DOCTOR

    def is_agent(self):
        return self.role == self.Roles.AGENT

    def is_superadmin(self):
        return self.role == self.Roles.SUPERADMIN


class Speciality(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name


class DoctorProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    speciality = models.ForeignKey(Speciality, on_delete=models.SET_NULL, null=True, blank=True)
    license_number = models.CharField(max_length=50, unique=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    location = models.CharField(max_length=200, blank=True, null=True, help_text="Adresse précise ou coordonnées GPS")
    years_of_experience = models.IntegerField(default=0)
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    is_available = models.BooleanField(default=True)
    bio = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Dr. {self.user.get_full_name()} - {self.speciality}"


class PatientProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, limit_choices_to={'role': User.Roles.PATIENT})
    blood_type = models.CharField(max_length=10, blank=True, null=True)
    allergies = models.TextField(blank=True, null=True)
    emergency_contact = models.CharField(max_length=100, blank=True, null=True)
    emergency_phone = models.CharField(max_length=20, blank=True, null=True)
    height = models.FloatField(null=True, blank=True, help_text="Taille en cm")
    weight = models.FloatField(null=True, blank=True, help_text="Poids en kg")

    def __str__(self):
        return f"Patient: {self.user.get_full_name()}"


class MedicalRecord(models.Model):
    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name='medical_records')
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.SET_NULL, null=True, blank=True)
    title = models.CharField(max_length=200)
    description = models.TextField()
    diagnosis = models.TextField(blank=True, null=True)
    treatment = models.TextField(blank=True, null=True)
    record_date = models.DateTimeField(default=timezone.now)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-record_date']

    def __str__(self):
        return f"{self.title} - {self.patient.user.get_full_name()}"


class Appointment(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'En attente'),
        ('CONFIRMED', 'Confirmé'),
        ('CANCELLED', 'Annulé'),
        ('REFUSED', 'Refusé'),
        ('COMPLETED', 'Terminé'),
    ]

    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name='appointments')
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.CASCADE, related_name='appointments')
    date = models.DateTimeField()
    duration = models.IntegerField(default=30, help_text="Durée en minutes")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    reason = models.TextField(blank=True, null=True)
    refusal_reason = models.TextField(blank=True, null=True, help_text="Raison du refus (optionnel)")
    cancel_reason = models.TextField(blank=True, null=True, help_text="Raison de l'annulation (optionnel)")
    notes_patient = models.TextField(blank=True, null=True, help_text="Notes visibles par le patient")
    notes_doctor = models.TextField(blank=True, null=True, help_text="Notes privées du médecin")
    reminder_sent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f"RDV {self.patient.user.get_full_name()} avec {self.doctor.user.get_full_name()} le {self.date}"


class Notification(models.Model):
    TYPE_CHOICES = [
        ('INFO', 'Information'),
        ('WARNING', 'Avertissement'),
        ('SUCCESS', 'Succès'),
        ('ERROR', 'Erreur'),
        ('APPOINTMENT', 'Rendez-vous'),
        ('MESSAGE', 'Message'),
        ('DOCUMENT', 'Document'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    date = models.DateTimeField(default=timezone.now)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='INFO')
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f"{self.title} - {self.user.username}"


class Conversation(models.Model):
    patient = models.ForeignKey(
        PatientProfile,
        on_delete=models.CASCADE,
        related_name="conversations",
    )
    doctor = models.ForeignKey(
        DoctorProfile,
        on_delete=models.CASCADE,
        related_name="conversations",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at"]
        unique_together = ("patient", "doctor")

    def __str__(self):
        return f"Conversation {self.patient.user.get_full_name()} / Dr. {self.doctor.user.get_full_name()}"


class Message(models.Model):
    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.CASCADE,
        related_name="messages",
    )
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="sent_messages",
    )
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return f"Message #{self.id} by {self.sender.username}"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        Conversation.objects.filter(id=self.conversation_id).update(
            updated_at=timezone.now()
        )


class AvailabilitySlot(models.Model):
    DAYS_OF_WEEK = [
        (0, 'Lundi'), (1, 'Mardi'), (2, 'Mercredi'),
        (3, 'Jeudi'), (4, 'Vendredi'), (5, 'Samedi'), (6, 'Dimanche'),
    ]

    doctor = models.ForeignKey(DoctorProfile, on_delete=models.CASCADE, related_name='availability_slots')
    day_of_week = models.IntegerField(choices=DAYS_OF_WEEK)
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_recurring = models.BooleanField(default=True)

    class Meta:
        ordering = ['day_of_week', 'start_time']

    def __str__(self):
        return f"{self.doctor} - {self.get_day_of_week_display()} {self.start_time}-{self.end_time}"


class Holiday(models.Model):
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.CASCADE, related_name='holidays')
    date = models.DateField()
    reason = models.CharField(max_length=200, blank=True, null=True)

    class Meta:
        ordering = ['date']
        unique_together = ('doctor', 'date')


class MedicalDocument(models.Model):
    class DocumentType(models.TextChoices):
        ORDONNANCE = "ORDONNANCE", "Ordonnance"
        ANALYSE = "ANALYSE", "Analyse"
        AUTRE = "AUTRE", "Autre"

    class UploadedBy(models.TextChoices):
        DOCTOR = "DOCTOR", "Médecin"
        PATIENT = "PATIENT", "Patient"

    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name='medical_documents')
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.SET_NULL, null=True, blank=True, related_name='issued_documents')
    title = models.CharField(max_length=200)
    document_type = models.CharField(max_length=20, choices=DocumentType.choices, default=DocumentType.AUTRE)
    file = models.FileField(upload_to='medical_documents/')
    description = models.TextField(blank=True, null=True)
    uploaded_by = models.CharField(max_length=10, choices=UploadedBy.choices, default=UploadedBy.DOCTOR)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.patient.user.get_full_name()}"
