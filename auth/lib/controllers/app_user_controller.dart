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
      final token = AppUtils.getTokenFromHeader(header);
      if (user?.accessToken != token)
        return AppResponse.unauthorized(
            error: "Unauthorized", message: "Token is invalid");
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
      return AppResponse.ok(message: "Update profile success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Update profile failed");
    }
  }

  @Operation.put()
  Future<Response> updatePassword() async {
    try {
      return AppResponse.ok(message: "update password success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Update password failed");
    }
  }
}
