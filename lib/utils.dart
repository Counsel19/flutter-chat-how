import 'package:chat_how/firebase_options.dart';
import 'package:chat_how/services/alert_service.dart';
import 'package:chat_how/services/auth_service.dart';
import 'package:chat_how/services/database_service.dart';
import 'package:chat_how/services/media_service.dart';
import 'package:chat_how/services/naviagation_service.dart';
import 'package:chat_how/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerService() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<AuthService>(
    AuthService(),
  );

  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );

  getIt.registerSingleton<AlertService>(
    AlertService(),
  );

  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );

  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}

String generateChatId({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  return uids.fold("", (id, uid) => "$id$uid");
}
