import 'package:equatable/equatable.dart';

enum AcademicStage { primary, preparatory, secondary }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String parentPhone;
  final AcademicStage stage;
  final String studentCode;
  final String password;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.parentPhone,
    required this.stage,
    required this.studentCode,
    required this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    uid,
    name,
    email,
    phone,
    parentPhone,
    stage,
    password,
  ];
}
