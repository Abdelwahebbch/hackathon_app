import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon_app/src/features/calculator/calculator_screen.dart';
import 'package:hackathon_app/src/features/calculator/test.dart';
import 'package:hackathon_app/src/middleware/app_route_observer.dart';
import 'package:hackathon_app/src/routing/global_navigator.dart';
import 'package:hackathon_app/src/routing/app_routes.dart';

import 'package:hackathon_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:hackathon_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:hackathon_app/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:hackathon_app/src/features/home/presentation/screens/home_page.dart';
import 'package:hackathon_app/src/features/onboarding/presentation/screens/onboarding_page.dart';

import 'package:hackathon_app/src/shared/widgets/ui/ui_showcase_screen.dart';
import 'package:flutter/foundation.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  observers: <NavigatorObserver>[AppRouteObserver()],
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const TestScreen(),
    ),
    GoRoute(
      path: AppRoutes.secretHome,
      name: 'secret home',
      builder: (context, state) =>
          CalculatorScreen(onsecretCode: () => context.pushReplacement(AppRoutes.home)),
    ),
    if (kDebugMode)
      GoRoute(
        path: AppRoutes.uiShowcase,
        name: 'uiShowcase',
        builder: (context, state) => const UiShowcaseScreen(),
      ),
  ],
);
