import 'package:abokamall/controllers/LoginController.dart';
import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/controllers/RegisterController.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<RegisterController>(() => RegisterController());
  getIt.registerLazySingleton<LoginController>(() => LoginController());
  getIt.registerLazySingleton<ProfileController>(() => ProfileController());
  getIt.registerSingleton<TokenService>(TokenService());
}
