import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alaref/core/Router/app_router.dart';
import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:responsive_screen_master/config/responsive_master_config.dart';
import 'package:responsive_screen_master/responsive_master.dart';

class AlArefApp extends StatelessWidget {
  final AppRouter appRouter;
  const AlArefApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ResponsiveMaster(
      config: const ResponsiveMasterConfig(
        designWidth: 375,
        designHeight: 812,
        mobileBreakpoint: 600,
        tabletBreakpoint: 1100,
        enableCaching: true,
      ),
      builder: (BuildContext context, deviceInfo) {
        return MaterialApp(
          title: 'Edu Arabic App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: const Color(0xFF335EF7),
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF335EF7),
            ),
          ),
          initialRoute: FirebaseAuth.instance.currentUser != null
              ? Routes.bottomNavBar
              : Routes.registerPage,
          onGenerateRoute: appRouter.generateRoute,
        );
      },
    );
  }
}
