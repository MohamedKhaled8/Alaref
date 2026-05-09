import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  ExamsCubit() : super(const ExamsState());

  void loadExams() {
    emit(state.copyWith(isLoading: true));
    _sub?.cancel();
    _sub = _firestore
        .collection('exams') // Or whatever collection name is appropriate
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        // final exams = snapshot.docs.map((d) => ExamModel.fromMap(d.data(), d.id)).toList();
        // emit(state.copyWith(exams: exams, isLoading: false));
        emit(state.copyWith(exams: [], isLoading: false)); // Placeholder
      },
      onError: (e) => emit(state.copyWith(errorMessage: e.toString(), isLoading: false)),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
