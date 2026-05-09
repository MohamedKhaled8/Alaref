import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

abstract class SessionsRemoteDataSource {
  Future<void> recordSession({
    required String uid,
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  });
  Stream<List<SessionModel>> getRecentSessions(String uid);
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final FirebaseFirestore firestore;

  SessionsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> recordSession({
    required String uid,
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  }) async {
    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('recent_sessions');

    // Check if session already exists — if so, update timestamp
    final existing = await ref.where('lessonId', isEqualTo: lessonId).limit(1).get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'openedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.add(SessionModel(
        id: '',
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        lessonImageUrl: lessonImageUrl,
        teacherName: teacherName,
        openedAt: DateTime.now(),
      ).toMap());
    }
  }

  @override
  Stream<List<SessionModel>> getRecentSessions(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('recent_sessions')
        .orderBy('openedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => SessionModel.fromMap(d.data(), d.id))
          .toList();
    });
  }
}
