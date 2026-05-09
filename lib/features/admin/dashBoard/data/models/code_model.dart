import 'package:cloud_firestore/cloud_firestore.dart';

class CodeModel {
  final String id;
  final String code;
  final double value;
  final String teacherId;
  final String teacherName;
  final bool isUsed;
  final String? usedByStudentId;
  final String? usedByStudentName;
  final String? usedByStudentPhone;
  final String? usedByStudentCode;
  final DateTime createdAt;
  final DateTime? usedAt;

  const CodeModel({
    required this.id,
    required this.code,
    required this.value,
    required this.teacherId,
    required this.teacherName,
    this.isUsed = false,
    this.usedByStudentId,
    this.usedByStudentName,
    this.usedByStudentPhone,
    this.usedByStudentCode,
    required this.createdAt,
    this.usedAt,
  });

  factory CodeModel.fromMap(Map<String, dynamic> map, String id) {
    return CodeModel(
      id: id,
      code: map['code'] ?? '',
      value: (map['value'] ?? 0).toDouble(),
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      isUsed: map['isUsed'] ?? false,
      usedByStudentId: map['usedByStudentId'],
      usedByStudentName: map['usedByStudentName'],
      usedByStudentPhone: map['usedByStudentPhone'],
      usedByStudentCode: map['usedByStudentCode'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      usedAt: map['usedAt'] != null
          ? (map['usedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'value': value,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'isUsed': isUsed,
      'usedByStudentId': usedByStudentId,
      'usedByStudentName': usedByStudentName,
      'usedByStudentPhone': usedByStudentPhone,
      'usedByStudentCode': usedByStudentCode,
      'createdAt': FieldValue.serverTimestamp(),
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
    };
  }
}
