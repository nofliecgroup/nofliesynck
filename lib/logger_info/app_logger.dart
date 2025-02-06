import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
// For the `Logger` package

class AppLogger {
  static late Logger _logger;

  // Initialize the logger
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
       // printTime: true,
      ),
    );
  }

  // Static method to log information
  static void logInfo(String message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  // Static method to log warnings
  static void logWarn(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  // Static method to log errors
  static void logError(String message) {
    if (kDebugMode) {
      _logger.e(message);
    }
  }

  // Static method to log debug messages
  static void logDebug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  // Static method to log exceptions with stack trace
  static void logException(Exception exception, StackTrace stackTrace) {
    if (kDebugMode) {
      _logger.e('Exception occurred', error: exception, stackTrace: stackTrace);
    }
  }
}
