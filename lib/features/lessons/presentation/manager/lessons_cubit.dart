import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:alaref/core/utils/services/user_stage_provider.dart';
import '../../domain/usecases/get_lessons_usecase.dart';
import 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  final GetLessonsUseCase getLessonsUseCase;
  final UserStageProvider userStageProvider;
  StreamSubscription? _sub;

  LessonsCubit({
    required this.getLessonsUseCase,
    required this.userStageProvider,
  }) : super(const LessonsState());

  Future<void> loadLessons() async {
    emit(state.copyWith(isLoading: true));
    _sub?.cancel();

    final stage = await userStageProvider.getStage();

    _sub = getLessonsUseCase(stage).listen(
      (lessons) {
        emit(state.copyWith(lessons: lessons, isLoading: false));
      },
      onError: (e) => emit(
        state.copyWith(errorMessage: e.toString(), isLoading: false),
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
