import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lesson_model.dart';
import '../cubit/dashboard_cubit.dart';
import 'admin_add_lesson_page.dart';

class AdminCoursesVideosPage extends StatefulWidget {
  const AdminCoursesVideosPage({super.key});

  @override
  State<AdminCoursesVideosPage> createState() => _AdminCoursesVideosPageState();
}

class _AdminCoursesVideosPageState extends State<AdminCoursesVideosPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, listenState) {
        if (!context.mounted) return;
        if (listenState is LessonAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم رفع الحصة بنجاح ✓'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<DashboardCubit>().loadLessons();
        } else if (listenState is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${listenState.message}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final dashboardCubit = context.read<DashboardCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: dashboardCubit,
                    child: const AdminAddLessonPage(),
                  ),
                ),
              ).then((_) {
                if (context.mounted) {
                  dashboardCubit.loadLessons();
                }
              });
            },
            backgroundColor: const Color(0xFFFF9800),
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'رفع حصة / باقة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          body: state is DashboardLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF335EF7)),
                )
              : state is LessonsLoaded
              ? state.lessons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد حصص بعد',
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
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 100, // padding for FAB
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = state.lessons[index] as LessonModel;
                          return _LessonCard(lesson: lesson);
                        },
                      )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image & Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child:
                      (lesson.imageUrl.isNotEmpty &&
                          Uri.tryParse(lesson.imageUrl)?.hasAbsolutePath ==
                              true)
                      ? Image.network(
                          lesson.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: lesson.isActive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lesson.isActive
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lesson.isActive ? 'متاح للطلاب' : 'مغلق / مخفي',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Package Badge
              if (lesson.isPackage)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'باقة (${lesson.packageItems.length} حصص)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D2E),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF335EF7,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.school_rounded,
                                      size: 14,
                                      color: Color(0xFF335EF7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      lesson.teacherName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF335EF7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'السعر',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lesson.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'ج.م',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // 3. Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: lesson.isActive
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        label: lesson.isActive ? 'إخفاء' : 'إظهار',
                        color: lesson.isActive
                            ? Colors.grey[700]!
                            : const Color(0xFF4CAF50),
                        backgroundColor: lesson.isActive
                            ? Colors.grey[200]!
                            : const Color(0xFF4CAF50).withOpacity(0.1),
                        onTap: () {
                          context.read<DashboardCubit>().toggleLessonStatus(
                            lesson.id,
                            !lesson.isActive,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      label: 'تعديل',
                      color: const Color(0xFF335EF7),
                      backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
                      onTap: () {
                        final dashboardCubit = context.read<DashboardCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: dashboardCubit,
                              child: AdminAddLessonPage(lessonToEdit: lesson),
                            ),
                          ),
                        ).then((_) {
                          if (context.mounted) dashboardCubit.loadLessons();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_forever_rounded,
                      label: 'حذف',
                      color: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      onTap: () {
                        _showDeleteDialog(context);
                      },
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_rounded,
              size: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد صورة',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه الحصة نهائياً؟ هذا الإجراء لا يمكن التراجع عنه وسيحذف الكورس أو الباقة وكل بياناتها.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardCubit>().deleteLesson(lesson.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'تأكيد الحذف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
