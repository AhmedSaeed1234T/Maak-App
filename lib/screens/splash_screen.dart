import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  final Color primary = const Color(0xFF13A9F6);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _handleStartupFlow());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _isConnected() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _handleStartupFlow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (isFirstLaunch) {
        await prefs.clear(); // Delete all the previous saints

        await prefs.setBool('is_first_launch', false);
        Navigator.pushReplacementNamed(context, '/onboarding');
        return;
      }

      // Network check
      final hasNet = await _isConnected();
      final tokenService = getIt<TokenService>();
      if (!hasNet) {
        // Offline!
        final isLocallyValid = await tokenService.isRefreshTokenLocallyValid();
        if (isLocallyValid) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("تعذر الاتصال بالخادم")));
        }
        return;
      }
      // Online flow - just try to refresh as before
      debugPrint("I'm attempting refreshing wait");
      final refreshed = await tokenService.refreshAccessToken();
      if (!mounted) return;
      if (refreshed) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final isLocallyValid = await tokenService.isRefreshTokenLocallyValid();
        if (isLocallyValid) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e, stack) {
      debugPrint('Splash flow failed: $e');
      debugPrint(stack.toString());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handshake,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'معاك',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نقوم بالتحقق من حسابك وتحديث الجلسة الحالية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: Color(0xFF13A9F6)),
                const SizedBox(height: 16),
                const Text(
                  'يرجى الانتظار لحظات...',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
