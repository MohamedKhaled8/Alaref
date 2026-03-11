import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/home/data/datasources/course_details_remote_datasource.dart';
import 'package:alaref/features/home/domain/repositories/course_details_repository.dart';
import 'package:dartz/dartz.dart';

class CourseDetailsRepositoryImpl implements CourseDetailsRepository {
  final CourseDetailsRemoteDataSource dataSource;

  CourseDetailsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, bool>> checkUnlockStatus(
    String lessonId,
    double price,
  ) async {
    try {
      final result = await dataSource.checkUnlockStatus(lessonId, price);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ExamCheckResult>> checkExamStatus({
    required String examId,
    required String lessonId,
    required int minimumPassScore,
  }) async {
    try {
      final result = await dataSource.checkExamStatus(
        examId: examId,
        lessonId: lessonId,
        minimumPassScore: minimumPassScore,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, TeacherInfo>> loadTeacherInfo(String teacherId) async {
    try {
      final result = await dataSource.loadTeacherInfo(teacherId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> redeemCode({
    required String code,
    required String lessonId,
    required double lessonPrice,
  }) async {
    try {
      await dataSource.redeemCode(
        code: code,
        lessonId: lessonId,
        lessonPrice: lessonPrice,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> incrementStudentsCount(String lessonId) async {
    try {
      await dataSource.incrementStudentsCount(lessonId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitComment({
    required String lessonId,
    required String comment,
  }) async {
    try {
      await dataSource.submitComment(lessonId: lessonId, comment: comment);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ExamModel>> getExam(String examId) async {
    try {
      final result = await dataSource.getExam(examId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkIfPassedExam({
    required String examId,
    required int minimumPassScore,
  }) async {
    try {
      final result = await dataSource.checkIfPassedExam(
        examId: examId,
        minimumPassScore: minimumPassScore,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
