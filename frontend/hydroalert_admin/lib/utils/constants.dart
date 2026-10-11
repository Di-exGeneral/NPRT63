/// Central configuration values used by the Flutter application.
class Constants {
  const Constants._();

  /// Override with `--dart-define=API_BASE_URL=http://localhost:8000` for local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hydroalert-api.fly.dev',
  );

  static const String adminRole = 'MunicipalAdmin';
}
