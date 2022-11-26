import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../models/response_model.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getErrorResponseModel(error, message));

  AppResponse.ok({dynamic body, String? message})
      : super.ok(MyResponseModel(data: body, message: message));

  AppResponse.badRequest({dynamic error, String? message})
      : super.badRequest(
            body: MyResponseModel(error: error.toString(), message: message));

  AppResponse.unauthorized({dynamic error, String? message})
      : super.unauthorized(
            body: MyResponseModel(error: error.toString(), message: message));

  static MyResponseModel _getErrorResponseModel(error, String? message) {
    if (error is QueryException)
      return MyResponseModel(
          error: error.toString(), message: message ?? error.message);
    if (error is JwtException)
      return MyResponseModel(
          error: error.toString(), message: message ?? error.message);
    return MyResponseModel(error: error.toString(), message: "Unknown error");
  }
}
