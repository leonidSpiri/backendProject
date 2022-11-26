import 'package:auth/controllers/app_auth_controller.dart';
import 'package:auth/controllers/app_token_controller.dart';
import 'package:auth/utils/app_env.dart';
import 'package:conduit/conduit.dart';

import 'controllers/app_user_controller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);

    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route("token/[:refresh]").link(() => AppAuthController(managedContext))
    ..route("user")
        .link(() => AppTokenController())!
        .link(() => AppUserController(managedContext));

  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(AppEnv.db_username, AppEnv.db_password,
        AppEnv.db_host, int.tryParse(AppEnv.db_port), AppEnv.db_databaseName);
  }
}
