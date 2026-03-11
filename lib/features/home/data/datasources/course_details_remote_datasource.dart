import 'package:alaref/core/utils/error/firebase_error_handler.dart';
import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// DataSource بيتعامل مع Firebase مباشرة لتفاصيل الكورس
abstract class CourseDetailsRemoteDataSource {
  /// فحص هل الحصة مفتوحة (مجانية أو مشتراة)
  Future<bool> checkUnlockStatus(String lessonId, double price);

  /// فحص حالة الامتحان القبلي
  Future<ExamCheckResult> checkExamStatus({
    required String examId,
    required String lessonId,
    required int minimumPassScore,
  });

  /// جلب معلومات المدرس
  Future<TeacherInfo> loadTeacherInfo(String teacherId);

  /// التحقق من كود الدفع وتفعيل الاشتراك
  Future<void> redeemCode({
    required String code,
    required String lessonId,
    required double lessonPrice,
  });

  /// زيادة عدد الطلاب
  Future<void> incrementStudentsCount(String lessonId);

  /// إرسال تعليق
  Future<void> submitComment({
    required String lessonId,
    required String comment,
  });

  /// جلب بيانات الامتحان
  Future<ExamModel> getExam(String examId);

  /// فحص هل الطالب اجتاز الامتحان
  Future<bool> checkIfPassedExam({
    required String examId,
    required int minimumPassScore,
  });
}

class CourseDetailsRemoteDataSourceImpl
    implements CourseDetailsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CourseDetailsRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<bool> checkUnlockStatus(String lessonId, double price) async {
    try {
      if (price == 0) return true;

      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) return false;

      final userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final purchasedLessons = List<String>.from(
          data['purchasedLessons'] ?? [],
        );
        return purchasedLessons.contains(lessonId);
      }
      return false;
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<ExamCheckResult> checkExamStatus({
    required String examId,
    required String lessonId,
    required int minimumPassScore,
  }) async {
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return ExamCheckResult(passed: false, cooldownUntil: null);
      }

      final resultsSnap = await firestore
          .collection('exam_results')
          .where('examId', isEqualTo: examId)
          .where('studentId', isEqualTo: uid)
          .get();

      bool passed = false;
      DateTime? lastSubmission;

      final sortedDocs = resultsSnap.docs.toList();
      if (sortedDocs.isNotEmpty) {
        sortedDocs.sort((a, b) {
          final t1 = a.data()['submittedAt'] as Timestamp?;
          final t2 = b.data()['submittedAt'] as Timestamp?;
          if (t1 == null && t2 == null) return 0;
          if (t1 == null) return 1;
          if (t2 == null) return -1;
          return t2.compareTo(t1);
        });

        for (var doc in sortedDocs) {
          final data = doc.data();
          final score = data['score'] ?? 0;
          final totalGrade = data['totalGrade'] ?? 1;
          final pct = (score / totalGrade) * 100;
          if (pct >= minimumPassScore) {
            passed = true;
            break;
          }
        }

        if (!passed) {
          final lastDocData = sortedDocs.first.data();
          if (lastDocData['submittedAt'] != null) {
            lastSubmission = (lastDocData['submittedAt'] as Timestamp).toDate();
          }
        }
      }

      DateTime? nextRetake;
      if (!passed && lastSubmission != null) {
        final examDoc = await firestore.collection('exams').doc(examId).get();
        if (examDoc.exists) {
          final cd = examDoc.data()?['retakeCooldownSeconds'] ?? 0;
          if (cd > 0) {
            final possibleRetake = lastSubmission.add(Duration(seconds: cd));
            if (possibleRetake.isAfter(DateTime.now())) {
              nextRetake = possibleRetake;
            }
          }
        }
      }

      return ExamCheckResult(passed: passed, cooldownUntil: nextRetake);
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<TeacherInfo> loadTeacherInfo(String teacherId) async {
    try {
      if (teacherId.isEmpty) {
        return TeacherInfo(imageUrl: '', subject: '');
      }
      final teacherDoc = await firestore
          .collection('teachers')
          .doc(teacherId)
          .get();
      if (teacherDoc.exists) {
        final data = teacherDoc.data()!;
        return TeacherInfo(
          imageUrl: data['imageUrl'] ?? '',
          subject: data['subject'] ?? '',
        );
      }
      return TeacherInfo(imageUrl: '', subject: '');
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> redeemCode({
    required String code,
    required String lessonId,
    required double lessonPrice,
  }) async {
    try {
      final codesSnapshot = await firestore
          .collection('codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (codesSnapshot.docs.isEmpty) {
        throw ServerException('الكود غير صحيح');
      }

      final codeDoc = codesSnapshot.docs.first;
      final codeData = codeDoc.data();

      if (codeData['isUsed'] == true) {
        throw ServerException('هذا الكود مستخدم من قبل');
      }

      final codeValue = (codeData['value'] as num).toDouble();
      if (codeValue != lessonPrice) {
        throw ServerException(
          'قيمة الكود (${codeValue.toStringAsFixed(0)}) لا تطابق سعر الحصة (${lessonPrice.toStringAsFixed(0)})',
        );
      }

      // Mark code as used
      await firestore.collection('codes').doc(codeDoc.id).update({
        'isUsed': true,
        'usedBy': firebaseAuth.currentUser?.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Add lesson to user purchased array
      final uid = firebaseAuth.currentUser?.uid;
      if (uid != null) {
        await firestore.collection('users').doc(uid).update({
          'purchasedLessons': FieldValue.arrayUnion([lessonId]),
        });
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> incrementStudentsCount(String lessonId) async {
    try {
      await firestore.collection('lessons').doc(lessonId).update({
        'studentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> submitComment({
    required String lessonId,
    required String comment,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('يجب تسجيل الدخول أولاً');
      }

      String userName = user.displayName ?? 'مستخدم';
      String userPhoto = user.photoURL ?? '';
      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] ?? userName;
          userPhoto = userDoc.data()?['photoUrl'] ?? userPhoto;
        }
      } catch (_) {}

      await firestore
          .collection('lessons')
          .doc(lessonId)
          .collection('reviews')
          .add({
            'userId': user.uid,
            'userName': userName,
            'userPhoto': userPhoto,
            'comment': comment,
            'rating': 5,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<ExamModel> getExam(String examId) async {
    try {
      final examDoc = await firestore.collection('exams').doc(examId).get();
      if (!examDoc.exists) {
        throw ServerException('الامتحان غير موجود');
      }
      return ExamModel.fromMap(examDoc.data()!, examDoc.id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<bool> checkIfPassedExam({
    required String examId,
    required int minimumPassScore,
  }) async {
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) return false;

      final resultsSnap = await firestore
          .collection('exam_results')
          .where('examId', isEqualTo: examId)
          .where('studentId', isEqualTo: uid)
          .get();

      for (var doc in resultsSnap.docs) {
        final data = doc.data();
        final score = data['score'] ?? 0;
        final totalGrade = data['totalGrade'] ?? 1;
        final pct = (score / totalGrade) * 100;
        if (pct >= minimumPassScore) return true;
      }
      return false;
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }
}

/// نتيجة فحص الامتحان
class ExamCheckResult {
  final bool passed;
  final DateTime? cooldownUntil;

  ExamCheckResult({required this.passed, this.cooldownUntil});
}

/// معلومات المدرس
class TeacherInfo {
  final String imageUrl;
  final String subject;

  TeacherInfo({required this.imageUrl, required this.subject});
}
