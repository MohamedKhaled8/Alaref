import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:alaref/core/utils/di/get_it.dart';
import 'package:alaref/core/utils/constant/color_manager.dart';
import 'package:alaref/features/home/presentation/screens/course_details_screen.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../manager/sessions_cubit.dart';
import '../manager/sessions_state.dart';
import '../../data/models/session_model.dart';

class RecentSessionsScreen extends StatelessWidget {
  const RecentSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionsCubit>()..loadSessions(),
      child: const _RecentSessionsView(),
    );
  }
}

class _RecentSessionsView extends StatelessWidget {
  const _RecentSessionsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.homeScaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A1D2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'أحدث الجلسات',
            style: TextStyle(
              color: const Color(0xFF1A1D2E),
              fontSize: 20.spScaled,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SessionsCubit, SessionsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF335EF7)),
              );
            }

            if (state.sessions.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 16.sh),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                return _SessionCard(session: state.sessions[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, _) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(28.sw),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF335EF7).withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 60.sw,
                      color: const Color(0xFF335EF7),
                    ),
                  ),
                  SizedBox(height: 24.sh),
                  Text(
                    'لا توجد جلسات بعد',
                    style: TextStyle(
                      fontSize: 18.spScaled,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                  SizedBox(height: 8.sh),
                  Text(
                    'ابدأ بمشاهدة حصة وستظهر هنا تلقائياً',
                    style: TextStyle(
                      fontSize: 14.spScaled,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;

  const _SessionCard({required this.session});

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sh),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToLesson(context),
          child: Container(
            padding: EdgeInsets.all(14.sw),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: session.lessonImageUrl.isNotEmpty &&
                            session.lessonImageUrl.startsWith('http')
                        ? Image.network(
                            session.lessonImageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => _buildThumbPlaceholder(),
                          )
                        : _buildThumbPlaceholder(),
                  ),
                ),
                SizedBox(width: 14.sw),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.lessonTitle,
                        style: TextStyle(
                          fontSize: 15.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1D2E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.sh),
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 14.sw,
                            color: const Color(0xFF335EF7),
                          ),
                          SizedBox(width: 4.sw),
                          Flexible(
                            child: Text(
                              session.teacherName,
                              style: TextStyle(
                                fontSize: 12.spScaled,
                                color: const Color(0xFF335EF7),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.sh),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.sw,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4.sw),
                          Text(
                            _formatTimeAgo(session.openedAt),
                            style: TextStyle(
                              fontSize: 11.spScaled,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder() {
    return Container(
      color: const Color(0xFFF0F2FF),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Color(0xFF335EF7),
          size: 32,
        ),
      ),
    );
  }

  Future<void> _navigateToLesson(BuildContext context) async {
    // Fetch the lesson from Firestore to navigate to full details
    try {
      final doc = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(session.lessonId)
          .get();

      if (doc.exists && context.mounted) {
        final lesson = LessonModel.fromMap(doc.data()!, doc.id);
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => CourseDetailsScreen(lesson: lesson),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الحصة')),
        );
      }
    }
  }
}
