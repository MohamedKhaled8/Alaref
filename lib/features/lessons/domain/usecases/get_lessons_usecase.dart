import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import '../repositories/lessons_repository.dart';

class GetLessonsUseCase {
  final LessonsRepository repository;

  GetLessonsUseCase({required this.repository});

  Stream<List<LessonModel>> call(String stage) {
    return repository.getLessons(stage);
  }
}
