import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/presentation/pages/exam_taking_screen.dart';
import 'package:alaref/features/exams/presentation/widgets/exam_info_chip.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final bool isTaken;
  final int? score;
  final VoidCallback onReturn;

  static const primaryColor = Color(0xFF335EF7);
  static const darkColor = Color(0xFF1A1D2E);
  static const greenColor = Color(0xFF22C55E);

  const ExamCard({
    super.key,
    required this.exam,
    required this.isTaken,
    required this.score,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final totalGrade = exam.totalGrade;
    final pct = (isTaken && totalGrade > 0 && score != null)
        ? (score! / totalGrade * 100)
        : 0.0;
    final passed = pct >= 50;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam)),
            );
            onReturn();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isTaken
                  ? Border.all(color: greenColor.withOpacity(0.3), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isTaken ? greenColor : primaryColor).withOpacity(
                    0.06,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Exam icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isTaken
                            ? const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                              ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isTaken
                            ? Icons.check_circle_rounded
                            : Icons.quiz_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Exam info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (exam.teacherName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                exam.teacherName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          // Info chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ExamInfoChip(
                                icon: Icons.timer_rounded,
                                label: '${exam.durationMinutes} دقيقة',
                              ),
                              ExamInfoChip(
                                icon: Icons.help_outline_rounded,
                                label: '${exam.questions.length} سؤال',
                              ),
                              ExamInfoChip(
                                icon: Icons.grade_rounded,
                                label: '$totalGrade درجة',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge or arrow
                    if (isTaken)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (passed ? greenColor : const Color(0xFFEF4444))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${pct.toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: passed
                                ? greenColor
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                // Show score bar if taken
                if (isTaken) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'درجتك: $score / $totalGrade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'تم الحل ✓',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: greenColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation(
                        passed ? greenColor : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
