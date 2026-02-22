import 'package:abokamall/helpers/FirebaseUtilities.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/models/ServiceProviderDto.dart';
import 'package:abokamall/models/Subscription.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/screens/notifications_screen.dart';
import 'package:abokamall/screens/payment_webview_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/onboarding_screen.dart';
import 'package:abokamall/controllers/PresenceController.dart';
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
import 'screens/payment_success_screen.dart';
import 'screens/payment_failure_screen.dart';
import 'screens/subscription_status_screen.dart';
import 'screens/worker_register_screen.dart';
import 'screens/engineer_register_screen.dart';
import 'screens/company_register_screen.dart';
import 'screens/profile/profile_worker_screen.dart';
import 'screens/profile/profile_engineer_screen.dart';
import 'screens/profile/profile_company_screen.dart';
import 'screens/sculptor_register_screen.dart'; // Added import

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  /*
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Production mode
  );

  // Register a periodic task to check subscription daily
  Workmanager().registerPeriodicTask(
    "subscriptionCheckTask",
    checkSubscriptionTask,
    frequency: const Duration(hours: 24), // runs daily
    initialDelay: const Duration(minutes: 5), // first run delay
  );
  */
  // Initialize Hive first

  await Firebase.initializeApp();

  // 3️⃣ Register background handler BEFORE calling FirebaseUtilities.init()
  FirebaseMessaging.onBackgroundMessage(
    FirebaseUtilities.firebaseMessagingBackgroundHandler,
  );

  // 4️⃣ Initialize your notification system (permissions, channels, listeners)
  await FirebaseUtilities.init();

  // 5️⃣ Check for initial message if app was terminated
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    FirebaseUtilities.handleNotificationClick(initialMessage);
  }
  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  Hive.registerAdapter(ServiceProviderDtoAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ServiceProviderAdapter());

  // Open boxes
  if (!Hive.isBoxOpen('currentUserProfile')) {
    await Hive.openBox<UserProfile>('currentUserProfile');
  }
  await Hive.openBox<List<dynamic>>('serviceProviderBox');
  // Then set up service locator
  await setupServiceLocator();
  // Try to connect presence early (will return if no token yet)
  try {
    if (getIt.isRegistered<PresenceController>()) {
      getIt<PresenceController>().connect();
    }
  } catch (e) {
    debugPrint('Error connecting presence on startup: $e');
  }

  runApp(const MaakApp());
}

class MaakApp extends StatelessWidget {
  const MaakApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Cairo'),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
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
        '/notifications': (_) => const NotificationsScreen(),
        '/payment': (_) => const PaymentScreen(),
        '/payment_success': (_) => const PaymentSuccessScreen(),
        '/payment_failure': (_) => const PaymentFailureScreen(),
        '/subscription_status': (context) {
          return SubscriptionStatusScreen(
            userProfile:
                ModalRoute.of(context)!.settings.arguments as UserProfile,
          );
        },
        '/payment-webview': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return PaymentWebViewScreen(
            paymentLink: args['paymentLink'] as String,
            paymentId: args['paymentId'] as int,
          );
        },
        '/my_account': (_) => const ProfileSettingsPage(),
        '/register_worker': (_) => const WorkerRegisterScreen(),
        '/register_engineer': (_) => const EngineerRegisterScreen(),
        '/register_company': (_) => const CompanyRegisterScreen(),
        '/profile_worker': (_) => const WorkerProfileScreen(),
        '/profile_engineer': (_) => const EngineerProfileScreen(),
        '/profile_company': (_) => const CompanyProfileScreen(),
        '/register_sculptor': (_) =>
            const SculptorRegisterScreen(), // Added route
      },
    );
  }
}
