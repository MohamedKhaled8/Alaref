import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/data/datasources/course_details_remote_datasource.dart';
import 'package:alaref/features/home/data/repositories/course_details_repository_impl.dart';
import 'package:alaref/features/home/domain/repositories/course_details_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final LessonModel lesson;
  late final CourseDetailsRepository repository;

  CourseDetailsCubit({required this.lesson}) : super(CourseDetailsInitial()) {
    final dataSource = CourseDetailsRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    repository = CourseDetailsRepositoryImpl(dataSource: dataSource);
  }

  Future<void> initialize() async {
    emit(
      CourseDetailsLoaded(
        isUnlocked: false,
        currentStudentsCount: lesson.studentsCount,
        currentVideoUrl: lesson.videoUrl,
        checkingExamStatus: true,
      ),
    );

    // Load unlock status
    await _checkUnlockStatus();

    // Load teacher info
    _loadTeacherInfo();

    // Check exam status
    await _checkExamStatus();
  }

  Future<void> _checkUnlockStatus() async {
    final result = await repository.checkUnlockStatus(lesson.id, lesson.price);
    result.fold((failure) {}, (isUnlocked) {
      if (state is CourseDetailsLoaded && !isClosed) {
        emit((state as CourseDetailsLoaded).copyWith(isUnlocked: isUnlocked));
      }
    });
  }

  Future<void> _loadTeacherInfo() async {
    final result = await repository.loadTeacherInfo(lesson.teacherId);
    result.fold((failure) {}, (info) {
      if (state is CourseDetailsLoaded && !isClosed) {
        emit(
          (state as CourseDetailsLoaded).copyWith(
            teacherImageUrl: info.imageUrl,
            teacherSubject: info.subject,
          ),
        );
      }
    });
  }

  Future<void> _checkExamStatus() async {
    if (!lesson.requiresExam || lesson.prerequisiteExamId == null) {
      if (state is CourseDetailsLoaded && !isClosed) {
        emit(
          (state as CourseDetailsLoaded).copyWith(checkingExamStatus: false),
        );
      }
      return;
    }

    final result = await repository.checkExamStatus(
      examId: lesson.prerequisiteExamId!,
      lessonId: lesson.id,
      minimumPassScore: lesson.minimumPassScore,
    );

    result.fold(
      (failure) {
        if (state is CourseDetailsLoaded && !isClosed) {
          emit(
            (state as CourseDetailsLoaded).copyWith(checkingExamStatus: false),
          );
        }
      },
      (examResult) {
        if (state is CourseDetailsLoaded && !isClosed) {
          emit(
            (state as CourseDetailsLoaded).copyWith(
              hasPassedExam: examResult.passed,
              cooldownUntil: examResult.cooldownUntil,
              checkingExamStatus: false,
            ),
          );
        }
      },
    );
  }

  void playVideo(String videoUrl) {
    if (state is CourseDetailsLoaded && !isClosed) {
      emit(
        (state as CourseDetailsLoaded).copyWith(
          currentVideoUrl: videoUrl,
          isPlayingVideo: true,
        ),
      );
    }
  }

  void toggleDescription() {
    if (state is CourseDetailsLoaded && !isClosed) {
      final current = state as CourseDetailsLoaded;
      emit(
        current.copyWith(isDescriptionExpanded: !current.isDescriptionExpanded),
      );
    }
  }

  void setPassedExam() {
    if (state is CourseDetailsLoaded && !isClosed) {
      emit((state as CourseDetailsLoaded).copyWith(hasPassedExam: true));
    }
  }

  void setUnlocked() {
    if (state is CourseDetailsLoaded && !isClosed) {
      final current = state as CourseDetailsLoaded;
      emit(
        current.copyWith(
          isUnlocked: true,
          currentStudentsCount: current.currentStudentsCount + 1,
        ),
      );
    }
  }

  Future<void> redeemCode({
    required String code,
    required double lessonPrice,
  }) async {
    final result = await repository.redeemCode(
      code: code,
      lessonId: lesson.id,
      lessonPrice: lessonPrice,
    );

    result.fold((failure) => throw Exception(failure.message), (_) async {
      // Increment students count in background
      repository.incrementStudentsCount(lesson.id);
      setUnlocked();
    });
  }

  Future<void> submitComment(String comment) async {
    final result = await repository.submitComment(
      lessonId: lesson.id,
      comment: comment,
    );

    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  /// Re-check everything after returning from exam
  Future<void> refreshAfterExam() async {
    await _checkUnlockStatus();
    await _checkExamStatus();
  }
}
