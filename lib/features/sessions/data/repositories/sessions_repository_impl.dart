import 'package:alaref/features/sessions/data/models/session_model.dart';
import 'package:alaref/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:alaref/features/sessions/data/datasources/sessions_remote_datasource.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource remoteDataSource;

  SessionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> recordSession({
    required String uid,
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  }) {
    return remoteDataSource.recordSession(
      uid: uid,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      lessonImageUrl: lessonImageUrl,
      teacherName: teacherName,
    );
  }

  @override
  Stream<List<SessionModel>> getRecentSessions(String uid) {
    return remoteDataSource.getRecentSessions(uid);
  }
}
