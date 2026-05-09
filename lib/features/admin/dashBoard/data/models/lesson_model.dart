import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final double price;
  final double? discountPrice;
  final bool hasDiscount;
  final String teacherId;
  final String teacherName;
  final bool isPackage;
  final bool isCourse;
  final String stage; // primary, preparatory, secondary
  final DateTime createdAt;
  final List<PackageItem> packageItems;
  final bool isActive;
  final int studentsCount;
  // Prerequisite exam fields
  final bool requiresExam;
  final String? prerequisiteExamId;
  final int minimumPassScore;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.price,
    this.discountPrice,
    this.hasDiscount = false,
    required this.teacherId,
    required this.teacherName,
    this.isPackage = false,
    this.isCourse = false,
    required this.stage,
    required this.createdAt,
    this.packageItems = const [],
    this.isActive = true,
    this.studentsCount = 0,
    this.requiresExam = false,
    this.prerequisiteExamId,
    this.minimumPassScore = 50,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      hasDiscount: map['hasDiscount'] == true,
      teacherId: map['teacherId']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      isPackage: map['isPackage'] == true,
      isCourse: map['isCourse'] == true,
      stage: map['stage']?.toString() ?? 'primary',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      packageItems: map['packageItems'] != null
          ? (map['packageItems'] as List)
                .map(
                  (e) =>
                      PackageItem.fromMap(Map<String, dynamic>.from(e as Map)),
                )
                .toList()
          : [],
      isActive: map['isActive'] ?? true,
      studentsCount: map['studentsCount'] ?? 0,
      requiresExam: map['requiresExam'] == true,
      prerequisiteExamId: map['prerequisiteExamId']?.toString(),
      minimumPassScore: map['minimumPassScore'] ?? 50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'price': price,
      'discountPrice': discountPrice,
      'hasDiscount': hasDiscount,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'isPackage': isPackage,
      'isCourse': isCourse,
      'stage': stage,
      'createdAt': FieldValue.serverTimestamp(),
      'packageItems': packageItems.map((e) => e.toMap()).toList(),
      'isActive': isActive,
      'studentsCount': studentsCount,
      'requiresExam': requiresExam,
      'prerequisiteExamId': prerequisiteExamId,
      'minimumPassScore': minimumPassScore,
    };
  }

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    double? price,
    double? discountPrice,
    bool? hasDiscount,
    String? teacherId,
    String? teacherName,
    bool? isPackage,
    bool? isCourse,
    String? stage,
    DateTime? createdAt,
    List<PackageItem>? packageItems,
    bool? isActive,
    int? studentsCount,
    bool? requiresExam,
    String? prerequisiteExamId,
    int? minimumPassScore,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isPackage: isPackage ?? this.isPackage,
      isCourse: isCourse ?? this.isCourse,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      packageItems: packageItems ?? this.packageItems,
      isActive: isActive ?? this.isActive,
      studentsCount: studentsCount ?? this.studentsCount,
      requiresExam: requiresExam ?? this.requiresExam,
      prerequisiteExamId: prerequisiteExamId ?? this.prerequisiteExamId,
      minimumPassScore: minimumPassScore ?? this.minimumPassScore,
    );
  }
}

class PackageItem {
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  // Prerequisite exam fields
  final bool requiresExam;
  final String? prerequisiteExamId;
  final int minimumPassScore;

  const PackageItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    this.requiresExam = false,
    this.prerequisiteExamId,
    this.minimumPassScore = 50,
  });

  factory PackageItem.fromMap(Map<String, dynamic> map) {
    return PackageItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      requiresExam: map['requiresExam'] ?? false,
      prerequisiteExamId: map['prerequisiteExamId'],
      minimumPassScore: map['minimumPassScore'] ?? 50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'requiresExam': requiresExam,
      'prerequisiteExamId': prerequisiteExamId,
      'minimumPassScore': minimumPassScore,
    };
  }
}
