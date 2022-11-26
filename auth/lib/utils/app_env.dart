import 'dart:io';

abstract class AppEnv {
  AppEnv._();

  static final String secretKey =
      Platform.environment["SECRET_KEY"] ?? "";

  static final String port = Platform.environment['PORT'] ?? '';

  static final String db_username =
      Platform.environment['DB_USERNAME'] ?? '';
  static final String db_password =
      Platform.environment['DB_PASSWORD'] ?? '';
  static final String db_host = Platform.environment['DB_HOST'] ?? '';
  static final String db_port = Platform.environment['DB_PORT'] ?? '';
  static final String db_databaseName =
      Platform.environment['DB_NAME'] ?? '';
}
