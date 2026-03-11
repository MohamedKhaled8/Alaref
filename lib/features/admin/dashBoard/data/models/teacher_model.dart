import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id;
  final String name;
  final String phone;
  final String subject;
  final String imageUrl;
  final DateTime createdAt;

  const TeacherModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.subject,
    required this.imageUrl,
    required this.createdAt,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map, String id) {
    return TeacherModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      subject: map['subject'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'subject': subject,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? subject,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
