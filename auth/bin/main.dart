import 'dart:io';
import 'package:backendProject/auth.dart';
import 'package:conduit/conduit.dart';

void main() async {
  final int port = int.parse(Platform.environment['PORT'] ?? '8080');
  final service = Application<AppService>()..options.port = port;
  // ..options.configurationFilePath = 'config.yaml'
  // ..options.address = InternetAddress.anyIPv4;
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
