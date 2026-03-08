import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error handler for Firebase Authentication and Firestore errors
class FirebaseErrorHandler {
  /// Maps Firebase Auth exceptions to user-friendly messages
  static String handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';

        case 'user-not-found':
          return 'لا يوجد حساب بهذا البريد الإلكتروني. يرجى التأكد من البريد أو إنشاء حساب جديد.';

        case 'email-already-in-use':
          return 'هذا البريد الإلكتروني مستخدم بالفعل. يرجى تسجيل الدخول أو استخدام بريد آخر.';

        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً. يرجى استخدام 6 أحرف على الأقل.';

        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';

        case 'user-disabled':
          return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني.';

        case 'too-many-requests':
          return 'محاولات تسجيل دخول كثيرة فاشلة. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.';

        case 'operation-not-allowed':
          return 'طريقة تسجيل الدخول هذه غير مفعلة.';

        case 'requires-recent-login':
          return 'هذه العملية تتطلب تسجيل دخول حديث. يرجى تسجيل الدخول مرة أخرى.';

        case 'invalid-credential':
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التأكد والمحاولة مرة أخرى.';

        case 'invalid-verification-code':
          return 'رمز التحقق غير صالح. يرجى طلب رمز جديد.';

        case 'invalid-verification-id':
          return 'معرف التحقق غير صالح. يرجى المحاولة مرة أخرى.';

        case 'session-expired':
          return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';

        case 'network-request-failed':
          return 'خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

        case 'internal-error':
          return 'حدث خطأ داخلي. يرجى المحاولة مرة أخرى لاحقاً.';

        default:
          return 'فشلت عملية المصادقة: ${error.message ?? error.code}. يرجى المحاولة مرة أخرى.';
      }
    }

    return _handleGenericError(error);
  }

  /// Maps Firestore exceptions to user-friendly messages
  static String handleFirestoreException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'الخدمة غير متاحة حالياً. تأكد من اتصالك بالإنترنت والمحاولة مرة أخرى.';

        case 'permission-denied':
          return 'ليس لديك صلاحية لإجراء هذه العملية. يرجى التواصل مع الدعم.';

        case 'not-found':
          return 'البيانات المطلوبة غير موجودة.';

        case 'already-exists':
          return 'هذا السجل موجود بالفعل.';

        case 'failed-precondition':
          return 'تم رفض العملية بسبب حالة النظام غير المستقرة.';

        case 'aborted':
          return 'تم إلغاء العملية. يرجى المحاولة مرة أخرى.';

        case 'out-of-range':
          return 'تمت محاولة العملية خارج النطاق الصالح.';

        case 'unimplemented':
          return 'هذه العملية غير متوفرة.';

        case 'deadline-exceeded':
          return 'انتهت مهلة العملية. يرجى التحقق من اتصالك بالإنترنت.';

        case 'resource-exhausted':
          return 'قلة موارد النظام. يرجى المحاولة لاحقاً.';

        case 'cancelled':
          return 'تم إلغاء العملية.';

        case 'data-loss':
          return 'حدث فقدان أو تلف للبيانات.';

        case 'unauthenticated':
          return 'الطلب لا يحتوي على بيانات مصادقة صحيحة.';

        case 'internal':
          return 'حدث خطأ داخلي. يرجى المحاولة مرة أخرى لاحقاً.';

        default:
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('connection') || errorStr.contains('channel')) {
            return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';
          }
          return 'خطأ في قاعدة البيانات: ${error.message ?? error.code}. يرجى المحاولة مرة أخرى.';
      }
    }

    return _handleGenericError(error);
  }

  /// Handles generic exceptions and network errors
  static String _handleGenericError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return 'خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }

    // Firestore unavailable errors
    if (errorString.contains('unavailable') ||
        errorString.contains('backend didn\'t respond') ||
        errorString.contains('could not reach')) {
      return 'تعذر الاتصال بالخادم. قد تكون الخدمة غير متاحة مؤقتاً. تأكد من اتصالك بالإنترنت.';
    }

    // Format errors
    if (errorString.contains('format') || errorString.contains('invalid')) {
      return 'تنسيق البيانات غير صالح. يرجى التحقق من إدخالك والمحاولة مرة أخرى.';
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'تم رفض الإذن. يرجى التواصل مع الدعم الفني إذا كنت تعتقد أن هذا خطأ.';
    }

    // Default fallback
    return 'حدث خطأ غير متوقع: ${error.toString()}. يرجى المحاولة أو التواصل مع الدعم الفني.';
  }

  /// Determines if an error is retryable (network issues, timeouts, etc.)
  static bool isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'network-request-failed' ||
          error.code == 'internal';
    }

    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed' ||
          error.code == 'internal-error';
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('unavailable') ||
        errorString.contains('connection');
  }

  /// Determines if the error indicates offline mode
  static bool isOfflineError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.message?.toLowerCase().contains('offline') == true;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('offline') ||
        errorString.contains('could not reach') ||
        errorString.contains('backend didn\'t respond');
  }

  /// Gets a user-friendly error message for any Firebase-related error
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthException(error);
    }

    if (error is FirebaseException) {
      return handleFirestoreException(error);
    }

    return _handleGenericError(error);
  }

  /// Logs error for debugging (can be extended to use a logging service)
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final errorMessage = getErrorMessage(error);
    print('❌ Firebase Error [${context ?? 'Unknown'}]: $errorMessage');
    print('   Original error: $error');
    if (stackTrace != null) {
      print('   Stack trace: $stackTrace');
    }
  }
}
