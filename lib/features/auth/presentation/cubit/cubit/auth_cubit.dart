import 'package:alaref/core/Router/export_routes.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:alaref/features/auth/domain/usecases/login_usecase.dart';
import 'package:alaref/features/auth/domain/usecases/register_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       super(AuthInitial());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // القيمة الدراسية المختارة
  AcademicStage selectedStage = AcademicStage.primary;

  // حالة العين (إظهار/إخفاء الباسورد)
  bool isPasswordHidden = true;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    // بننبه الـ UI أن فيه تغيير حصل
    emit(AuthInitial());
  }

  void updateStage(AcademicStage stage) {
    selectedStage = stage;
    emit(AuthInitial());
  }

  // داله التحقق من البيانات (Validation)
  bool _validateRegister() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        parentPhoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      emit(const AuthError('برجاء ملء جميع الحقول'));
      return false;
    }

    return true;
  }

  bool _validateLogin() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      emit(const AuthError('برجاء إدخال البريد الإلكتروني وكلمة المرور'));
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!_validateLogin()) return;

    emit(AuthLoading());

    final result = await _loginUseCase(
      LoginParams(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> register() async {
    if (!_validateRegister()) return;

    emit(AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        parentPhone: parentPhoneController.text.trim(),
        stage: selectedStage,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    parentPhoneController.dispose();
    return super.close();
  }
}
