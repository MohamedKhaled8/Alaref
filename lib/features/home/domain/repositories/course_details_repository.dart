import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/home/data/datasources/course_details_remote_datasource.dart';
import 'package:dartz/dartz.dart';

/// Repository abstraction — domain layer
abstract class CourseDetailsRepository {
  Future<Either<Failure, bool>> checkUnlockStatus(
    String lessonId,
    double price,
  );

  Future<Either<Failure, ExamCheckResult>> checkExamStatus({
    required String examId,
    required String lessonId,
    required int minimumPassScore,
  });

  Future<Either<Failure, TeacherInfo>> loadTeacherInfo(String teacherId);

  Future<Either<Failure, void>> redeemCode({
    required String code,
    required String lessonId,
    required double lessonPrice,
  });

  Future<Either<Failure, void>> incrementStudentsCount(String lessonId);

  Future<Either<Failure, void>> submitComment({
    required String lessonId,
    required String comment,
  });

  Future<Either<Failure, ExamModel>> getExam(String examId);

  Future<Either<Failure, bool>> checkIfPassedExam({
    required String examId,
    required int minimumPassScore,
  });
}
