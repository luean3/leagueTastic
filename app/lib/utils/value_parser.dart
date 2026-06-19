/// Converts loosely typed Firestore and callable-function values into the
/// primitive types used by the domain models.
class ValueParser {
  const ValueParser._();

  static String string(Object? value) => value?.toString() ?? '';

  static int integer(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Parses an integer while preserving a missing value as `null`.
  static int? nullableInteger(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double decimal(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Parses a decimal while preserving a missing value as `null`.
  static double? nullableDecimal(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool boolean(Object? value) => value == true;
}
