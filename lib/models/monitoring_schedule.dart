import 'package:flutter/material.dart';

class MonitoringSchedule {
  const MonitoringSchedule({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  factory MonitoringSchedule.defaults() {
    return const MonitoringSchedule(
      startHour: 8,
      startMinute: 0,
      endHour: 22,
      endMinute: 0,
    );
  }

  factory MonitoringSchedule.fromJson(Map<String, dynamic> json) {
    return MonitoringSchedule(
      startHour: json['startHour'] as int? ?? 8,
      startMinute: json['startMinute'] as int? ?? 0,
      endHour: json['endHour'] as int? ?? 22,
      endMinute: json['endMinute'] as int? ?? 0,
    );
  }

  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);

  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  int get startTotalMinutes => (startHour * 60) + startMinute;

  int get endTotalMinutes => (endHour * 60) + endMinute;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  MonitoringSchedule copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return MonitoringSchedule(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  bool contains(DateTime now) {
    final int currentMinutes = (now.hour * 60) + now.minute;

    // Matching start and end means "always on" for users who want 24-hour cover.
    if (startTotalMinutes == endTotalMinutes) {
      return true;
    }

    if (startTotalMinutes < endTotalMinutes) {
      return currentMinutes >= startTotalMinutes &&
          currentMinutes < endTotalMinutes;
    }

    return currentMinutes >= startTotalMinutes ||
        currentMinutes < endTotalMinutes;
  }
}
