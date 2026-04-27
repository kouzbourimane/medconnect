from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AuthViewSet, UserAdminViewSet, PatientViewSet, PatchedAppointmentViewSet,
    PatientDashboardView, DoctorViewSet, PatientProfileView, MedicalDocumentViewSet,
    MedicalRecordViewSet, PatientMedicalRecordView
)

router = DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'users', UserAdminViewSet, basename='user')
router.register(r'patients', PatientViewSet, basename='patient')
router.register(r'doctors', DoctorViewSet, basename='doctor')
router.register(r'appointments', PatchedAppointmentViewSet, basename='appointment')
router.register(r'patient/documents', MedicalDocumentViewSet, basename='patient-documents')
router.register(r'medical-records', MedicalRecordViewSet, basename='medical-record')

urlpatterns = [
    path('api/', include(router.urls)),
    path('api/patient/dashboard/', PatientDashboardView.as_view(), name='patient-dashboard'),
    path('api/patient/profile/', PatientProfileView.as_view(), name='patient-profile'),
    path('api/patient/medical-record/', PatientMedicalRecordView.as_view(), name='patient-medical-record'),
    path('api-auth/', include('rest_framework.urls')),
]
