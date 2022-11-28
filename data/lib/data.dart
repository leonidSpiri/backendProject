import 'package:conduit/conduit.dart';
import 'package:data/utils/app_env.dart';

import 'controllers/app_post_controller.dart';
import 'controllers/app_token_controller.dart';

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
    ..route("posts/[:id]")
        .link(() => AppTokenController())!
        .link(() => AppPostController(managedContext));

  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(AppEnv.db_username, AppEnv.db_password,
        AppEnv.db_host, int.tryParse(AppEnv.db_port), AppEnv.db_databaseName);
  }
}
