import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/exams/domain/repositories/exams_repository.dart';
import 'package:dartz/dartz.dart';

class GetStudentResultsUseCase {
  final ExamsRepository repository;

  GetStudentResultsUseCase({required this.repository});

  Future<Either<Failure, Map<String, int>>> call() {
    return repository.getStudentResults();
  }
}
