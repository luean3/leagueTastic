import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  // Privater Konstruktor für das Singleton-Muster
  AppLogger._internal();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,       // Wie viele Methoden im Stacktrace angezeigt werden
      errorMethodCount: 8,  // Stacktrace-Tiefe bei Fehlern
      lineLength: 120,      // Breite der Trennlinien
      colors: true,         // Farben im Terminal (funktioniert meistens)
      printEmojis: true,    // Emojis für die verschiedenen Level
      printTime: true,      // Zeitstempel hinzufügen
    ),
    // Im Release-Modus loggen wir nichts
    filter: DevelopmentFilter(),
  );

  // Log-Methoden für verschiedene Situationen

  /// Für allgemeine Informationen
  static void i(String message) => _logger.i(message);

  /// Für Debug-Ausgaben während der Entwicklung
  static void d(String message) => _logger.d(message);

  /// Warnungen (wenn etwas nicht ideal läuft, aber die App nicht abstürzt)
  static void w(String message) => _logger.w(message);

  /// Fehler-Logging mit optionalem Error-Objekt und Stacktrace
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// "What a Terrible Failure" - für absolut kritische Fehler
  static void wtf(String message) => _logger.f(message);
}

/// Filter, der sicherstellt, dass nur im Debug-Modus geloggt wird
class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode; // kDebugMode kommt aus flutter/foundation.dart
  }
}