import 'dart:io';

abstract class AppEnv {
  AppEnv._();

  static final String secretKey =
      Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";

  static final String port = Platform.environment['PORT'] ?? '6200';

  static final String db_username =
      Platform.environment['DB_USERNAME'] ?? 'admin';
  static final String db_password =
      Platform.environment['DB_PASSWORD'] ?? 'root';
  static final String db_host = Platform.environment['DB_HOST'] ?? 'localhost';
  static final String db_port = Platform.environment['DB_PORT'] ?? '6201';
  static final String db_databaseName =
      Platform.environment['DB_NAME'] ?? 'postgres';
}
