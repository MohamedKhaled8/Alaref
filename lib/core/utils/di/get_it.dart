// lib/core/di/injection_container.dart
import 'package:alaref/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:alaref/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:alaref/features/auth/domain/repositories/auth_repository.dart';
import 'package:alaref/features/auth/domain/usecases/login_usecase.dart';
import 'package:alaref/features/auth/domain/usecases/register_usecase.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';
import 'package:alaref/features/admin/dashBoard/presentation/cubit/dashboard_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Cubit

// sl = Service Locator = المكان اللي بيجمع كل الـ dependencies
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ==============================
  // 🔵 Firebase - External
  // ==============================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ==============================
  // 🟡 DataSource - Data Layer
  // ==============================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // ==============================
  // 🟠 Repository - Data Layer
  // ==============================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // ==============================
  // 🟢 UseCases - Domain Layer
  // ==============================
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));

  // ==============================
  // 🔴 Cubit - Presentation Layer
  // ==============================
  sl.registerFactory(
    () => AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
  );

  // ==============================
  // 🟣 Dashboard Cubit
  // ==============================
  sl.registerFactory(() => DashboardCubit(firestore: sl()));
}
