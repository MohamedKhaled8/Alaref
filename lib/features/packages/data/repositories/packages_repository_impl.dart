import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import '../../domain/repositories/packages_repository.dart';
import '../datasources/packages_remote_datasource.dart';

class PackagesRepositoryImpl implements PackagesRepository {
  final PackagesRemoteDataSource remoteDataSource;

  PackagesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<LessonModel>> getPackages(String stage) {
    return remoteDataSource.getPackages(stage);
  }
}
