from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, permission_classes, api_view
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate, login, logout
from django.db import transaction
from datetime import datetime, time

from .models import User, PatientProfile, DoctorProfile, MedicalDocument
from .serializers import (
    UserSerializer, PatientProfileSerializer, DoctorProfileSerializer,
    RegisterPatientSerializer, LoginSerializer, PatientDashboardSerializer,
    MedicalDocumentSerializer, RegisterDoctorSerializer
)
from .permissions import IsAgentOrSuperAdmin


@api_view(['GET'])
@permission_classes([AllowAny])
def api_home(request):
    return Response({
        "message": "MedConnect backend is running.",
        "admin_url": "/admin/",
        "api_root": "/api/",
        "login_url": "/api/auth/login/",
        "patient_dashboard_url": "/api/patient/dashboard/",
    })

# Vues d'authentification
class AuthViewSet(viewsets.GenericViewSet):
    permission_classes = [AllowAny]
    
    @action(detail=False, methods=['post'], url_path='register/patient')
    def register_patient(self, request):
        """Inscription d'un nouveau patient"""
        serializer = RegisterPatientSerializer(data=request.data)
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    patient_profile = serializer.save()
                    
                    # Créer un token pour l'utilisateur
                    token, created = Token.objects.get_or_create(user=patient_profile.user)
                    
                    # Préparer la réponse
                    response_data = {
                        'token': token.key,
                        'user': UserSerializer(patient_profile.user).data,
                        'patient_profile': PatientProfileSerializer(patient_profile).data,
                        'message': 'Inscription réussie'
                    }
                    
                    return Response(response_data, status=status.HTTP_201_CREATED)
                    
            except Exception as e:
                return Response(
                    {'error': str(e)}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'], url_path='register/doctor')
    def register_doctor(self, request):
        """Inscription d'un nouveau médecin"""
        serializer = RegisterDoctorSerializer(data=request.data)
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    doctor_profile = serializer.save()
                    
                    # Créer un token pour l'utilisateur
                    token, created = Token.objects.get_or_create(user=doctor_profile.user)
                    
                    # Préparer la réponse
                    response_data = {
                        'token': token.key,
                        'user': UserSerializer(doctor_profile.user).data,
                        'doctor_profile': DoctorProfileSerializer(doctor_profile).data,
                        'message': 'Inscription médecin réussie'
                    }
                    
                    return Response(response_data, status=status.HTTP_201_CREATED)
                    
            except Exception as e:
                return Response(
                    {'error': str(e)}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], url_path='login')
    def user_login(self, request):
        """Connexion d'un utilisateur"""
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            
            # Créer ou récupérer le token
            token, created = Token.objects.get_or_create(user=user)
            
            # Préparer la réponse selon le rôle
            response_data = {
                'token': token.key,
                'user': UserSerializer(user).data,
                'message': 'Connexion réussie'
            }
            
            # Ajouter les données spécifiques au rôle
            if user.is_patient():
                try:
                    patient_profile = PatientProfile.objects.get(user=user)
                    response_data['patient_profile'] = PatientProfileSerializer(patient_profile).data
                except PatientProfile.DoesNotExist:
                    pass
            elif user.is_doctor():
                try:
                    doctor_profile = DoctorProfile.objects.get(user=user)
                    response_data['doctor_profile'] = DoctorProfileSerializer(doctor_profile).data
                except DoctorProfile.DoesNotExist:
                    pass
            
            return Response(response_data, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def logout(self, request):
        """Déconnexion de l'utilisateur"""
        try:
            # Supprimer le token
            Token.objects.filter(user=request.user).delete()
            logout(request)
            return Response({'message': 'Déconnexion réussie'}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

# Vue pour la gestion des utilisateurs (admin)
class UserAdminViewSet(viewsets.ModelViewSet):
    """
    CRUD utilisateur accessible uniquement aux agents / superadmins.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAgentOrSuperAdmin]

# Vue pour les patients
class PatientViewSet(viewsets.ModelViewSet):
    """
    CRUD pour les profils patients.
    """
    queryset = PatientProfile.objects.all()
    serializer_class = PatientProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Les patients ne voient que leur propre profil
        # Les agents et admins voient tous les patients
        user = self.request.user
        if user.is_patient():
            return PatientProfile.objects.filter(user=user)
        return PatientProfile.objects.all()
    
    def get_permissions(self):
        # Autoriser l'inscription sans authentification
        if self.action == 'create':
            return [AllowAny()]
        return super().get_permissions()

from rest_framework.views import APIView

class PatientDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        
        # Vérifier si l'utilisateur est un patient
        if not user.is_patient():
            return Response(
                {"error": "Accès réservé aux patients."}, 
                status=status.HTTP_403_FORBIDDEN
            )
            
        serializer = PatientDashboardSerializer(user)
        return Response(serializer.data)

class PatientProfileView(APIView):
    """
    Vue pour récupérer et modifier le profil du patient connecté.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        if not user.is_patient():
            return Response({"error": "Accès réservé aux patients."}, status=status.HTTP_403_FORBIDDEN)
            
        try:
            profile = user.patientprofile
        except PatientProfile.DoesNotExist:
            return Response({"error": "Profil introuvable."}, status=status.HTTP_404_NOT_FOUND)
            
        serializer = PatientProfileSerializer(profile)
        return Response(serializer.data)
        
    def put(self, request):
        user = request.user
        if not user.is_patient():
            return Response({"error": "Accès réservé aux patients."}, status=status.HTTP_403_FORBIDDEN)
            
        try:
            profile = user.patientprofile
        except PatientProfile.DoesNotExist:
            return Response({"error": "Profil introuvable."}, status=status.HTTP_404_NOT_FOUND)
            
        serializer = PatientProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class DoctorViewSet(viewsets.ModelViewSet):
    queryset = DoctorProfile.objects.all()
    serializer_class = DoctorProfileSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=True, methods=['get'])
    def availability(self, request, pk=None):
        """
        Retourne les créneaux disponibles pour une date donnée.
        Query param: date (YYYY-MM-DD)
        """
        doctor = self.get_object()
        date_str = request.query_params.get('date')
        
        if not date_str:
            return Response({"error": "Date param required"}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        except ValueError:
            return Response({"error": "Invalid date format"}, status=status.HTTP_400_BAD_REQUEST)
            
        from .services import AppointmentValidationService
        slots = AppointmentValidationService.get_available_slots(doctor, target_date)
        
        return Response({
            "doctor": doctor.user.get_full_name(),
            "date": str(target_date),
            "slots": [slot.strftime("%H:%M") for slot in slots]
        })

    @action(detail=False, methods=['get'])
    def my_patients(self, request):
        """
        Retourne la liste des patients ayant eu au moins un RDV avec le médecin connecté.
        """
        user = request.user
        if not user.is_doctor():
            return Response({"error": "Accès réservé aux médecins"}, status=status.HTTP_403_FORBIDDEN)
            
        doctor = user.doctorprofile
        # Récupérer les IDs des patients uniques ayant un RDV avec ce médecin
        patient_ids = Appointment.objects.filter(doctor=doctor).values_list('patient', flat=True).distinct()
        patients = PatientProfile.objects.filter(id__in=patient_ids)
        
        serializer = PatientProfileSerializer(patients, many=True)
        serializer = PatientProfileSerializer(patients, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], url_path='update_schedule')
    def update_schedule(self, request):
        """
        Met à jour les horaires du médecin connecté.
        Format attendu:
        {
          "slotDurationMinutes": 30,
          "workingHours": {
            "0": [{"start_hour": 9, "start_minute": 0, "end_hour": 17, "end_minute": 0}],
            ...
          }
        }
        """
        user = request.user
        if not user.is_doctor():
            return Response({"error": "Accès réservé aux médecins"}, status=status.HTTP_403_FORBIDDEN)
            
        doctor = user.doctorprofile
        data = request.data
        
        try:
            with transaction.atomic():
                # 1. Supprimer les anciens créneaux
                from .models import AvailabilitySlot
                AvailabilitySlot.objects.filter(doctor=doctor).delete()
                
                # 2. Créer les nouveaux créneaux
                working_hours = data.get('workingHours', {})
                # Note: slotDurationMinutes is ignored for now as it's not in the model.
                
                for day_str, ranges in working_hours.items():
                    day_of_week = int(day_str)
                    
                    # Convert JS 1-7 to Python 0-6 if needed?
                    # Dart: Mon=1...Sun=7. Django: Mon=0...Sun=6.
                    # MAPPING REQUIRED: Django = Dart - 1.
                    # Wait, let's verify Dart.
                    # Dart DateTime.weekday: Monday=1, Sunday=7.
                    # Django Weekday: Monday=0, Sunday=6.
                    # So we must subtract 1.
                    
                    django_day = day_of_week - 1
                    if django_day < 0: django_day = 6 # Sunday 7 -> 6? No 1-1=0. 7-1=6.
                    
                    for time_range in ranges:
                        start_time = time(
                            hour=time_range['start_hour'], 
                            minute=time_range['start_minute']
                        )
                        end_time = time(
                            hour=time_range['end_hour'], 
                            minute=time_range['end_minute']
                        )
                        
                        AvailabilitySlot.objects.create(
                            doctor=doctor,
                            day_of_week=django_day,
                            start_time=start_time,
                            end_time=end_time
                        )
                
                return Response({"message": "Horaires mis à jour avec succès"})
                
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='get_schedule')
    def get_schedule(self, request):
        """
        Récupère les horaires du médecin connecté.
        """
        user = request.user
        if not user.is_doctor():
            return Response({"error": "Accès réservé aux médecins"}, status=status.HTTP_403_FORBIDDEN)
            
        doctor = user.doctorprofile
        from .models import AvailabilitySlot
        
        slots = AvailabilitySlot.objects.filter(doctor=doctor)
        working_hours = {}
        
        for slot in slots:
            # Convertir Django (0-6) vers Frontend/Dart (1-7)
            # Dart Mon=1 -> Django=0. Donc Django 0 -> Dart 1.
            # 6 (Dimanche) -> 7.
            dart_day = slot.day_of_week + 1
            
            day_key = str(dart_day)
            if day_key not in working_hours:
                working_hours[day_key] = []
            
            working_hours[day_key].append({
                "start_hour": slot.start_time.hour,
                "start_minute": slot.start_time.minute,
                "end_hour": slot.end_time.hour,
                "end_minute": slot.end_time.minute
            })
            
        return Response({
            "slotDurationMinutes": 30, # Default or stored if model updated
            "workingHours": working_hours
        })

    @action(detail=False, methods=['get'], url_path='profile')
    def get_profile(self, request):
        """
        Récupère le profil du médecin connecté.
        """
        user = request.user
        if not user.is_doctor():
            return Response({"error": "Accès réservé aux médecins"}, status=status.HTTP_403_FORBIDDEN)
        
        doctor = user.doctorprofile
        serializer = DoctorProfileSerializer(doctor)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], url_path='update_profile')
    def update_profile(self, request):
        """
        Met à jour le profil du médecin connecté (bio, tarif, etc.).
        """
        user = request.user
        if not user.is_doctor():
            return Response({"error": "Accès réservé aux médecins"}, status=status.HTTP_403_FORBIDDEN)
        
        doctor = user.doctorprofile
        # Partial update allows sending only fields that changed
        serializer = DoctorProfileSerializer(doctor, data=request.data, partial=True)
        
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from .serializers import AppointmentSerializer, CreateAppointmentSerializer
from .models import Appointment

class AppointmentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return CreateAppointmentSerializer
        return AppointmentSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_patient():
            return Appointment.objects.filter(patient__user=user)
        elif user.is_doctor():
            return Appointment.objects.filter(doctor__user=user)
        return Appointment.objects.none()

    def perform_create(self, serializer):
        user = self.request.user
        if user.is_patient():
            serializer.save(patient=user.patientprofile)
        else:
            # Pour l'instant on empêche les médecins de créer des RDV pour eux-mêmes via cette API
            # ou on pourrait implémenter une logique différente
            raise serializers.ValidationError("Seuls les patients peuvent prendre rendez-vous pour le moment.")

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        
        # Utiliser le serializer de lecture pour la réponse
        read_serializer = AppointmentSerializer(serializer.instance)
        headers = self.get_success_headers(read_serializer.data)
        return Response(read_serializer.data, status=status.HTTP_201_CREATED, headers=headers)

class MedicalDocumentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = MedicalDocumentSerializer

    def get_queryset(self):
        user = self.request.user
        queryset = MedicalDocument.objects.all()
        
        # Filter by patient ID if provided (common for both roles)
        patient_id = self.request.query_params.get('patient')
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
            
        if user.is_patient():
            return queryset.filter(patient__user=user)
        elif user.is_doctor():
            # Doctor can see documents if he knows the patient ID (filtered above)
            # OR documents explicitly linked to him.
            # If no patient_id filter, maybe show all docs linked to him?
            if patient_id:
                # If viewing a specific patient, show all their docs?
                # For privacy, should we ensure this patient is "his" patient?
                # Currently we don't have strict "My Patients" enforcement in backend models (only Appointment linkage).
                # We'll allow it if patient_id is provided.
                return queryset
            else:
                # Default list: documents assigned to this doctor or uploaded by him
                return queryset.filter(doctor__user=user)
        return MedicalDocument.objects.none()

    def get_permissions(self):
        if self.action in ['update', 'partial_update', 'destroy']:
            # Requirement: patient cannot modify/delete
            # You might want to allow doctors to modify their own issued documents
            # For now, let's stick to the simplest restriction
            return [IsAuthenticated()]
        return super().get_permissions()

    def check_permissions(self, request):
        super().check_permissions(request)
        if self.action in ['update', 'partial_update', 'destroy'] and request.user.is_patient():
            self.permission_denied(request, message="Les patients ne peuvent pas modifier ou supprimer des documents.")

    @action(detail=False, methods=['post'], url_path='upload')
    def upload(self, request):
        user = request.user
        
        # Validation file size (10MB)
        file_obj = request.FILES.get('file')
        if not file_obj:
            return Response({"error": "Aucun fichier fourni"}, status=status.HTTP_400_BAD_REQUEST)
        
        if file_obj.size > 10 * 1024 * 1024:
            return Response({"error": "Fichier trop volumineux (max 10MB)"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validation extension
        ext = file_obj.name.split('.')[-1].lower()
        if ext not in ['pdf', 'jpg', 'jpeg', 'png']:
            return Response({"error": "Type de fichier non supporté (PDF, JPG, PNG uniquement)"}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            if user.is_patient():
                serializer.save(
                    patient=user.patientprofile,
                    uploaded_by=MedicalDocument.UploadedBy.PATIENT
                )
            elif user.is_doctor():
                # If doctor, need to provide patient ID
                patient_id = request.data.get('patient')
                if not patient_id:
                    return Response({"error": "ID du patient requis pour l'upload par un médecin"}, status=status.HTTP_400_BAD_REQUEST)
                try:
                    patient = PatientProfile.objects.get(id=patient_id)
                except PatientProfile.DoesNotExist:
                    return Response({"error": "Patient non trouvé"}, status=status.HTTP_404_NOT_FOUND)
                
                serializer.save(
                    patient=patient,
                    doctor=user.doctorprofile,
                    uploaded_by=MedicalDocument.UploadedBy.DOCTOR
                )
            else:
                return Response({"error": "Action non autorisée"}, status=status.HTTP_403_FORBIDDEN)
                
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from .serializers import MedicalRecordSerializer
from .models import MedicalRecord

class MedicalRecordViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = MedicalRecordSerializer
    
    def get_queryset(self):
        user = self.request.user
        queryset = MedicalRecord.objects.all()
        
        # Filtrer par patient si demandé
        patient_id = self.request.query_params.get('patient')
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
            
        if user.is_patient():
            return queryset.filter(patient__user=user)
        elif user.is_doctor():
            # Le médecin peut voir tous les dossiers (pour ses patients)
            # Ou on peut restreindre à ceux qu'il a créés OU ceux de ses patients ("My Patients")
            # Pour l'instant, on laisse ouvert pour consulter l'historique global si on a l'ID patient
            return queryset
        return MedicalRecord.objects.none()


    def perform_create(self, serializer):
        user = self.request.user
        if not user.is_doctor():
            raise serializers.ValidationError("Seuls les médecins peuvent créer des dossiers médicaux.")
        serializer.save(doctor=user.doctorprofile)

class PatientMedicalRecordView(APIView):
    """
    Vue agrégée pour le dossier médical du patient.
    Retourne:
    - Infos patient
    - Historique des consultations (basé sur MedicalRecord)
    - Documents
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if not user.is_patient():
            return Response({"error": "Accès réservé aux patients"}, status=status.HTTP_403_FORBIDDEN)
        
        try:
            profile = user.patientprofile
        except PatientProfile.DoesNotExist:
            return Response({"error": "Profil patient introuvable"}, status=status.HTTP_404_NOT_FOUND)

        # 1. Infos Patient
        patient_info = {
            "full_name": user.get_full_name(),
            "blood_type": profile.blood_type,
            "allergies": profile.allergies,
            "height": profile.height,
            "weight": profile.weight,
            "emergency_contact": profile.emergency_contact,
            "emergency_phone": profile.emergency_phone,
        }

        # 2. Consultations (Mapping MedicalRecord -> ConsultationInfo)
        # On récupère tous les dossiers médicaux de ce patient
        records = MedicalRecord.objects.filter(patient=profile).select_related('doctor', 'doctor__user', 'doctor__speciality').order_by('-record_date')
        
        consultations = []
        for record in records:
            doctor_name = record.doctor.user.get_full_name() if record.doctor else "Inconnu"
            specialty = record.doctor.speciality.name if (record.doctor and record.doctor.speciality) else "Généraliste"
            
            # Construction des notes combinées
            notes_parts = []
            if record.description: notes_parts.append(f"Description: {record.description}")
            if record.diagnosis: notes_parts.append(f"Diagnostic: {record.diagnosis}")
            if record.treatment: notes_parts.append(f"Traitement: {record.treatment}")
            
            consultations.append({
                "id": record.id,
                "doctor_name": doctor_name,
                "specialty": specialty,
                "date": record.record_date.isoformat(),
                "reason": record.title, # Le titre du dossier devient le motif
                "notes_patient": "\n\n".join(notes_parts)
            })

        # 3. Documents
        documents_qs = MedicalDocument.objects.filter(patient=profile).select_related('doctor', 'doctor__user').order_by('-created_at')
        documents_data = []
        # On utilise le serializer existant pour plus de facilité
        doc_serializer = MedicalDocumentSerializer(documents_qs, many=True, context={'request': request})
        documents_data = doc_serializer.data

        response_data = {
            "patient_info": patient_info,
            "consultations": consultations,
            "documents": documents_data
        }

        return Response(response_data)

