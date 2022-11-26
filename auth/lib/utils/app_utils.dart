import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"];
      final jwtClaim = verifyJwtHS256Signature(token, key ?? "SECRET_KEY");
      return int.parse(jwtClaim["id"].toString());
    } catch (e) {
      rethrow;
    }
  }

  static int getIdFromHeader(String header) {
    try {
      final token = AuthorizationBearerParser().parse(header);
      return getIdFromToken(token ?? "");
    } catch (e) {
      rethrow;
    }
  }

  static String getTokenFromHeader(String header) {
    try {
      return AuthorizationBearerParser().parse(header) ?? "";
    } catch (e) {
      rethrow;
    }
  }
}
