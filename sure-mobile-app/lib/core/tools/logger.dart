import 'dart:developer' as developer;

/// Log prefix constants for module-specific logging
/// Prefixed logs can be muted by adding to _mutedPrefixes set
abstract class LogPrefix {
  static const String database = '[DATABASE]';
  static const String network = '[NETWORK]';
  static const String auth = '[AUTH]';
  static const String navigation = '[NAVIGATION]';
  static const String storage = '[STORAGE]';
  static const String sync = '[SYNC]';
  static const String bluetooth = '[BLUETOOTH]';
  static const String camera = '[CAMERA]';
  static const String location = '[LOCATION]';
  static const String api = '[API]';
}

/// Centralized logging utility
/// ALWAYS use AppLogger instead of print() statements
class AppLogger {
  AppLogger._();

  /// Prefixes to mute (add prefixes here to silence verbose modules)
  static final Set<String> _mutedPrefixes = {};

  /// Add a prefix to mute
  static void mutePrefix(String prefix) {
    _mutedPrefixes.add(prefix);
  }

  /// Remove a prefix from mute list
  static void unmutePrefix(String prefix) {
    _mutedPrefixes.remove(prefix);
  }

  /// Log debug message (development debugging, detailed flow)
  static void debug(String message, {String? prefix}) {
    if (prefix != null && _mutedPrefixes.contains(prefix)) {
      return;
    }
    final formattedMessage = prefix != null ? '$prefix $message' : message;
    developer.log(formattedMessage, name: 'DEBUG');
  }

  /// Log info message (important operations, user actions)
  static void info(String message) {
    developer.log(message, name: 'INFO');
  }

  /// Log warning message
  static void warning(String message) {
    developer.log(message, name: 'WARNING');
  }

  /// Log error (MANDATORY in all catch blocks)
  static void error(Object error, [StackTrace? stackTrace]) {
    developer.log(
      error.toString(),
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
