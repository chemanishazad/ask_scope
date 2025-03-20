import 'package:flutter/material.dart';
import 'package:loop/screens/auth/login/login_screen.dart';
import 'package:loop/screens/auth/splash/splash_screen.dart';
import 'package:loop/screens/bottomNavigation/bottom_navigation.dart';
import 'package:loop/screens/home/details/addScope/add_new_scope.dart';
import 'package:loop/screens/home/details/details_query.dart';
import 'package:loop/screens/home/details/scope_card.dart';
import 'package:loop/screens/home/notification/notification_screen.dart';

class AppRoutes {
  static final Map<String, Widget Function(BuildContext)> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/bottomNavigation': (context) => const BottomNavigation(),
    '/notificationScreen': (context) => const NotificationScreen(),
    '/detailsQuery': (context) => const DetailsQuery(),
    '/scopeCard': (context) => const ScopeCard(),
    '/addNewScope': (context) => const AddNewScope(),
  };
}
