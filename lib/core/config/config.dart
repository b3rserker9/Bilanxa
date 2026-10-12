import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class Config {
  static const mockApi = bool.fromEnvironment('MOCK_API');
  static const mockAuth = bool.fromEnvironment('MOCK_AUTH');
  static bool get mocksAllowed => environment == 'local';
  static bool get mockConfigurationInvalid =>
      ((mockApi || mockAuth) && !mocksAllowed) || (mockAuth && !mockApi);
  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static void validateUrl() {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !['https', 'http'].contains(uri.scheme) ||
        (environment == 'production' && uri.scheme != 'https')) {
      throw StateError('API_BASE_URL');
    }
  }
}

final setupErrorProvider = Provider<String?>((ref) => null);
