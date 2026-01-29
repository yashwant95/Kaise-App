class AppConfig {
  // API Base URL
  // Change this to your backend URL
  // For Android Emulator: use 10.0.2.2 instead of localhost
  // For iOS Simulator: use localhost
  // For real device: use your computer's IP address or deployed backend URL
  static const String apiBaseUrl =
      'https://q0c22gpw-5000.inc1.devtunnels.ms/api';

  // App Name
  static const String appName = 'Kaise';

  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 15);
}
