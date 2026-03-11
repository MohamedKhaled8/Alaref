part of 'course_details_cubit.dart';

sealed class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

// 🔵 جاري التحقق من الحالة الأولية
class CourseDetailsInitial extends CourseDetailsState {}

// ⏳ جاري التحميل
class CourseDetailsLoading extends CourseDetailsState {}

// ✅ تم تحميل البيانات
class CourseDetailsLoaded extends CourseDetailsState {
  final bool isUnlocked;
  final bool hasPassedExam;
  final bool checkingExamStatus;
  final String teacherImageUrl;
  final String teacherSubject;
  final int currentStudentsCount;
  final bool isPlayingVideo;
  final bool isDescriptionExpanded;
  final String currentVideoUrl;
  final DateTime? cooldownUntil;

  const CourseDetailsLoaded({
    required this.isUnlocked,
    this.hasPassedExam = false,
    this.checkingExamStatus = true,
    this.teacherImageUrl = '',
    this.teacherSubject = '',
    required this.currentStudentsCount,
    this.isPlayingVideo = false,
    this.isDescriptionExpanded = false,
    required this.currentVideoUrl,
    this.cooldownUntil,
  });

  CourseDetailsLoaded copyWith({
    bool? isUnlocked,
    bool? hasPassedExam,
    bool? checkingExamStatus,
    String? teacherImageUrl,
    String? teacherSubject,
    int? currentStudentsCount,
    bool? isPlayingVideo,
    bool? isDescriptionExpanded,
    String? currentVideoUrl,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
  }) {
    return CourseDetailsLoaded(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasPassedExam: hasPassedExam ?? this.hasPassedExam,
      checkingExamStatus: checkingExamStatus ?? this.checkingExamStatus,
      teacherImageUrl: teacherImageUrl ?? this.teacherImageUrl,
      teacherSubject: teacherSubject ?? this.teacherSubject,
      currentStudentsCount: currentStudentsCount ?? this.currentStudentsCount,
      isPlayingVideo: isPlayingVideo ?? this.isPlayingVideo,
      isDescriptionExpanded:
          isDescriptionExpanded ?? this.isDescriptionExpanded,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
      cooldownUntil: clearCooldown
          ? null
          : (cooldownUntil ?? this.cooldownUntil),
    );
  }

  @override
  List<Object?> get props => [
    isUnlocked,
    hasPassedExam,
    checkingExamStatus,
    teacherImageUrl,
    teacherSubject,
    currentStudentsCount,
    isPlayingVideo,
    isDescriptionExpanded,
    currentVideoUrl,
    cooldownUntil,
  ];
}

// ❌ حدث خطأ
class CourseDetailsError extends CourseDetailsState {
  final String message;

  const CourseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
