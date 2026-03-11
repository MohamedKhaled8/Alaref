import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';

class AdminStatisticsPage extends StatelessWidget {
  final void Function(int)? onNavigate;
  const AdminStatisticsPage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF335EF7)),
          );
        }

        int totalUsers = 0;
        int totalLessons = 0;
        int totalExams = 0;
        int totalCodes = 0;
        int usedCodes = 0;
        int totalTeachers = 0;

        if (state is StatisticsLoaded) {
          totalUsers = state.totalUsers;
          totalLessons = state.totalLessons;
          totalExams = state.totalExams;
          totalCodes = state.totalCodes;
          usedCodes = state.usedCodes;
          totalTeachers = state.totalTeachers;
        }

        return RefreshIndicator(
          color: const Color(0xFF335EF7),
          onRefresh: () => context.read<DashboardCubit>().loadStatistics(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نظرة عامة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'إحصائيات المنصة في لمحة واحدة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _StatCard(
                      title: 'إجمالي الطلاب',
                      value: '$totalUsers',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF335EF7),
                      gradient: const [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                    ),
                    _StatCard(
                      title: 'المدرسين',
                      value: '$totalTeachers',
                      icon: Icons.school_rounded,
                      color: const Color(0xFF4CAF50),
                      gradient: const [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    _StatCard(
                      title: 'الدروس',
                      value: '$totalLessons',
                      icon: Icons.video_library_rounded,
                      color: const Color(0xFFFF9800),
                      gradient: const [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    ),
                    _StatCard(
                      title: 'الامتحانات',
                      value: '$totalExams',
                      icon: Icons.quiz_rounded,
                      color: const Color(0xFFE91E63),
                      gradient: const [Color(0xFFE91E63), Color(0xFFFF4081)],
                    ),
                    _StatCard(
                      title: 'الأكواد المتاحة',
                      value: '${totalCodes - usedCodes}',
                      icon: Icons.qr_code_rounded,
                      color: const Color(0xFF9C27B0),
                      gradient: const [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                    ),
                    _StatCard(
                      title: 'الأكواد المستخدمة',
                      value: '$usedCodes',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF00BCD4),
                      gradient: const [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick Actions
                const Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 14),
                _QuickActionRow(
                  onActionTapped: (index) {
                    if (onNavigate != null) {
                      if (index == 0)
                        onNavigate!(2); // Teachers
                      else if (index == 1)
                        onNavigate!(3); // Lessons
                      else if (index == 2)
                        onNavigate!(4); // Codes
                    }
                  },
                  actions: [
                    const _QuickAction(
                      'إضافة مدرس',
                      Icons.person_add_rounded,
                      Color(0xFF4CAF50),
                    ),
                    const _QuickAction(
                      'رفع حصة',
                      Icons.upload_file_rounded,
                      Color(0xFFFF9800),
                    ),
                    const _QuickAction(
                      'توليد كود',
                      Icons.qr_code_scanner_rounded,
                      Color(0xFF9C27B0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(this.label, this.icon, this.color);
}

class _QuickActionRow extends StatelessWidget {
  final List<_QuickAction> actions;
  final void Function(int) onActionTapped;
  const _QuickActionRow({required this.actions, required this.onActionTapped});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onActionTapped(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
