import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../datasources/lessons_remote_datasource.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource remoteDataSource;

  LessonsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<LessonModel>> getLessons(String stage) {
    return remoteDataSource.getLessons(stage);
  }
}
