import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // بنطلب من الـ DataSource يعمل login
      final user = await _dataSource.login(email: email, password: password);

      // Right = نجاح — بنرجع الـ UserEntity
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Failure catch (failure) {
      // Left = فشل — بنرجع الـ Failure
      return Left(failure);
    } catch (e) {
      // أي exception تاني مش متوقع
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String parentPhone,
    required AcademicStage stage,
  }) async {
    try {
      final user = await _dataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        parentPhone: parentPhone,
        stage: stage,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        ServerFailure(e.toString()),
      ); // Return message temporarily to debug if it's not ServerException
    }
  }
}
