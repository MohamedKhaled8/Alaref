import '../../domain/entities/user_entity.dart';

// UserModel بيورث UserEntity — يعني فيه كل حاجة فيه وزيادة
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.parentPhone,
    required super.stage,
    required super.password,
  });

  // 📥 fromMap: بيحول Map (من Firestore) لـ UserModel
  // بيتاستخدم لما تجيب بيانات من Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '', // لو مفيش name ارجع string فاضي
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      // بنحول الـ String اللي في Firestore لـ enum
      stage: _stageFromString(map['stage'] ?? 'primary'),
      password: map['password'] ?? '',
    );
  }

  // 📤 toMap: بيحول UserModel لـ Map عشان نحطه في Firestore
  // بيتاستخدم لما تحفظ البيانات
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'parentPhone': parentPhone,
      // بنحول الـ enum لـ String عشان Firestore ما بيعرفش enum
      'stage': _stageToString(stage),
      'createdAt': DateTime.now().toIso8601String(), // وقت الإنشاء
      'password': password,
    };
  }

  // Helper: بيحول String → AcademicStage
  static AcademicStage _stageFromString(String stage) {
    switch (stage) {
      case 'preparatory':
        return AcademicStage.preparatory;
      case 'secondary':
        return AcademicStage.secondary;
      default:
        return AcademicStage.primary;
    }
  }

  // Helper: بيحول AcademicStage → String
  static String _stageToString(AcademicStage stage) {
    switch (stage) {
      case AcademicStage.preparatory:
        return 'preparatory';
      case AcademicStage.secondary:
        return 'secondary';
      case AcademicStage.primary:
        return 'primary';
    }
  }
}
