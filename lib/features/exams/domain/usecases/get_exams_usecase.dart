import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/domain/repositories/exams_repository.dart';
import 'package:dartz/dartz.dart';

class GetExamsUseCase {
  final ExamsRepository repository;

  GetExamsUseCase({required this.repository});

  Future<Either<Failure, List<ExamModel>>> call() {
    return repository.getAllExams();
  }
}
