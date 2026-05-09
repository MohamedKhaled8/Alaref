import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:equatable/equatable.dart';

class PackagesState extends Equatable {
  final List<LessonModel> packages;
  final bool isLoading;
  final String? errorMessage;

  const PackagesState({
    this.packages = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  PackagesState copyWith({
    List<LessonModel>? packages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [packages, isLoading, errorMessage];
}
