import 'package:flutter/material.dart';

import '../models/monitoring_schedule.dart';

class TimeUtils {
  const TimeUtils._();

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String greetingFor(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning';
    }
    if (now.hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  static String formatTimeOfDay(BuildContext context, TimeOfDay timeOfDay) {
    return timeOfDay.format(context);
  }

  static String formatSchedule(BuildContext context, MonitoringSchedule value) {
    final String start = formatTimeOfDay(context, value.startTime);
    final String end = formatTimeOfDay(context, value.endTime);
    return '$start - $end';
  }

  static String formatDateTime(DateTime value) {
    final String month = _months[value.month - 1];
    final String day = value.day.toString().padLeft(2, '0');
    final int hour12 = value.hour == 0
        ? 12
        : value.hour > 12
            ? value.hour - 12
            : value.hour;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String period = value.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $hour12:$minute $period';
  }
}
