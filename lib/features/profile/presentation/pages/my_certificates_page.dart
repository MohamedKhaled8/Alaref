import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  static const _primaryBlue = Color(0xFF335EF7);
  static const _darkText = Color(0xFF1A1D2E);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(child: Text('يجب تسجيل الدخول أولاً')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'شهاداتي الدراسية',
            style: TextStyle(
              color: _darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('exam_results')
              .where('studentId', isEqualTo: authUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'تعذر تحميل النتائج.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              );
            }

            final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
              snapshot.data?.docs ?? [],
            )..sort((a, b) {
                final ta = a.data()['submittedAt'];
                final tb = b.data()['submittedAt'];
                final da = ta is Timestamp ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                final db = tb is Timestamp ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                return db.compareTo(da);
              });

            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 72,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج امتحانات بعد',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'عند إتمام الامتحانات ستظهر درجاتك وشهادات النجاح هنا.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final result = ExamResult.fromMap(data);
                final passed =
                    result.totalGrade > 0 &&
                    result.percentage >= 50;

                return _ResultCard(
                  examId: result.examId,
                  score: result.score,
                  totalGrade: result.totalGrade,
                  percentage: result.percentage,
                  submittedAt: result.submittedAt,
                  passed: passed,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String examId;
  final int score;
  final int totalGrade;
  final double percentage;
  final DateTime submittedAt;
  final bool passed;

  const _ResultCard({
    required this.examId,
    required this.score,
    required this.totalGrade,
    required this.percentage,
    required this.submittedAt,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('exams')
                        .doc(examId)
                        .get(),
                    builder: (context, snap) {
                      final title = snap.data?.data()?['title'] as String?;
                      return Text(
                        title != null && title.isNotEmpty
                            ? title
                            : 'امتحان',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFF22C55E).withOpacity(0.12)
                        : const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    passed ? 'ناجح' : 'راسب',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: passed
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniStat(
                  label: 'الدرجة',
                  value: '$score / $totalGrade',
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  label: 'النسبة',
                  value: '${percentage.toStringAsFixed(0)}%',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(submittedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} — '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF335EF7),
          ),
        ),
      ],
    );
  }
}
