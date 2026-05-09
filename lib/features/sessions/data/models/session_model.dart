import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String lessonImageUrl;
  final String teacherName;
  final DateTime openedAt;

  const SessionModel({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonImageUrl,
    required this.teacherName,
    required this.openedAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      lessonImageUrl: map['lessonImageUrl'] ?? '',
      teacherName: map['teacherName'] ?? '',
      openedAt: map['openedAt'] != null
          ? (map['openedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'lessonImageUrl': lessonImageUrl,
      'teacherName': teacherName,
      'openedAt': FieldValue.serverTimestamp(),
    };
  }
}
