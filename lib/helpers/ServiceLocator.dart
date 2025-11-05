import 'package:abokamall/controllers/RegisterController.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<RegisterController>(() => RegisterController());
}
