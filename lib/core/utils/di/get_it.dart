// lib/core/di/injection_container.dart
import 'package:alaref/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:alaref/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:alaref/features/auth/domain/repositories/auth_repository.dart';
import 'package:alaref/features/auth/domain/usecases/login_usecase.dart';
import 'package:alaref/features/auth/domain/usecases/register_usecase.dart';
import 'package:alaref/features/auth/presentation/cubit/cubit/auth_cubit.dart';
import 'package:alaref/features/admin/dashBoard/presentation/cubit/dashboard_cubit.dart';
import 'package:alaref/features/home/presentation/cubit/home_cubit.dart';
import 'package:alaref/features/packages/data/datasources/packages_remote_datasource.dart';
import 'package:alaref/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:alaref/features/packages/domain/repositories/packages_repository.dart';
import 'package:alaref/features/packages/domain/usecases/get_packages_usecase.dart';
import 'package:alaref/features/packages/presentation/manager/packages_cubit.dart';
import 'package:alaref/features/lessons/data/datasources/lessons_remote_datasource.dart';
import 'package:alaref/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:alaref/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:alaref/features/lessons/domain/usecases/get_lessons_usecase.dart';
import 'package:alaref/features/lessons/presentation/manager/lessons_cubit.dart';
import 'package:alaref/features/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:alaref/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:alaref/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:alaref/features/sessions/domain/usecases/get_recent_sessions_usecase.dart';
import 'package:alaref/features/sessions/domain/usecases/record_session_usecase.dart';
import 'package:alaref/features/sessions/presentation/manager/sessions_cubit.dart';
import 'package:alaref/core/utils/services/user_stage_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// sl = Service Locator = المكان اللي بيجمع كل الـ dependencies
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ==============================
  // 🔵 Firebase - External
  // ==============================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ==============================
  // 🔵 Core Services
  // ==============================
  sl.registerLazySingleton(
    () => UserStageProvider(auth: sl(), firestore: sl()),
  );

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

  // ==============================
  // 🟢 Home
  // ==============================
  sl.registerFactory(() => HomeCubit(userStageProvider: sl()));

  // ==============================
  // 📦 Packages (Clean Arch)
  // ==============================
  sl.registerLazySingleton<PackagesRemoteDataSource>(
    () => PackagesRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<PackagesRepository>(
    () => PackagesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetPackagesUseCase(repository: sl()));
  sl.registerFactory(
    () => PackagesCubit(getPackagesUseCase: sl(), userStageProvider: sl()),
  );

  // ==============================
  // 📚 Lessons (Clean Arch)
  // ==============================
  sl.registerLazySingleton<LessonsRemoteDataSource>(
    () => LessonsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<LessonsRepository>(
    () => LessonsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetLessonsUseCase(repository: sl()));
  sl.registerFactory(
    () => LessonsCubit(getLessonsUseCase: sl(), userStageProvider: sl()),
  );

  // ==============================
  // 📝 Sessions (Clean Arch)
  // ==============================
  sl.registerLazySingleton<SessionsRemoteDataSource>(
    () => SessionsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<SessionsRepository>(
    () => SessionsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetRecentSessionsUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordSessionUseCase(repository: sl()));
  sl.registerFactory(
    () => SessionsCubit(
      getRecentSessionsUseCase: sl(),
      recordSessionUseCase: sl(),
      userStageProvider: sl(),
    ),
  );
}
