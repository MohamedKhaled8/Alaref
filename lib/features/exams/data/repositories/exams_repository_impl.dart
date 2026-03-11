import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/data/datasources/exams_remote_datasource.dart';
import 'package:alaref/features/exams/domain/repositories/exams_repository.dart';
import 'package:dartz/dartz.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource dataSource;

  ExamsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ExamModel>>> getAllExams() async {
    try {
      final exams = await dataSource.getAllExams();
      return Right(exams);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getStudentResults() async {
    try {
      final results = await dataSource.getStudentResults();
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
