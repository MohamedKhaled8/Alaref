import 'package:alaref/features/auth/domain/entities/user_entity.dart';

/// عرض المرحلة الدراسية بالعربية (للواجهة فقط).
String academicStageLabel(AcademicStage stage) {
  switch (stage) {
    case AcademicStage.primary:
      return 'المرحلة الابتدائية';
    case AcademicStage.preparatory:
      return 'المرحلة الإعدادية';
    case AcademicStage.secondary:
      return 'المرحلة الثانوية';
  }
}
