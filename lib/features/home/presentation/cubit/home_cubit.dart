import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/admin/dashBoard/data/models/teacher_model.dart';
import 'package:async/async.dart';

class HomeState extends Equatable {
  final int visibleSections;
  final List<LessonModel> lessons;
  final List<TeacherModel> teachers;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.visibleSections = 0,
    this.lessons = const [],
    this.teachers = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  HomeState copyWith({
    int? visibleSections,
    List<LessonModel>? lessons,
    List<TeacherModel>? teachers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      visibleSections: visibleSections ?? this.visibleSections,
      lessons: lessons ?? this.lessons,
      teachers: teachers ?? this.teachers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    visibleSections,
    lessons,
    teachers,
    isLoading,
    errorMessage,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _homeSub;

  HomeCubit() : super(const HomeState());

  void startEntranceAnimation() {
    // Instantly show sections to avoid heavy sequential layout rebuilds
    // which caused significant lag on the home screen.
    emit(state.copyWith(visibleSections: 10, isLoading: true));
    _loadData();
  }

  void _loadData() {
    _homeSub?.cancel();
    _homeSub =
        StreamZip([
          _firestore
              .collection('lessons')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          _firestore
              .collection('teachers')
              .orderBy('createdAt', descending: true)
              .snapshots(),
        ]).listen(
          (results) {
            final lessons = results[0].docs
                .map((d) => LessonModel.fromMap(d.data(), d.id))
                .toList();
            final teachers = results[1].docs
                .map((d) => TeacherModel.fromMap(d.data(), d.id))
                .toList();

            emit(
              state.copyWith(
                lessons: lessons,
                teachers: teachers,
                isLoading: false,
              ),
            );
          },
          onError: (e) {
            emit(state.copyWith(errorMessage: e.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _homeSub?.cancel();
    return super.close();
  }
}
