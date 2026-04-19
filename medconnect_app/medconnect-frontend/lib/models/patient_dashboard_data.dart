class PatientDashboardData {
  final Map<String, dynamic>? userInfo;
  final Map<String, dynamic>? patientProfile;
  final DashboardAppointment? nextAppointment;
  final int unreadMessagesCount;
  final int newDocumentsCount;
  final List<DashboardNotification> recentNotifications;

  PatientDashboardData({
    required this.userInfo,
    required this.patientProfile,
    this.nextAppointment,
    required this.unreadMessagesCount,
    required this.newDocumentsCount,
    required this.recentNotifications,
  });

  factory PatientDashboardData.fromJson(Map<String, dynamic> json) {
    return PatientDashboardData(
      userInfo: json['user_info'],
      patientProfile: json['patient_profile'],
      nextAppointment: json['next_appointment'] != null
          ? DashboardAppointment.fromJson(json['next_appointment'])
          : null,
      unreadMessagesCount: json['unread_messages_count'] ?? 0,
      newDocumentsCount: json['new_documents_count'] ?? 0,
      recentNotifications:
          (json['recent_notifications'] as List?)
              ?.map((e) => DashboardNotification.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DashboardAppointment {
  final int id;
  final String doctorName;
  final String specialty;
  final String date;
  final String status;

  DashboardAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.status,
  });

  factory DashboardAppointment.fromJson(Map<String, dynamic> json) {
    return DashboardAppointment(
      id: json['id'],
      doctorName: json['doctor_name'] ?? 'Inconnu',
      specialty: json['specialty'] ?? 'Général',
      date: json['date'],
      status: json['status'],
    );
  }
}

class DashboardNotification {
  final int id;
  final String title;
  final String message;
  final String date;
  final String type;

  DashboardNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
  });

  factory DashboardNotification.fromJson(Map<String, dynamic> json) {
    return DashboardNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'] ?? '',
      date: json['date'],
      type: json['type'] ?? 'INFO',
    );
  }
}
