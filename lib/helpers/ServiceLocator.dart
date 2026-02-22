import 'package:abokamall/controllers/ChatController.dart';
import 'package:abokamall/controllers/LoginController.dart';
import 'package:abokamall/controllers/NotificationController.dart';
import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/controllers/RegisterController.dart';
import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/services/ProfileCacheService.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<RegisterController>(() => RegisterController());
  getIt.registerLazySingleton<LoginController>(() => LoginController());
  getIt.registerLazySingleton<ProfileController>(() => ProfileController());
  getIt.registerSingleton<TokenService>(TokenService());
  getIt.registerLazySingleton<searchcontroller>(() => searchcontroller());
  getIt.registerSingleton<ProfileCacheService>(ProfileCacheService());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<TokenService>()),
  );
  final userListCacheService = await UserListCacheService.create();
  getIt.registerSingleton<UserListCacheService>(userListCacheService);
  getIt.registerLazySingleton<ChatController>(() => ChatController());
  getIt.registerLazySingleton<PresenceController>(() => PresenceController());
  getIt.registerLazySingleton<NotificationController>(() => NotificationController());
}
