part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Teacher States
class TeacherAdded extends DashboardState {}

class TeachersLoaded extends DashboardState {
  final List<dynamic> teachers;
  const TeachersLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

// Lesson States
class LessonAdded extends DashboardState {}

class LessonsLoaded extends DashboardState {
  final List<dynamic> lessons;
  const LessonsLoaded(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

// Code States
class CodeGenerated extends DashboardState {
  final String code;
  final List<dynamic> teachers;
  const CodeGenerated(this.code, {this.teachers = const []});

  @override
  List<Object?> get props => [code, teachers];
}

class CodesLoaded extends DashboardState {
  final List<dynamic> codes;
  const CodesLoaded(this.codes);

  @override
  List<Object?> get props => [codes];
}

// User States
class UsersLoaded extends DashboardState {
  final List<dynamic> users;
  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserUpdated extends DashboardState {}

// Exam States
class ExamAdded extends DashboardState {}

class ExamsLoaded extends DashboardState {
  final List<dynamic> exams;
  const ExamsLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

// Statistics
class StatisticsLoaded extends DashboardState {
  final int totalUsers;
  final int totalLessons;
  final int totalExams;
  final int totalCodes;
  final int usedCodes;
  final int totalTeachers;

  const StatisticsLoaded({
    required this.totalUsers,
    required this.totalLessons,
    required this.totalExams,
    required this.totalCodes,
    required this.usedCodes,
    required this.totalTeachers,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalLessons,
    totalExams,
    totalCodes,
    usedCodes,
    totalTeachers,
  ];
}

// Combined state for pages that need teachers + another action
class TeachersWithCodeLoaded extends DashboardState {
  final List<dynamic> teachers;
  final String? lastGeneratedCode;
  const TeachersWithCodeLoaded(this.teachers, {this.lastGeneratedCode});

  @override
  List<Object?> get props => [teachers, lastGeneratedCode];
}
