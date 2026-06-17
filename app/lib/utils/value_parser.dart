class ValueParser {
  const ValueParser._();

  static String string(dynamic value) => value?.toString() ?? '';

  static int integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double decimal(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static bool boolean(dynamic value) => value == true;
}
