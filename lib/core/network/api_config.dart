import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Server port and path configuration:
  /// TechKart Core PHP server runs via PHP built-in server (`php -S 127.0.0.1:8000 -t public`)
  /// on port 8000 serving API endpoints under `/api/v1`.
  /// Alternatively, Apache XAMPP default port 80 serves `/techkart_backend/public/api/v1`.
  static const int phpBuiltInPort = 8000;
  static const int apachePort = 80;

  /// Default local development base URLs:
  /// - Web / iOS Simulator / Desktop / Windows loopback: 127.0.0.1:8000
  /// - Android (via adb reverse tcp:8000 tcp:8000 or physical loopback): 127.0.0.1:8000
  /// - Host LAN fallback: 192.168.31.246:8000
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:$phpBuiltInPort/api/v1';
    }
    if (Platform.isAndroid) {
      // 127.0.0.1 routes seamlessly to host via `adb reverse tcp:8000 tcp:8000`
      return 'http://127.0.0.1:$phpBuiltInPort/api/v1';
    }
    return 'http://127.0.0.1:$phpBuiltInPort/api/v1';
  }

  /// Active base URL. Can be reassigned at startup or runtime (e.g., custom LAN IP).
  static String baseUrl = defaultBaseUrl;

  /// Separate connection and response timeout durations:
  /// - connectTimeout: TCP socket connection establishment limit
  /// - responseTimeout: Server processing & data stream reception limit
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration responseTimeout = Duration(seconds: 25);
}
