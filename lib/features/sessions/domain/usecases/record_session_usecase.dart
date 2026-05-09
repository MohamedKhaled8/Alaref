import 'package:alaref/features/sessions/domain/repositories/sessions_repository.dart';

class RecordSessionUseCase {
  final SessionsRepository repository;

  RecordSessionUseCase({required this.repository});

  Future<void> call({
    required String uid,
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  }) {
    return repository.recordSession(
      uid: uid,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      lessonImageUrl: lessonImageUrl,
      teacherName: teacherName,
    );
  }
}
