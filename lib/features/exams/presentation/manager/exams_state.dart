import 'package:equatable/equatable.dart';

class ExamsState extends Equatable {
  final List<dynamic> exams; // Replace dynamic with ExamModel when created
  final bool isLoading;
  final String? errorMessage;

  const ExamsState({
    this.exams = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  ExamsState copyWith({
    List<dynamic>? exams,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExamsState(
      exams: exams ?? this.exams,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [exams, isLoading, errorMessage];
}
