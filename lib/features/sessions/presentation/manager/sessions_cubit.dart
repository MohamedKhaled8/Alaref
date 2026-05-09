import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:alaref/core/utils/services/user_stage_provider.dart';
import 'package:alaref/features/sessions/domain/usecases/get_recent_sessions_usecase.dart';
import 'package:alaref/features/sessions/domain/usecases/record_session_usecase.dart';
import 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final GetRecentSessionsUseCase getRecentSessionsUseCase;
  final RecordSessionUseCase recordSessionUseCase;
  final UserStageProvider userStageProvider;
  StreamSubscription? _sub;

  SessionsCubit({
    required this.getRecentSessionsUseCase,
    required this.recordSessionUseCase,
    required this.userStageProvider,
  }) : super(const SessionsState());

  void loadSessions() {
    emit(state.copyWith(isLoading: true));
    _sub?.cancel();

    final uid = userStageProvider.currentUid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    _sub = getRecentSessionsUseCase(uid).listen(
      (sessions) {
        emit(state.copyWith(sessions: sessions, isLoading: false));
      },
      onError: (e) => emit(
        state.copyWith(errorMessage: e.toString(), isLoading: false),
      ),
    );
  }

  Future<void> recordSession({
    required String lessonId,
    required String lessonTitle,
    required String lessonImageUrl,
    required String teacherName,
  }) async {
    final uid = userStageProvider.currentUid;
    if (uid == null) return;

    await recordSessionUseCase(
      uid: uid,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      lessonImageUrl: lessonImageUrl,
      teacherName: teacherName,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
