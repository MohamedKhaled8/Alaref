import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:alaref/features/admin/dashBoard/data/models/teacher_model.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/admin/dashBoard/data/models/code_model.dart';
import 'package:alaref/core/utils/services/imgbb_service.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FirebaseFirestore _firestore;
  FirebaseFirestore get firestore => _firestore;

  // Subscriptions for realtime data
  StreamSubscription? _statsSub;
  StreamSubscription? _usersSub;
  StreamSubscription? _teachersSub;
  StreamSubscription? _lessonsSub;
  StreamSubscription? _codesSub;
  StreamSubscription? _examsSub;

  // Cache teachers so we don't lose them between state changes
  List<TeacherModel> _cachedTeachers = [];

  DashboardCubit({required FirebaseFirestore firestore})
    : _firestore = firestore,
      super(DashboardInitial());

  // Getter for cached teachers (any page can use)
  List<TeacherModel> get cachedTeachers => _cachedTeachers;

  // Helper to upload image to ImgBB
  Future<String> _uploadImage(String path, String folder) async {
    final url = await ImgbbService.uploadImage(path);
    return url ?? path;
  }

  // ==============================
  // 📊 Statistics
  // ==============================
  Future<void> loadStatistics() async {
    emit(DashboardLoading());
    _statsSub?.cancel();

    _statsSub =
        StreamZip([
          _firestore.collection('users').snapshots(),
          _firestore.collection('lessons').snapshots(),
          _firestore.collection('exams').snapshots(),
          _firestore.collection('codes').snapshots(),
          _firestore.collection('teachers').snapshots(),
        ]).listen((results) {
          final usersSnap = results[0];
          final lessonsSnap = results[1];
          final examsSnap = results[2];
          final codesSnap = results[3];
          final teachersSnap = results[4];

          final usedCodes = codesSnap.docs
              .where((d) => d.data()['isUsed'] == true)
              .length;

          emit(
            StatisticsLoaded(
              totalUsers: usersSnap.docs.length,
              totalLessons: lessonsSnap.docs.length,
              totalExams: examsSnap.docs.length,
              totalCodes: codesSnap.docs.length,
              usedCodes: usedCodes,
              totalTeachers: teachersSnap.docs.length,
            ),
          );
        }, onError: (e) => emit(DashboardError(e.toString())));
  }

  // ==============================
  // 👥 Users Management
  // ==============================
  Future<void> loadUsers({String? searchQuery}) async {
    emit(DashboardLoading());
    _usersSub?.cancel();
    _usersSub = _firestore.collection('users').snapshots().listen((snap) {
      var users = snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        users = users
            .where(
              (u) =>
                  (u['name'] ?? '').toString().toLowerCase().contains(q) ||
                  (u['email'] ?? '').toString().toLowerCase().contains(q) ||
                  (u['phone'] ?? '').toString().contains(q),
            )
            .toList();
      }
      emit(UsersLoaded(users));
    }, onError: (e) => emit(DashboardError(e.toString())));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    emit(DashboardLoading());
    try {
      await _firestore.collection('users').doc(uid).update(data);
      emit(UserUpdated());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // ==============================
  // 👨‍🏫 Teachers Management
  // ==============================
  Future<void> addTeacher(TeacherModel teacher) async {
    emit(DashboardLoading());
    try {
      String finalImageUrl = teacher.imageUrl;
      if (teacher.imageUrl.isNotEmpty && !teacher.imageUrl.startsWith('http')) {
        finalImageUrl = await _uploadImage(teacher.imageUrl, 'teachers');
      }

      final updatedTeacher = teacher.copyWith(imageUrl: finalImageUrl);
      await _firestore.collection('teachers').add(updatedTeacher.toMap());
      emit(TeacherAdded());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadTeachers() async {
    _teachersSub?.cancel();
    _teachersSub = _firestore
        .collection('teachers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _cachedTeachers = snap.docs
              .map((d) => TeacherModel.fromMap(d.data(), d.id))
              .toList();
          emit(TeachersLoaded(_cachedTeachers));
        }, onError: (e) => emit(DashboardError(e.toString())));
  }

  // ==============================
  // 📚 Lessons Management
  // ==============================
  Future<void> addLesson(LessonModel lesson) async {
    emit(DashboardLoading());
    try {
      String mainImageUrl = lesson.imageUrl;
      if (lesson.imageUrl.isNotEmpty && !lesson.imageUrl.startsWith('http')) {
        mainImageUrl = await _uploadImage(lesson.imageUrl, 'lessons');
      }

      List<PackageItem> updatedItems = [];
      for (var item in lesson.packageItems) {
        String itemUrl = item.imageUrl;
        if (item.imageUrl.isNotEmpty && !item.imageUrl.startsWith('http')) {
          itemUrl = await _uploadImage(item.imageUrl, 'lessons/packages');
        }
        updatedItems.add(
          PackageItem(
            title: item.title,
            description: item.description,
            imageUrl: itemUrl,
            videoUrl: item.videoUrl,
            requiresExam: item.requiresExam,
            prerequisiteExamId: item.prerequisiteExamId,
            minimumPassScore: item.minimumPassScore,
          ),
        );
      }

      final updatedLesson = lesson.copyWith(
        imageUrl: mainImageUrl,
        packageItems: updatedItems,
      );

      await _firestore.collection('lessons').add(updatedLesson.toMap());
      emit(LessonAdded());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> updateLesson(String id, LessonModel lesson) async {
    emit(DashboardLoading());
    try {
      String mainImageUrl = lesson.imageUrl;
      if (lesson.imageUrl.isNotEmpty && !lesson.imageUrl.startsWith('http')) {
        mainImageUrl = await _uploadImage(lesson.imageUrl, 'lessons');
      }

      List<PackageItem> updatedItems = [];
      for (var item in lesson.packageItems) {
        String itemUrl = item.imageUrl;
        if (item.imageUrl.isNotEmpty && !item.imageUrl.startsWith('http')) {
          itemUrl = await _uploadImage(item.imageUrl, 'lessons/packages');
        }
        updatedItems.add(
          PackageItem(
            title: item.title,
            description: item.description,
            imageUrl: itemUrl,
            videoUrl: item.videoUrl,
            requiresExam: item.requiresExam,
            prerequisiteExamId: item.prerequisiteExamId,
            minimumPassScore: item.minimumPassScore,
          ),
        );
      }

      final updatedLesson = lesson.copyWith(
        imageUrl: mainImageUrl,
        packageItems: updatedItems,
      );

      await _firestore
          .collection('lessons')
          .doc(id)
          .update(updatedLesson.toMap());
      emit(
        LessonAdded(),
      ); // Reuse this state so the UI shows success and reloads
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadLessons() async {
    _lessonsSub?.cancel();
    _lessonsSub = _firestore
        .collection('lessons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          final lessons = snap.docs
              .map((d) => LessonModel.fromMap(d.data(), d.id))
              .toList();
          emit(LessonsLoaded(lessons));
        }, onError: (e) => emit(DashboardError(e.toString())));
  }

  // ==============================
  // � Lessons Management
  // ==============================
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).delete();
      // Wait a moment and reload
      await Future.delayed(const Duration(milliseconds: 300));
      loadLessons();
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> toggleLessonStatus(String lessonId, bool isActive) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'isActive': isActive,
      });
      await Future.delayed(const Duration(milliseconds: 300));
      loadLessons();
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // ==============================
  // �🔐 Codes Management
  // ==============================
  String _generateRandomCode() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }

  Future<void> generateCode({
    required double value,
    required String teacherId,
    required String teacherName,
  }) async {
    emit(DashboardLoading());
    try {
      final code = _generateRandomCode();
      final codeModel = CodeModel(
        id: '',
        code: code,
        value: value,
        teacherId: teacherId,
        teacherName: teacherName,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('codes').add(codeModel.toMap());
      emit(CodeGenerated(code, teachers: _cachedTeachers));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadCodes() async {
    _codesSub?.cancel();
    _codesSub = _firestore
        .collection('codes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          final codes = snap.docs
              .map((d) => CodeModel.fromMap(d.data(), d.id))
              .toList();
          emit(CodesLoaded(codes));
        }, onError: (e) => emit(DashboardError(e.toString())));
  }

  // ==============================
  // 📝 Exams Management
  // ==============================
  Future<void> loadExams() async {
    _examsSub?.cancel();
    _examsSub = _firestore.collection('exams').snapshots().listen((snap) {
      final exams = snap.docs
          .map((d) => ExamModel.fromMap(d.data(), d.id))
          .toList();
      // Sort locally: newest first (some old docs may lack createdAt)
      exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(ExamsLoaded(exams));
    }, onError: (e) => emit(DashboardError(e.toString())));
  }

  Future<void> addExam(ExamModel exam) async {
    emit(DashboardLoading());
    try {
      await _firestore.collection('exams').add(exam.toMap());
      emit(ExamAdded());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> submitExamResult(ExamResult result) async {
    try {
      await _firestore.collection('exam_results').add(result.toMap());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _statsSub?.cancel();
    _usersSub?.cancel();
    _teachersSub?.cancel();
    _lessonsSub?.cancel();
    _codesSub?.cancel();
    _examsSub?.cancel();
    return super.close();
  }
}
