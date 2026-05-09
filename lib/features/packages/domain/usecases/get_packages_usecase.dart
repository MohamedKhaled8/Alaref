import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import '../repositories/packages_repository.dart';

class GetPackagesUseCase {
  final PackagesRepository repository;

  GetPackagesUseCase({required this.repository});

  Stream<List<LessonModel>> call(String stage) {
    return repository.getPackages(stage);
  }
}
