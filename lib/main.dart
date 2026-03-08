import 'package:alaref/alaref_app.dart';
import 'package:alaref/core/Router/app_router.dart';
import 'package:alaref/core/utils/di/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initDependencies();
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: AlArefApp(appRouter: AppRouter()),
    ),
  );
}
