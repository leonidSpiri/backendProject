import 'package:auth/models/response_model.dart';
import 'package:auth/models/user_data.dart';
import 'package:auth/utils/app_env.dart';
import 'package:auth/utils/app_response.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../utils/app_utils.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.username == null || user.password == null)
      return Response.badRequest(
          body: MyResponseModel(error: "Username and password are required"));

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties((table) => [
              table.id,
              table.salt,
              table.passwordHash,
            ]);

      final findUser = await qFindUser.fetchOne();
      if (findUser == null)
        return AppResponse.badRequest(
            error: "Bad Request", message: "User not found");

      final hashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");

      if (hashPassword != findUser.passwordHash)
        return AppResponse.badRequest(
            error: "Bad Request", message: "Wrong password");

      await _updateTokens(findUser.id ?? -1, managedContext);
      final updatedUser =
          await managedContext.fetchObjectWithID<User>(findUser.id);
      return AppResponse.ok(
          body: updatedUser?.backing.contents, message: "Login success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Login failed");
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null)
      return AppResponse.badRequest(
          error: "Register failed",
          message: "Username. password and Email are required");

    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.phone = user.phone
          ..values.passwordHash = hashPassword
          ..values.salt = salt
          ..values.refreshToken = generateRandomSalt()
          ..values.accessToken = generateRandomSalt();

        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"] as int;
        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
          body: userData?.backing.contents, message: "Register success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Register failed");
    }
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken)
        return AppResponse.unauthorized(
            error: "Unauthorized", message: "Invalid refresh token");
      await _updateTokens(id, managedContext);
      final updatedUser = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
          body: updatedUser?.backing.contents, message: "Refresh success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Refresh failed");
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"]
      ..where((user) => user.id).equalTo(id);
    await qUpdateTokens.updateOne();
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = AppEnv.secretKey;
    final accessClaimSet = JwtClaim(
      maxAge: Duration(days: 10),
      otherClaims: {"id": id},
    );
    final refreshClaimSet = JwtClaim(
      otherClaims: {"id": id},
    );
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
