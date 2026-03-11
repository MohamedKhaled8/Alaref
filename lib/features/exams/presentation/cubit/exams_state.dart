part of 'exams_cubit.dart';

sealed class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

// 🔵 الحالة الابتدائية
class ExamsInitial extends ExamsState {}

// ⏳ جاري التحميل
class ExamsLoading extends ExamsState {}

// ✅ تم تحميل الامتحانات
class ExamsLoaded extends ExamsState {
  final List<ExamModel> exams;
  final Map<String, int> scores;
  final int selectedTab;
  final int visibleCount;

  const ExamsLoaded({
    required this.exams,
    required this.scores,
    this.selectedTab = 0,
    this.visibleCount = 0,
  });

  Set<String> get takenExamIds => scores.keys.toSet();

  List<ExamModel> get filteredExams => exams
      .where((e) => selectedTab == 0 ? !e.isComprehensive : e.isComprehensive)
      .toList();

  ExamsLoaded copyWith({
    List<ExamModel>? exams,
    Map<String, int>? scores,
    int? selectedTab,
    int? visibleCount,
  }) {
    return ExamsLoaded(
      exams: exams ?? this.exams,
      scores: scores ?? this.scores,
      selectedTab: selectedTab ?? this.selectedTab,
      visibleCount: visibleCount ?? this.visibleCount,
    );
  }

  @override
  List<Object?> get props => [exams, scores, selectedTab, visibleCount];
}

// ❌ حدث خطأ
class ExamsError extends ExamsState {
  final String message;

  const ExamsError(this.message);

  @override
  List<Object?> get props => [message];
}
