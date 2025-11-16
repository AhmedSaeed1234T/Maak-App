import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/select_account_type_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_code_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/reset_success_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/filters_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/worker_register_screen.dart';
import 'screens/engineer_register_screen.dart';
import 'screens/company_register_screen.dart';
import 'screens/profile/profile_worker_screen.dart';
import 'screens/profile/profile_engineer_screen.dart';
import 'screens/profile/profile_company_screen.dart';
// ... يمكن إضافة بقية الشاشات لاحقاً

void main() {
  setupServiceLocator();
  runApp(const MaakApp());
}

class MaakApp extends StatelessWidget {
  const MaakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'), // Good practice to add English as a fallback
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // تأكد من إضافة الخط لو متوفر
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/select_account_type': (_) => const SelectAccountTypeScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/verify_code': (_) => const VerifyCodeScreen(),
        '/reset_password': (_) => const ChangePasswordScreen(),
        '/reset_success': (_) => const ResetSuccessScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/filters': (_) => const FiltersScreen(),
        '/search_results': (_) => const SearchResultsPage(
          firstName: '',
          lastName: '',
          specialization: '',
          governorate: '',
          city: '',
          district: '',
          workerType: null,
          providerType: null,
        ),
        '/settings': (_) => const ProfileSettingsPage(),
        '/payment': (_) => const PaymentScreen(),
        '/my_account': (_) => const ProfileSettingsPage(),
        '/register_worker': (_) => const WorkerRegisterScreen(),
        '/register_engineer': (_) => const EngineerRegisterScreen(),
        '/register_company': (_) => const CompanyRegisterScreen(),
        '/profile_worker': (_) => const WorkerProfileScreen(),
        '/profile_engineer': (_) => const EngineerProfileScreen(),
        '/profile_company': (_) => const CompanyProfileScreen(),
        // أضف بقية الشاشات هنا
      },
    );
  }
}
