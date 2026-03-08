abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
// ❌ مفيش إنترنت
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// ❌ الإيميل موجود قبل كده
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() 
    : super('هذا البريد الإلكتروني مستخدم بالفعل');
}

// ❌ إيميل أو باسورد غلط
class WrongCredentialsFailure extends Failure {
  const WrongCredentialsFailure() 
    : super('البريد الإلكتروني أو كلمة المرور غير صحيحة');
}

// ❌ أي خطأ تاني مش متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure() 
    : super('حدث خطأ غير متوقع، حاول مرة أخرى');
}