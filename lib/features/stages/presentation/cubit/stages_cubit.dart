import 'package:bloc/bloc.dart';

class StagesState {
  final int visibleCount;
  const StagesState({this.visibleCount = 0});
}

class StagesCubit extends Cubit<StagesState> {
  StagesCubit() : super(const StagesState(visibleCount: 0));

  void startEntranceAnimation() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 200)), () {
        if (!isClosed) emit(StagesState(visibleCount: i + 1));
      });
    }
  }
}
