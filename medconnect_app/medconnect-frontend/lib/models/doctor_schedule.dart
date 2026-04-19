import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {
      'start_hour': start.hour,
      'start_minute': start.minute,
      'end_hour': end.hour,
      'end_minute': end.minute,
    };
  }

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(hour: json['start_hour'], minute: json['start_minute']),
      end: TimeOfDay(hour: json['end_hour'], minute: json['end_minute']),
    );
  }

  @override
  String toString() {
    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }
}

class DoctorSchedule {
  final int slotDurationMinutes;
  final Map<int, List<TimeRange>> workingHours; // 1 (Mon) to 7 (Sun)

  DoctorSchedule({
    this.slotDurationMinutes = 30,
    Map<int, List<TimeRange>>? workingHours,
  }) : workingHours = workingHours ?? {};

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> hoursJson = {};
    workingHours.forEach((key, value) {
      hoursJson[key.toString()] = value.map((e) => e.toJson()).toList();
    });

    return {
      'slotDurationMinutes': slotDurationMinutes,
      'workingHours': hoursJson,
    };
  }

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    final hoursJson = json['workingHours'] as Map<String, dynamic>? ?? {};
    final Map<int, List<TimeRange>> workingHours = {};

    hoursJson.forEach((key, value) {
      final list = (value as List).map((e) => TimeRange.fromJson(e)).toList();
      workingHours[int.parse(key)] = list;
    });

    return DoctorSchedule(
      slotDurationMinutes: json['slotDurationMinutes'] ?? 30,
      workingHours: workingHours,
    );
  }

  DoctorSchedule copyWith({
    int? slotDurationMinutes,
    Map<int, List<TimeRange>>? workingHours,
  }) {
    return DoctorSchedule(
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      workingHours: workingHours ?? Map.from(this.workingHours),
    );
  }
}
