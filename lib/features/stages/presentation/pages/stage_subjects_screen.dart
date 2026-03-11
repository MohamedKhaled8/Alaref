import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alaref/core/utils/enums/stage.dart';
import '../cubit/stage_subjects_cubit.dart';

// ============================================
// STAGE SUBJECTS SCREEN - مواد داخل المرحلة
// ============================================
class StageSubjectsScreen extends StatelessWidget {
  final Stage stage;
  final String stageName;

  const StageSubjectsScreen({
    super.key,
    required this.stage,
    required this.stageName,
  });

  static const List<Map<String, dynamic>> _subjects = [
    {
      'title': 'النحو',
      'icon': Icons.auto_fix_high_rounded,
      'color': Color(0xFF5E35B1),
      'done': 3,
      'total': 12,
    },
    {
      'title': 'الصرف',
      'icon': Icons.transform_rounded,
      'color': Color(0xFF00897B),
      'done': 0,
      'total': 10,
    },
    {
      'title': 'الإملاء',
      'icon': Icons.edit_note_rounded,
      'color': Color(0xFFD84315),
      'done': 5,
      'total': 8,
    },
    {
      'title': 'البلاغة',
      'icon': Icons.volunteer_activism_rounded,
      'color': Color(0xFF6A1B9A),
      'done': 2,
      'total': 15,
    },
    {
      'title': 'النصوص',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF0277BD),
      'done': 8,
      'total': 14,
    },
    {
      'title': 'القراءة',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF2E7D32),
      'done': 4,
      'total': 9,
    },
    {
      'title': 'التعبير',
      'icon': Icons.draw_rounded,
      'color': Color(0xFFEF6C00),
      'done': 0,
      'total': 6,
    },
    {
      'title': 'الخط',
      'icon': Icons.brush_rounded,
      'color': Color(0xFF37474F),
      'done': 1,
      'total': 5,
    },
  ];

  int get _totalVideos => _subjects.fold(0, (s, e) => s + (e['total'] as int));
  int get _completedVideos =>
      _subjects.fold(0, (s, e) => s + (e['done'] as int));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StageSubjectsCubit(_subjects.length),
      child: _StageSubjectsView(
        stageName: stageName,
        completedVideos: _completedVideos,
        totalVideos: _totalVideos,
        subjects: _subjects,
      ),
    );
  }
}

class _StageSubjectsView extends StatelessWidget {
  final String stageName;
  final int completedVideos;
  final int totalVideos;
  final List<Map<String, dynamic>> subjects;

  const _StageSubjectsView({
    required this.stageName,
    required this.completedVideos,
    required this.totalVideos,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFF212121),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'المرحلة $stageName',
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _StudentProgressCard(
                completed: completedVideos,
                total: totalVideos,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'موادك',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<StageSubjectsCubit, StageSubjectsState>(
            builder: (context, state) {
              final visibleCount = state.visibleCount;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subject = subjects[index];
                    final visible = index < visibleCount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectRowCard(
                        visible: visible,
                        index: index,
                        title: subject['title'] as String,
                        icon: subject['icon'] as IconData,
                        color: subject['color'] as Color,
                        done: subject['done'] as int,
                        total: subject['total'] as int,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${subject['title']} — ${subject['done']} من ${subject['total']} فيديو',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: subjects.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ——— شريط تقدم الطالب (أنيميشن + شكل دراسي) ———
class _StudentProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _StudentProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progressValue = total > 0 ? completed / total : 0.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF335EF7),
            const Color(0xFF335EF7).withOpacity(0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF335EF7).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تقدمك في الفيديوهات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'أكملت $completed من $total فيديو',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${total > 0 ? ((completed / total) * 100).round() : 0}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progressValue),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ——— كارت مادة واحد (صف أفقي + شريط تقدم مصغّر) ———
class _SubjectRowCard extends StatelessWidget {
  final bool visible;
  final int index;
  final String title;
  final IconData icon;
  final Color color;
  final int done;
  final int total;
  final VoidCallback onTap;

  const _SubjectRowCard({
    required this.visible,
    required this.index,
    required this.title,
    required this.icon,
    required this.color,
    required this.done,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? done / total : 0.0;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: Duration(milliseconds: 350 + (index * 40)),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0.15, 0),
        duration: Duration(milliseconds: 400 + (index * 50)),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: color.withOpacity(0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$done/$total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
