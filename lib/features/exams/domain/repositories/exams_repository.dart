import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:dartz/dartz.dart';
import 'package:alaref/core/utils/error/failures.dart';

/// Repository abstraction — domain layer
abstract class ExamsRepository {
  Future<Either<Failure, List<ExamModel>>> getAllExams();
  Future<Either<Failure, Map<String, int>>> getStudentResults();
}
