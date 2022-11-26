import 'dart:io';

abstract class AppConst {
  AppConst._();

  static final String secretKey =
      Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";

  static const accessToken = "accessToken";
  static const refreshToken = "refreshToken";
}
