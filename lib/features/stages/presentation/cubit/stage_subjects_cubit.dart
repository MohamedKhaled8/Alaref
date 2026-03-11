import 'package:bloc/bloc.dart';

class StageSubjectsState {
  final int visibleCount;
  const StageSubjectsState({this.visibleCount = 0});
}

class StageSubjectsCubit extends Cubit<StageSubjectsState> {
  final int totalSubjects;

  StageSubjectsCubit(this.totalSubjects) : super(const StageSubjectsState()) {
    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < totalSubjects; i++) {
      Future.delayed(Duration(milliseconds: 150 + (i * 85)), () {
        if (!isClosed) {
          emit(StageSubjectsState(visibleCount: i + 1));
        }
      });
    }
  }
}
