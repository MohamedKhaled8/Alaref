import 'package:alaref/core/utils/helper/functions.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/exams/presentation/widgets/cooldown_screen_content.dart';
import 'package:alaref/features/home/presentation/cubit/course_details_cubit.dart';
import 'package:alaref/features/home/presentation/utils/course_details_functions.dart';
import 'package:alaref/features/home/presentation/widgets/course_about_tab.dart';
import 'package:alaref/features/home/presentation/widgets/course_exam_gate_screen.dart';
import 'package:alaref/features/home/presentation/widgets/course_info_section.dart';
import 'package:alaref/features/home/presentation/widgets/course_lessons_tab.dart';
import 'package:alaref/features/home/presentation/widgets/course_reviews_tab.dart';
import 'package:alaref/features/home/presentation/widgets/sliver_tab_bar_delegate.dart';
import 'package:alaref/features/home/presentation/widgets/youtube_player_view.dart';
import 'package:alaref/features/sessions/presentation/manager/sessions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// ========================
/// Course Details Screen — Stateless ✓
/// ========================
class CourseDetailsScreen extends StatelessWidget {
  final LessonModel lesson;

  const CourseDetailsScreen({super.key, required this.lesson});

  void _recordSession() {
    try {
      final cubit = GetIt.instance<SessionsCubit>();
      cubit.recordSession(
        lessonId: lesson.id,
        lessonTitle: lesson.title,
        lessonImageUrl: lesson.imageUrl,
        teacherName: lesson.teacherName,
      );
      cubit.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    _recordSession();

    return BlocProvider(
      create: (_) => CourseDetailsCubit(lesson: lesson)..initialize(),
      child: CourseDetailsView(lesson: lesson),
    );
  }
}

/// ========================
/// Course Details View — Stateless ✓
/// Uses DefaultTabController instead of Stateful TabController
/// ========================
class CourseDetailsView extends StatelessWidget {
  final LessonModel lesson;

  const CourseDetailsView({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        final cubit = context.read<CourseDetailsCubit>();

        // Loading states
        if (state is! CourseDetailsLoaded || state.checkingExamStatus) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF335EF7)),
            ),
          );
        }

        // Exam gate / cooldown
        if (lesson.requiresExam &&
            lesson.prerequisiteExamId != null &&
            !state.hasPassedExam) {
          if (state.cooldownUntil != null &&
              state.cooldownUntil!.isAfter(DateTime.now())) {
            return CooldownScreenContent(
              nextRetakeTime: state.cooldownUntil!,
              onExit: () => Navigator.pop(context),
            );
          }
          return CourseExamGateScreen(
            lesson: lesson,
            onStartExam: () => checkAndHandleExam(
              context: context,
              cubit: cubit,
              examId: lesson.prerequisiteExamId!,
              minScore: lesson.minimumPassScore,
              onPassed: () => cubit.setPassedExam(),
            ),
          );
        }

        // DefaultTabController replaces Stateful TabController
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: _CourseDetailsBody(
              lesson: lesson,
              state: state,
              cubit: cubit,
            ),
          ),
        );
      },
    );
  }
}

/// ========================
/// Body — all stateless ✓
/// ========================
class _CourseDetailsBody extends StatelessWidget {
  final LessonModel lesson;
  final CourseDetailsLoaded state;
  final CourseDetailsCubit cubit;

  const _CourseDetailsBody({
    required this.lesson,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final isFreeOrUnlocked = state.isUnlocked || lesson.price == 0;
    final needsExam = lesson.requiresExam && !state.hasPassedExam;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── 1. Video / Cover Hero ───
            SliverAppBar(
              expandedHeight: stv(
                context: context,
                mobile: otv(
                  context: context,
                  portrait: 260.sh,
                  landscape: 320.sh,
                ),
                tablet: 360.sh,
                desktop: 420.sh,
              ),
              collapsedHeight: 60.sh,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF1A1D2E),
              leading: _CircularBackButton(onTap: () => Navigator.pop(context)),
              actions: [
                _CircularActionButton(icon: Icons.share_rounded, onTap: () {}),
                SizedBox(width: 8.sw),
                _CircularActionButton(
                  icon: Icons.bookmark_border_rounded,
                  onTap: () {},
                ),
                SizedBox(width: 16.sw),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: state.isPlayingVideo
                    ? YoutubePlayerView(
                        videoId:
                            extractYoutubeVideoId(state.currentVideoUrl) ?? '',
                      )
                    : _VideoCoverOverlay(
                        lesson: lesson,
                        state: state,
                        cubit: cubit,
                      ),
              ),
            ),

            // ─── 2. Info Card ───
            SliverToBoxAdapter(
              child: CourseInfoSection(
                lesson: lesson,
                currentStudentsCount: state.currentStudentsCount,
              ),
            ),

            // ─── 3. Tab Bar ───
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(
                TabBar(
                  labelColor: const Color(0xFF335EF7),
                  unselectedLabelColor: Colors.grey[400],
                  indicatorColor: const Color(0xFF335EF7),
                  indicatorWeight: 3,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.spScaled,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.spScaled,
                  ),
                  tabs: const [
                    Tab(text: 'نبذة'),
                    Tab(text: 'الحصص'),
                    Tab(text: 'التقييمات'),
                  ],
                ),
              ),
            ),

            // ─── 4. Tab Content ───
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CourseAboutTab(
                    lesson: lesson,
                    teacherImageUrl: state.teacherImageUrl,
                    teacherSubject: state.teacherSubject,
                    isDescriptionExpanded: state.isDescriptionExpanded,
                    onToggleDescription: cubit.toggleDescription,
                  ),
                  CourseLessonsTab(
                    lesson: lesson,
                    isUnlocked: state.isUnlocked,
                    onPlayVideo: cubit.playVideo,
                    onPaymentRequired: () => showPaymentRequiredSnackBar(
                      context: context,
                      cubit: cubit,
                    ),
                    onCheckExam:
                        ({
                          required examId,
                          required minScore,
                          required onPassed,
                        }) {
                          checkAndHandleExam(
                            context: context,
                            cubit: cubit,
                            examId: examId,
                            minScore: minScore,
                            onPassed: onPassed,
                          );
                        },
                  ),
                  CourseReviewsTab(
                    lessonId: lesson.id,
                    onSubmitComment: cubit.submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),

        // ─── 5. Sticky Bottom Bar ───
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.sw, vertical: 16.sh),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.sw)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Price tag (when not unlocked)
                  if (!isFreeOrUnlocked) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'السعر',
                          style: TextStyle(
                            fontSize: 12.spScaled,
                            color: Colors.grey[500],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${(lesson.hasDiscount && lesson.discountPrice != null) ? lesson.discountPrice!.toStringAsFixed(0) : lesson.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 22.spScaled,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF335EF7),
                              ),
                            ),
                            SizedBox(width: 4.sw),
                            Text(
                              'ج.م',
                              style: TextStyle(
                                fontSize: 14.spScaled,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF335EF7),
                              ),
                            ),
                          ],
                        ),
                        if (lesson.hasDiscount && lesson.discountPrice != null)
                          Text(
                            '${lesson.price.toStringAsFixed(0)} ج.م',
                            style: TextStyle(
                              fontSize: 12.spScaled,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 16.sw),
                  ],

                  // Main CTA
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => handleVideoTap(
                        context: context,
                        cubit: cubit,
                        state: state,
                        lessonPrice: lesson.price,
                        videoUrl: lesson.videoUrl,
                        requiresExam: lesson.requiresExam,
                        prerequisiteExamId: lesson.prerequisiteExamId,
                        minimumPassScore: lesson.minimumPassScore,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFreeOrUnlocked
                            ? (needsExam
                                  ? const Color(0xFFFF6B35)
                                  : const Color(0xFF4CAF50))
                            : const Color(0xFF335EF7),
                        padding: EdgeInsets.symmetric(vertical: 16.sh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.sw),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFreeOrUnlocked
                                ? (needsExam
                                      ? Icons.quiz_rounded
                                      : Icons.play_circle_fill_rounded)
                                : Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 22.sw,
                          ),
                          SizedBox(width: 8.sw),
                          Text(
                            isFreeOrUnlocked
                                ? (needsExam
                                      ? 'ابدأ الامتحان'
                                      : 'مشاهدة الفيديو')
                                : 'اشترك الآن',
                            style: TextStyle(
                              fontSize: 16.spScaled,
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
            ),
          ),
        ),
      ],
    );
  }
}

/// ========================
/// Video Cover Overlay — stateless ✓
/// ========================
class _VideoCoverOverlay extends StatelessWidget {
  final LessonModel lesson;
  final CourseDetailsLoaded state;
  final CourseDetailsCubit cubit;

  const _VideoCoverOverlay({
    required this.lesson,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final isFreeOrUnlocked = state.isUnlocked || lesson.price == 0;
    final needsExam = lesson.requiresExam && !state.hasPassedExam;

    return GestureDetector(
      onTap: () => handleVideoTap(
        context: context,
        cubit: cubit,
        state: state,
        lessonPrice: lesson.price,
        videoUrl: lesson.videoUrl,
        requiresExam: lesson.requiresExam,
        prerequisiteExamId: lesson.prerequisiteExamId,
        minimumPassScore: lesson.minimumPassScore,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (lesson.imageUrl.startsWith('http'))
            Image.network(
              lesson.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBg(),
            )
          else
            _fallbackBg(),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Exam lock overlay
          if (isFreeOrUnlocked && needsExam)
            _ExamLockOverlay(cubit: cubit, lesson: lesson, state: state)
          else
            _PlayButtonOverlay(isUnlocked: isFreeOrUnlocked),
        ],
      ),
    );
  }

  Widget _fallbackBg() {
    return Container(
      color: const Color(0xFF1A1D2E),
      child: const Center(
        child: Icon(Icons.video_library, color: Colors.white24, size: 64),
      ),
    );
  }
}

/// ─── Play Button Overlay ───
class _PlayButtonOverlay extends StatelessWidget {
  final bool isUnlocked;
  const _PlayButtonOverlay({required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.sw,
            height: 72.sw,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFF335EF7)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFF335EF7).withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
              border: isUnlocked
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Icon(
                isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                color: Colors.white,
                size: 36.sw,
              ),
            ),
          ),
          if (isUnlocked) ...[
            SizedBox(height: 12.sh),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 6.sh),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'اضغط للمشاهدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.spScaled,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ─── Exam Lock Overlay ───
class _ExamLockOverlay extends StatelessWidget {
  final CourseDetailsCubit cubit;
  final LessonModel lesson;
  final CourseDetailsLoaded state;

  const _ExamLockOverlay({
    required this.cubit,
    required this.lesson,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.sw),
        padding: EdgeInsets.all(24.sw),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24.sw),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_rounded, color: Colors.white, size: 48.sw),
            SizedBox(height: 16.sh),
            Text(
              'يتطلب اجتياز الامتحان أولاً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.spScaled,
              ),
            ),
            SizedBox(height: 8.sh),
            Text(
              'يجب الحصول على ${lesson.minimumPassScore}% على الأقل',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13.spScaled,
              ),
            ),
            SizedBox(height: 20.sh),
            ElevatedButton.icon(
              onPressed: () => handleVideoTap(
                context: context,
                cubit: cubit,
                state: state,
                lessonPrice: lesson.price,
                videoUrl: lesson.videoUrl,
                requiresExam: lesson.requiresExam,
                prerequisiteExamId: lesson.prerequisiteExamId,
                minimumPassScore: lesson.minimumPassScore,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.sw,
                  vertical: 12.sh,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sw),
                ),
              ),
              icon: const Icon(Icons.quiz_rounded),
              label: Text(
                'افتح الامتحان',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.spScaled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Circular Back Button ───
class _CircularBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircularBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.sw),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.sw,
          height: 40.sw,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sw),
        ),
      ),
    );
  }
}

/// ─── Circular Action Button ───
class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircularActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.sw,
        height: 40.sw,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20.sw),
      ),
    );
  }
}
