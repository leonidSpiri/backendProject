import 'package:conduit/conduit.dart';

import '../utils/app_response.dart';

class AppPostController extends ResourceController {
  final ManagedContext managedContext;

  AppPostController(this.managedContext);

  @Operation.get()
  Future<Response> getPosts() async {
    try {
      /*final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);
      final token = AppUtils.getTokenFromHeader(header);
      if (user?.accessToken != token)
        return AppResponse.unauthorized(
            error: "Unauthorized", message: "Token is invalid");

      user?.removePropertiesFromBackingMap(
          [AppConst.accessToken, AppConst.refreshToken]);*/
      return AppResponse.ok(message: "get Posts success");
    } catch (error) {
      return AppResponse.serverError(error, message: "get Posts failed");
    }
  }
}
