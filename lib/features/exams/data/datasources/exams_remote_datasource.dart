import 'package:alaref/core/utils/error/firebase_error_handler.dart';
import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// DataSource بيتعامل مع Firebase مباشرة لجلب بيانات الامتحانات
abstract class ExamsRemoteDataSource {
  Future<List<ExamModel>> getAllExams();
  Future<Map<String, int>> getStudentResults();
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ExamsRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<List<ExamModel>> getAllExams() async {
    try {
      final examSnap = await firestore.collection('exams').get();
      final exams = examSnap.docs
          .map((d) => ExamModel.fromMap(d.data(), d.id))
          .toList();
      // Sort locally: newest first
      exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return exams;
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<Map<String, int>> getStudentResults() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return {};

      final resultSnap = await firestore
          .collection('exam_results')
          .where('studentId', isEqualTo: user.uid)
          .get();

      final scores = <String, int>{};
      for (var doc in resultSnap.docs) {
        final data = doc.data();
        final examId = data['examId'] as String? ?? '';
        scores[examId] = (data['score'] as num?)?.toInt() ?? 0;
      }
      return scores;
    } catch (e) {
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }
}
