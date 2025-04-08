import 'package:doantotnghiep/presentation/pages/auth/auth.dart';
import 'package:doantotnghiep/presentation/pages/auth/forget_password.dart';
import 'package:doantotnghiep/presentation/pages/auth/register.dart';
import 'package:doantotnghiep/presentation/pages/document_reader.dart';
import 'package:doantotnghiep/presentation/pages/local_file.dart';
import 'package:doantotnghiep/presentation/pages/support.dart';
import 'package:doantotnghiep/presentation/pages/entrypoint.dart';
import 'package:doantotnghiep/presentation/pages/library.dart';
import 'package:doantotnghiep/presentation/pages/auth/login.dart';
import 'package:doantotnghiep/presentation/pages/setting.dart';
import 'package:doantotnghiep/presentation/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const Auth(),
    ),
    GoRoute(
      path: '/entrypoint',
      builder: (context, state) => const AppEntryPoint(),
    ),
    // GoRoute(
    //   path: '/onboarding',
    //   builder: (context, state) => const OnboardingPage(),
    // ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportPage(),
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => const Setting(),
    ),
    GoRoute(
      path: '/storage',
      builder: (context, state) => const FilePickerPage(

      ),
    ),
    GoRoute(
      path: '/reader/:id',
      builder: (BuildContext context, GoRouterState state) {
        final documentId = state.pathParameters['id'];
        return DocumentReaderPage(documentId: documentId.toString());
      },
    ),
    // GoRoute(
    //   path: '/search',
    //   builder: (context, state) => const CustomSearch(),
    // ),
    // GoRoute(
    //   path: '/help',
    //   builder: (context, state) => const HelpCenterPage(),
    // ),
    // GoRoute(
    //   path: '/orders',
    //   builder: (context, state) => const OrdersPage(),
    // ),


    // GoRoute(
    //   path: '/login',
    //   builder: (context, state) => const LoginScreen(),
    // ),
    // GoRoute(
    //   path: '/register',
    //   builder: (context, state) => const RegisterScreen(),
    // ),
    // GoRoute(
    //   path: '/forget_pass',
    //   builder: (context, state) => const ForgetPasswordScreen(),
    // ),

    
    // GoRoute(
    //   path: '/categories',
    //   builder: (context, state) => const CategoriesPage(),
    // ),
    // GoRoute(
    //   path: '/category',
    //   builder: (context, state) => const CategoryDetail(),
    // ),
    //
    //
    // GoRoute(
    //   path: '/addaddress',
    //   builder: (context, state) => const AddAddress(),
    // ),
    //
    // GoRoute(
    //   path: '/addresses',
    //   builder: (context, state) => const AddressesListPage(),
    // ),
    //
    // GoRoute(
    //   path: '/notifications',
    //   builder: (context, state) => const NotificationPage(),
    // ),
    //
    //  GoRoute(
    //   path: '/tracking',
    //   builder: (context, state) => const TrackOrderPage(),
    // ),
    //
    // GoRoute(
    //   path: '/checkout',
    //   builder: (context, state) => const CheckoutPage(),
    // ),
    //
    //   GoRoute(
    //   path: '/successful',
    //   builder: (context, state) => const SuccessfulPayment(),
    // ),
    //
    //   GoRoute(
    //   path: '/failed',
    //   builder: (context, state) => const FailedPayment(),
    // ),
    //
    // GoRoute(
    //   path: '/product/:id',
    //   builder: (BuildContext context, GoRouterState state) {
    //     final productId = state.pathParameters['id'];
    //     return ProductPage(productId: productId.toString());
    //   },
    // ),
  ],
);

GoRouter get router => _router;