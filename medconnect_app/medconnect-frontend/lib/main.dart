import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/patient_auth_view_model.dart';
import 'view_models/doctor_auth_view_model.dart';
import 'view_models/patient/patient_dashboard_view_model.dart';
import 'view_models/patient/appointment_view_model.dart';
import 'view_models/patient/patient_profile_view_model.dart';
import 'view_models/patient/medical_document_view_model.dart';
import 'view_models/patient/medical_record_view_model.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/doctor_dashboard_view_model.dart';
import 'views/auth/combined_login_screen.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'services/api_auth_service.dart';
import 'services/appointment_service.dart';
import 'repositories/appointment_repository.dart';
import 'view_models/doctor_appointment_view_model.dart';
import 'view_models/doctor_profile_view_model.dart';
import 'repositories/doctor_repository.dart';
import 'view_models/doctor_patients_view_model.dart';
import 'repositories/doctor_patient_repository.dart';
import 'view_models/doctor_medical_record_view_model.dart';
import 'view_models/doctor_medical_document_view_model.dart';
import 'view_models/messages_view_model.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = ApiAuthService();
    final AuthRepository authRepository = AuthRepository(authService);

    // Legacy support if needed
    final AuthViewModel authViewModel = AuthViewModel(authRepository);

    // New ViewModels
    final PatientAuthViewModel patientAuthViewModel = PatientAuthViewModel(
      authRepository,
    );
    final DoctorAuthViewModel doctorAuthViewModel = DoctorAuthViewModel(
      authRepository,
    );
    // DoctorDashboardViewModel
    final DoctorDashboardViewModel doctorDashboardViewModel = DoctorDashboardViewModel();

    final AppointmentService appointmentService = AppointmentService();
    final AppointmentRepository appointmentRepository = AppointmentRepository(appointmentService);
    final DoctorAppointmentViewModel doctorAppointmentViewModel = DoctorAppointmentViewModel(appointmentRepository);

    final PatientDashboardViewModel patientDashboardViewModel =
        PatientDashboardViewModel();
    final AppointmentViewModel appointmentViewModel = AppointmentViewModel();
    final MessagesViewModel messagesViewModel = MessagesViewModel();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authViewModel),
        ChangeNotifierProvider(create: (_) => patientAuthViewModel),
        ChangeNotifierProvider(create: (_) => doctorAuthViewModel),
        ChangeNotifierProvider(create: (_) => doctorDashboardViewModel),
        ChangeNotifierProvider(create: (_) => patientDashboardViewModel),
        ChangeNotifierProvider(create: (_) => appointmentViewModel),
        ChangeNotifierProvider(create: (_) => messagesViewModel),
        ChangeNotifierProvider(create: (_) => PatientProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalDocumentViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalRecordViewModel()),
        ChangeNotifierProvider(create: (_) => doctorAppointmentViewModel),
        ChangeNotifierProvider(create: (_) => DoctorProfileViewModel(DoctorRepository())),
        ChangeNotifierProvider(create: (_) => DoctorPatientsViewModel(DoctorPatientRepository())),
        ChangeNotifierProvider(create: (_) => DoctorMedicalRecordViewModel()),
        ChangeNotifierProvider(create: (_) => DoctorMedicalDocumentViewModel()),
      ],
      child: MaterialApp(
        title: 'MedConnect',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF1F8E9),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(
                primary: const Color(0xFF388E3C),
                secondary: const Color(0xFF81C784),
              ),
        ),
        home: const CombinedLoginScreen(),
      ),
    );
  }
}
