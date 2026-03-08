// Params = البيانات اللي الـ UseCase محتاجها
// بنحطها في class منفصل عشان الكود يبقى نظيف

import 'package:alaref/core/utils/error/failures.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:alaref/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  // call() بيخلي الـ UseCase يتاستخدم زي function
  // LoginUseCase(params) بدل LoginUseCase.execute(params)
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}
