import 'package:flutter/foundation.dart';

enum AppEnvironment { dev, prod }

class EnvConfig {
  // Current active environment. By default, toggles dynamically based on
  // compilation mode: DEV for debug/local runs, PROD for profile/release.
  // Can be manually changed to AppEnvironment.prod for production testing.
  static const AppEnvironment environment = kDebugMode ? AppEnvironment.dev : AppEnvironment.prod;

  static String get baseUrl => baseURL;

  static String get baseURL {
    switch (environment) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:8000'; // Local FastAPI server on Android Emulator
      case AppEnvironment.prod:
        return 'https://akburak-spor-app.onrender.com'; // Live Render cloud backend URL
    }
  }

  static bool get isDev => environment == AppEnvironment.dev;
  static bool get isProd => environment == AppEnvironment.prod;
}
