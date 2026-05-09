import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

abstract class LessonsRepository {
  Stream<List<LessonModel>> getLessons(String stage);
}
