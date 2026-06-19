import 'package:cloud_firestore/cloud_firestore.dart';

import 'value_parser.dart';

/// Gemeinsame Formatter für Werte, die aus Firestore/Functions typisiert
/// oder als String zurückkommen können.
class AppFormatters {
  const AppFormatters._();

  static String duration(Object? value) {
    final totalSeconds = ValueParser.integer(value);

    if (totalSeconds <= 0) {
      return '-';
    }

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  static String distance(Object? value) {
    final distance = ValueParser.decimal(value);

    if (distance <= 0) {
      return '-';
    }

    if (distance >= 1000) {
      final km = distance / 1000;
      return '${km.toStringAsFixed(2)} km';
    }

    return '${distance.toStringAsFixed(0)} m';
  }

  static String shortDate(Object? value) {
    final date = parseDate(value);

    if (date == null) {
      return '';
    }

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  static DateTime? parseDate(Object? value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.tryParse(value.toString());
  }
}
