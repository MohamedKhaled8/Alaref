import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

abstract class PackagesRepository {
  Stream<List<LessonModel>> getPackages(String stage);
}
