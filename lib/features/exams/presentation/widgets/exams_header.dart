import 'package:flutter/material.dart';
import 'package:alaref/features/exams/presentation/widgets/exam_mini_stat.dart';

class ExamsHeader extends StatelessWidget {
  final int totalExams;
  final int takenCount;

  static const primaryColor = Color(0xFF335EF7);
  static const darkColor = Color(0xFF1A1D2E);
  static const greenColor = Color(0xFF22C55E);

  const ExamsHeader({
    super.key,
    required this.totalExams,
    required this.takenCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          // Background decorative element
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'بنك الامتحانات',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_graph_rounded,
                                color: primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'طور مهاراتك بشكل مستمر',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Glassmorphism stats container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: darkColor.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ExamMiniStat(
                        icon: Icons.assignment_rounded,
                        label: 'امتحان',
                        value: '$totalExams',
                        color: primaryColor,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      ExamMiniStat(
                        icon: Icons.check_circle_rounded,
                        label: 'مكتمل',
                        value: '$takenCount',
                        color: greenColor,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      ExamMiniStat(
                        icon: Icons.pending_actions_rounded,
                        label: 'متبقي',
                        value: '${(totalExams - takenCount).clamp(0, 999)}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
