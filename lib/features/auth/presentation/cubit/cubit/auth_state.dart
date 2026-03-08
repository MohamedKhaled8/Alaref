part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 🔵 الحالة الابتدائية — قبل ما يعمل أي حاجة
class AuthInitial extends AuthState {}

// ⏳ جاري التحميل — بنعرض Loading indicator
class AuthLoading extends AuthState {}

// ✅ نجح — جبنا الـ User
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// ❌ فشل — بنعرض رسالة الخطأ
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
