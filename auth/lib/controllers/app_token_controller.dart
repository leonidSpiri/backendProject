import 'dart:async';
import 'dart:io';
import 'package:auth/utils/app_env.dart';
import 'package:auth/utils/app_response.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../models/user_data.dart';
import '../utils/app_utils.dart';

class AppTokenController extends Controller {
  final ManagedContext managedContext;

  AppTokenController(this.managedContext);

  @override
  FutureOr<RequestOrResponse?> handle(Request request) async {
    try {
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      final token = AuthorizationBearerParser().parse(header);
      final id = AppUtils.getIdFromToken(token!);
      final queryFindUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id);
      final findUser = await queryFindUser.fetchOne();
      if (findUser?.accessToken != token)
        return AppResponse.unauthorized(
            error: "Unauthorized", message: "Token is invalid!");
      if (findUser == null)
        return AppResponse.badRequest(
            error: "Bad Request", message: "User not found!");


      final jwtClaim = verifyJwtHS256Signature(token, AppEnv.secretKey);
      jwtClaim.validate();
      return request;
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
}
