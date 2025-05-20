import 'package:go_router/go_router.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:product_cart_flutter_training/presentation/pages/profile_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/',
      builder:
          (context, state) => const MyHomePage(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);
