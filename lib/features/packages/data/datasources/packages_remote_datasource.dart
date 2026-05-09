import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

abstract class PackagesRemoteDataSource {
  Stream<List<LessonModel>> getPackages(String stage);
}

class PackagesRemoteDataSourceImpl implements PackagesRemoteDataSource {
  final FirebaseFirestore firestore;

  PackagesRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<LessonModel>> getPackages(String stage) {
    return firestore
        .collection('lessons')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((d) => LessonModel.fromMap(d.data(), d.id))
          .where((l) => l.isPackage == true && l.isActive == true)
          .toList();
      
      // Sort in memory
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }
}
