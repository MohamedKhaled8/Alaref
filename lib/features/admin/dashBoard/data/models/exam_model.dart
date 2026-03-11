import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String id;
  final String title;
  final int durationMinutes;
  final List<ExamQuestion> questions;
  final String teacherId;
  final String teacherName;
  final String stage;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final int retakeCooldownSeconds;
  final bool isComprehensive;

  const ExamModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.questions,
    required this.teacherId,
    required this.teacherName,
    required this.stage,
    required this.createdAt,
    this.scheduledDate,
    this.retakeCooldownSeconds = 0,
    this.isComprehensive = false,
  });

  int get totalGrade => questions.fold(0, (sum, q) => sum + q.grade);

  factory ExamModel.fromMap(Map<String, dynamic> map, String id) {
    return ExamModel(
      id: id,
      title: map['title'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 30,
      questions: map['questions'] != null
          ? (map['questions'] as List)
                .map(
                  (e) =>
                      ExamQuestion.fromMap(Map<String, dynamic>.from(e as Map)),
                )
                .toList()
          : [],
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      stage: map['stage'] ?? 'primary',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      scheduledDate: map['scheduledDate'] != null
          ? (map['scheduledDate'] as Timestamp).toDate()
          : null,
      retakeCooldownSeconds: map['retakeCooldownSeconds'] ?? 0,
      isComprehensive: map['isComprehensive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'durationMinutes': durationMinutes,
      'questions': questions.map((e) => e.toMap()).toList(),
      'teacherId': teacherId,
      'teacherName': teacherName,
      'stage': stage,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledDate': scheduledDate != null
          ? Timestamp.fromDate(scheduledDate!)
          : null,
      'retakeCooldownSeconds': retakeCooldownSeconds,
      'isComprehensive': isComprehensive,
    };
  }
}

/// Question types:
/// 'image_mcq' = صورة + اختيارات
/// 'image_essay' = صورة + إجابة مقالي
/// 'text_mcq' = نص + اختيارات
/// 'mixed' = نص + اختيارات (نص ونص)
enum QuestionType { imageMcq, imageEssay, textMcq, mixed }

class ExamQuestion {
  final String questionText;
  final String? imageUrl;
  final QuestionType type;
  final List<String> choices;
  final String correctAnswer;
  final int grade;

  const ExamQuestion({
    required this.questionText,
    this.imageUrl,
    required this.type,
    this.choices = const [],
    required this.correctAnswer,
    required this.grade,
  });

  factory ExamQuestion.fromMap(Map<String, dynamic> map) {
    return ExamQuestion(
      questionText: map['questionText'] ?? '',
      imageUrl: map['imageUrl'],
      type: _typeFromString(map['type'] ?? 'text_mcq'),
      choices: map['choices'] != null ? List<String>.from(map['choices']) : [],
      correctAnswer: map['correctAnswer'] ?? '',
      grade: map['grade'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'imageUrl': imageUrl,
      'type': _typeToString(type),
      'choices': choices,
      'correctAnswer': correctAnswer,
      'grade': grade,
    };
  }

  static QuestionType _typeFromString(String type) {
    switch (type) {
      case 'image_mcq':
        return QuestionType.imageMcq;
      case 'image_essay':
        return QuestionType.imageEssay;
      case 'text_mcq':
        return QuestionType.textMcq;
      case 'mixed':
        return QuestionType.mixed;
      default:
        return QuestionType.textMcq;
    }
  }

  static String _typeToString(QuestionType type) {
    switch (type) {
      case QuestionType.imageMcq:
        return 'image_mcq';
      case QuestionType.imageEssay:
        return 'image_essay';
      case QuestionType.textMcq:
        return 'text_mcq';
      case QuestionType.mixed:
        return 'mixed';
    }
  }
}

class ExamResult {
  final String examId;
  final String studentId;
  final String studentName;
  final String studentCode;
  final int score;
  final int totalGrade;
  final Map<int, String> answers;
  final DateTime submittedAt;

  const ExamResult({
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.score,
    required this.totalGrade,
    required this.answers,
    required this.submittedAt,
  });

  double get percentage => totalGrade > 0 ? (score / totalGrade) * 100 : 0;

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      examId: map['examId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentCode: map['studentCode'] ?? '',
      score: map['score'] ?? 0,
      totalGrade: map['totalGrade'] ?? 0,
      answers: map['answers'] != null
          ? Map<int, String>.from(
              (map['answers'] as Map).map(
                (k, v) => MapEntry(int.parse(k.toString()), v.toString()),
              ),
            )
          : {},
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'studentId': studentId,
      'studentName': studentName,
      'studentCode': studentCode,
      'score': score,
      'totalGrade': totalGrade,
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }
}
