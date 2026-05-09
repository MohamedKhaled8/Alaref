import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

abstract class LessonsRemoteDataSource {
  Stream<List<LessonModel>> getLessons(String stage);
}

class LessonsRemoteDataSourceImpl implements LessonsRemoteDataSource {
  final FirebaseFirestore firestore;

  LessonsRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<LessonModel>> getLessons(String stage) {
    return firestore
        .collection('lessons')
//      .where('stage', isEqualTo: stage)
//      .where('isPackage', isEqualTo: false)
//      .where('isActive', isEqualTo: true)
//      .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => LessonModel.fromMap(d.data(), d.id))
          .toList();
    });
  }
}
