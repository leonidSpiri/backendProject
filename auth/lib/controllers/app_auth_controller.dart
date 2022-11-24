
import 'package:auth/models/response_model.dart';
import 'package:auth/models/user_data.dart';
import 'package:conduit/conduit.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.username == null || user.password == null)
      return Response.badRequest(
          body: MyResponseModel(error: "Username and password are required"));

    final fetchedUser = User();

    return Response.ok(
      MyResponseModel(data: {
        "id": fetchedUser.id,
        "refreshToken": fetchedUser.refreshToken,
        "accessToken": fetchedUser.accessToken,
      }, message: "User logged in successfully")
          .toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null)
      return Response.badRequest(
          body: MyResponseModel(
              error: "Username. password and Email are required"));

    final fetchedUser = User();

    return Response.ok(
      MyResponseModel(data: {
        "id": fetchedUser.id,
        "refreshToken": fetchedUser.refreshToken,
        "accessToken": fetchedUser.accessToken,
      }, message: "User sign up successfully")
          .toJson(),
    );
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
}
