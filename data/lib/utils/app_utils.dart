import 'package:conduit/conduit.dart';
import 'package:data/utils/app_env.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final jwtClaim = verifyJwtHS256Signature(token, AppEnv.secretKey);
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
