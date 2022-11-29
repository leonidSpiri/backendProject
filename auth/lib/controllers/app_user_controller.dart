import 'dart:io';

import 'package:auth/utils/app_const.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../models/user_data.dart';
import '../utils/app_response.dart';

class AppUserController extends ResourceController {
  final ManagedContext managedContext;

  AppUserController(this.managedContext);

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);

      user?.removePropertiesFromBackingMap(
          [AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(
          body: user?.backing.contents, message: "Get profile success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Get profile failed");
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() User user) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final oldUser = await managedContext.fetchObjectWithID<User>(id);

      final queryUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.username = user.username ?? oldUser?.username
        ..values.email = user.email ?? oldUser?.email
        ..values.phone = user.phone ?? oldUser?.phone;

      final updatedUser = await queryUpdateUser.updateOne();
      updatedUser?.removePropertiesFromBackingMap(
          [AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(
          body: updatedUser?.backing.contents,
          message: "Update profile success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Update profile failed");
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.query("oldPassword") String oldPassword,
      @Bind.query("newPassword") String newPassword) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((table) => [
              table.salt,
              table.passwordHash,
              table.accessToken,
            ]);
      final findUser = await qFindUser.fetchOne();

      final oldPasswordHash =
          generatePasswordHash(oldPassword, findUser?.salt ?? "");
      if (oldPasswordHash != findUser?.passwordHash)
        return AppResponse.badRequest(
            error: "Bad request", message: "Old password is incorrect");
      final newPasswordHash =
          generatePasswordHash(newPassword, findUser?.salt ?? "");
      if (oldPasswordHash == newPasswordHash)
        return AppResponse.badRequest(
            error: "Bad request",
            message: "New password is the same as old password");
      final queryUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.passwordHash = newPasswordHash;
      final updatedUser = await queryUpdateUser.updateOne();
      return AppResponse.ok(
          message: "update password success",
          body: updatedUser?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Update password failed");
    }
  }
}
