import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';                   
import 'features/auth/screens/get_started_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_step1_screen.dart';
import 'features/auth/screens/signup_step2_screen.dart';
import 'features/auth/screens/signup_step3_screen.dart';
import 'navigation/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  ApiClient.instance.initialize();                       

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(             
      child: LangGptApp(),
    ),
  );
}

class LangGptApp extends StatelessWidget {
  const LangGptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangGPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.getStarted,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.getStarted:
            return _fadeRoute(const GetStartedScreen(), settings);
          case AppRoutes.login:
            return _slideRoute(const LoginScreen(), settings);
          case AppRoutes.signup:
            return _slideRoute(const SignupStep1Screen(), settings);
          case AppRoutes.signupStep2:
            return _slideRoute(const SignupStep2Screen(), settings);
          case AppRoutes.signupStep3:
            return _slideRoute(const SignupStep3Screen(), settings);
          case AppRoutes.main:
            return _fadeRoute(const MainNavigation(), settings);
          default:
            return _fadeRoute(const GetStartedScreen(), settings);
        }
      },
    );
  }

  PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}