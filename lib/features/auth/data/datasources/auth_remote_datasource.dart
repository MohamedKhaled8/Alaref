import 'package:alaref/core/utils/error/firebase_error_handler.dart';
import 'package:alaref/core/utils/error/exceptions.dart';
import 'package:alaref/features/auth/data/models/user_model.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

///ده اللي بيكلم Firebase مباشرة
///لو في يوم حبيت تغير Firebase لـ API تاني، بس تعدل هنا

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String parentPhone,
    required AcademicStage stage,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // FirebaseAuth: للـ login/register/logout
  final FirebaseAuth _firebaseAuth;

  // FirebaseFirestore: لحفظ بيانات المستخدم الزيادة (اسم، هاتف، مرحله)
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      final docSnapShot = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromMap(docSnapShot.data()!, uid);
    } catch (e) {
      // بنتعامل مع اي خطأ بيحصل من فايربيز او غيره
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String parentPhone,
    required AcademicStage stage,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        parentPhone: parentPhone,
        stage: stage,
        password: password,
      );

      // بنحفظ في Firestore
      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      return userModel;
    } catch (e) {
      // لو حصل مشكلة بعد ما الحساب اتعمل في Auth، بنمسحه عشان ميعلقش
      if (userCredential != null && userCredential.user != null) {
        try {
          await userCredential.user!.delete();
        } catch (_) {
          // نتجاهل خطأ المسح لو حصل
        }
      }
      throw ServerException(FirebaseErrorHandler.getErrorMessage(e));
    }
  }
}
