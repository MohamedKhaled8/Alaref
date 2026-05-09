import 'package:alaref/features/sessions/data/models/session_model.dart';
import 'package:alaref/features/sessions/domain/repositories/sessions_repository.dart';

class GetRecentSessionsUseCase {
  final SessionsRepository repository;

  GetRecentSessionsUseCase({required this.repository});

  Stream<List<SessionModel>> call(String uid) {
    return repository.getRecentSessions(uid);
  }
}
