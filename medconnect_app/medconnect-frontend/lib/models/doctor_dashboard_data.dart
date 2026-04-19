import 'patient_dashboard_data.dart';

class DoctorDashboardData {
  final Map<String, dynamic>? doctorProfile;
  final List<DashboardAppointment> todayAppointments;
  final int patientsSeenCount;
  final int upcomingAppointmentsCount;
  final int unreadMessagesCount;
  final List<DashboardNotification> recentNotifications;

  DoctorDashboardData({
    required this.doctorProfile,
    required this.todayAppointments,
    required this.patientsSeenCount,
    required this.upcomingAppointmentsCount,
    required this.unreadMessagesCount,
    required this.recentNotifications,
  });

  factory DoctorDashboardData.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardData(
      doctorProfile: json['doctor_profile'],
      todayAppointments: (json['today_appointments'] as List?)
              ?.map((e) => DashboardAppointment.fromJson(e))
              .toList() ??
          [],
      patientsSeenCount: json['patients_seen_count'] ?? 0,
      upcomingAppointmentsCount: json['upcoming_appointments_count'] ?? 0,
      unreadMessagesCount: json['unread_messages_count'] ?? 0,
      recentNotifications: (json['recent_notifications'] as List?)
              ?.map((e) => DashboardNotification.fromJson(e))
              .toList() ??
          [],
    );
  }
}
