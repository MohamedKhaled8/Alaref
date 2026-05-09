import 'package:alaref/features/sessions/data/models/session_model.dart';

abstract class SessionsRepository {
  Future<void> recordSession({
    required String uid,
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  });
  Stream<List<SessionModel>> getRecentSessions(String uid);
}
