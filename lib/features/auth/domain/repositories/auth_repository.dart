import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  // Either<Failure, UserEntity>
  // يعني: إما بترجع Failure (لو فيه مشكلة)
  //        أو بترجع UserEntity (لو نجح)
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String parentPhone,
    required AcademicStage stage,
  });
}
