import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:equatable/equatable.dart';

class LessonsState extends Equatable {
  final List<LessonModel> lessons;
  final bool isLoading;
  final String? errorMessage;

  const LessonsState({
    this.lessons = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  LessonsState copyWith({
    List<LessonModel>? lessons,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LessonsState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [lessons, isLoading, errorMessage];
}
