import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/exam_model.dart';

import '../cubit/dashboard_cubit.dart';
import 'admin_add_exam_page.dart';

class AdminExamsSettingsPage extends StatefulWidget {
  const AdminExamsSettingsPage({super.key});
  @override
  State<AdminExamsSettingsPage> createState() => _AdminExamsSettingsPageState();
}

class _AdminExamsSettingsPageState extends State<AdminExamsSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadExams();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: GestureDetector(
                onTap: () {
                  final dashboardCubit = context.read<DashboardCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: dashboardCubit,
                        child: const AdminAddExamPage(),
                      ),
                    ),
                  ).then((_) {
                    if (mounted) {
                      dashboardCubit.loadExams();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'إضافة امتحان جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: state is DashboardLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF335EF7),
                      ),
                    )
                  : state is ExamsLoaded
                  ? state.exams.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_rounded,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا يوجد امتحانات بعد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.exams.length,
                            itemBuilder: (context, index) {
                              final exam = state.exams[index] as ExamModel;
                              return _ExamCard(exam: exam);
                            },
                          )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Color(0xFFE91E63),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exam.durationMinutes} دقيقة',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.help_outline_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exam.questions.length} سؤال',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${exam.totalGrade} درجة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
