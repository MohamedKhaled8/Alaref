import 'package:alaref/core/utils/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String parentPhone;
  final AcademicStage stage;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.parentPhone,
    required this.stage,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase({required AuthRepository repository})
    : _repository = repository;

  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
      parentPhone: params.parentPhone,
      stage: params.stage,
    );
  }
}
