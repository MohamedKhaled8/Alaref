import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/data/datasources/exams_remote_datasource.dart';
import 'package:alaref/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:alaref/features/exams/domain/usecases/get_exams_usecase.dart';
import 'package:alaref/features/exams/domain/usecases/get_student_results_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  late final GetExamsUseCase getExamsUseCase;
  late final GetStudentResultsUseCase getStudentResultsUseCase;

  ExamsCubit() : super(ExamsInitial()) {
    final dataSource = ExamsRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    final repository = ExamsRepositoryImpl(dataSource: dataSource);
    getExamsUseCase = GetExamsUseCase(repository: repository);
    getStudentResultsUseCase = GetStudentResultsUseCase(repository: repository);
  }

  Future<void> loadExams() async {
    emit(ExamsLoading());

    final examsResult = await getExamsUseCase();

    examsResult.fold((failure) => emit(ExamsError(failure.message)), (
      exams,
    ) async {
      final resultsResult = await getStudentResultsUseCase();

      resultsResult.fold((failure) => emit(ExamsError(failure.message)), (
        scores,
      ) {
        emit(ExamsLoaded(exams: exams, scores: scores));
        startEntranceAnimation();
      });
    });
  }

  void selectTab(int tab) {
    final currentState = state;
    if (currentState is ExamsLoaded) {
      emit(currentState.copyWith(selectedTab: tab, visibleCount: 0));
      startEntranceAnimation();
    }
  }

  void startEntranceAnimation() {
    final currentState = state;
    if (currentState is ExamsLoaded) {
      final count = currentState.filteredExams.length;
      for (int i = 0; i < count; i++) {
        Future.delayed(Duration(milliseconds: 100 + i * 80), () {
          if (!isClosed && state is ExamsLoaded) {
            emit((state as ExamsLoaded).copyWith(visibleCount: i + 1));
          }
        });
      }
    }
  }
}
