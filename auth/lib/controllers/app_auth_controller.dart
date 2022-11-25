import 'dart:io';

import 'package:auth/models/response_model.dart';
import 'package:auth/models/user_data.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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
      if (findUser == null) throw QueryException.input("User not found", null);

      final hashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");

      if (hashPassword != findUser.passwordHash)
        throw QueryException.input("Password is incorrect", null);

      await _updateTokens(findUser.id ?? -1, managedContext);
      final updatedUser =
          await managedContext.fetchObjectWithID<User>(findUser.id);

      return Response.ok(MyResponseModel(
          data: updatedUser?.backing.contents, message: "Login success"));
    } on QueryException catch (error) {
      return Response.serverError(body: MyResponseModel(error: error.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null)
      return Response.badRequest(
          body: MyResponseModel(
              error: "Username. password and Email are required"));

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
      return Response.ok(MyResponseModel(
              data: userData?.backing.contents,
              message: "Successfully register")
          .toJson());
    } on QueryException catch (error) {
      return Response.serverError(body: MyResponseModel(error: error.message));
    }
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    final fetchedUser = User();

    return Response.ok(
      MyResponseModel(data: {
        "id": fetchedUser.id,
        "refreshToken": fetchedUser.refreshToken,
        "accessToken": fetchedUser.accessToken,
      }, message: "Successfully refreshed token")
          .toJson(),
    );
  }

  _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"]
      ..where((user) => user.id).equalTo(id);
    await qUpdateTokens.updateOne();
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
    final accessClaimSet = JwtClaim(
      maxAge: Duration(hours: 1),
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
