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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// الصفحة الرئيسة — تفاصيل الحصة/الباقة
class CourseDetailsScreen extends StatelessWidget {
  final LessonModel lesson;

  const CourseDetailsScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailsCubit(lesson: lesson)..initialize(),
      child: CourseDetailsView(lesson: lesson),
    );
  }
}

/// الـ View — تحتاج TabController فلازم StatefulWidget
/// لكن كل الـ logic في الـ Cubit والـ functions في ملفات منفصلة
class CourseDetailsView extends StatefulWidget {
  final LessonModel lesson;

  const CourseDetailsView({super.key, required this.lesson});

  @override
  State<CourseDetailsView> createState() => CourseDetailsViewState();
}

class CourseDetailsViewState extends State<CourseDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        final cubit = context.read<CourseDetailsCubit>();

        if (state is! CourseDetailsLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF335EF7)),
            ),
          );
        }

        if (state.checkingExamStatus) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF335EF7)),
            ),
          );
        }

        // Exam gate check
        if (widget.lesson.requiresExam &&
            widget.lesson.prerequisiteExamId != null &&
            !state.hasPassedExam) {
          if (state.cooldownUntil != null &&
              state.cooldownUntil!.isAfter(DateTime.now())) {
            return CooldownScreenContent(
              nextRetakeTime: state.cooldownUntil!,
              onExit: () => Navigator.pop(context),
            );
          }
          return CourseExamGateScreen(
            lesson: widget.lesson,
            onStartExam: () {
              checkAndHandleExam(
                context: context,
                cubit: cubit,
                examId: widget.lesson.prerequisiteExamId!,
                minScore: widget.lesson.minimumPassScore,
                onPassed: () => cubit.setPassedExam(),
              );
            },
          );
        }

        // Main content
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. Cover / Video Area
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: const Color(0xFF1A1D2E),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: state.isPlayingVideo
                          ? YoutubePlayerView(
                              videoId:
                                  extractYoutubeVideoId(
                                    state.currentVideoUrl,
                                  ) ??
                                  '',
                            )
                          : GestureDetector(
                              onTap: () => handleVideoTap(
                                context: context,
                                cubit: cubit,
                                state: state,
                                lessonPrice: widget.lesson.price,
                                videoUrl: widget.lesson.videoUrl,
                                requiresExam: widget.lesson.requiresExam,
                                prerequisiteExamId:
                                    widget.lesson.prerequisiteExamId,
                                minimumPassScore:
                                    widget.lesson.minimumPassScore,
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (widget.lesson.imageUrl.startsWith('http'))
                                    Image.network(
                                      widget.lesson.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.black87),
                                    )
                                  else
                                    Container(color: Colors.black87),
                                  Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  if ((state.isUnlocked ||
                                          widget.lesson.price == 0) &&
                                      widget.lesson.requiresExam &&
                                      !state.hasPassedExam) ...[
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.lock_person_rounded,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'يتطلب اجتياز الامتحان أولاً',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: () => handleVideoTap(
                                              context: context,
                                              cubit: cubit,
                                              state: state,
                                              lessonPrice: widget.lesson.price,
                                              videoUrl: widget.lesson.videoUrl,
                                              requiresExam:
                                                  widget.lesson.requiresExam,
                                              prerequisiteExamId: widget
                                                  .lesson
                                                  .prerequisiteExamId,
                                              minimumPassScore: widget
                                                  .lesson
                                                  .minimumPassScore,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFF6B35,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            icon: const Icon(
                                              Icons.quiz_rounded,
                                            ),
                                            label: const Text(
                                              'افتح الامتحان',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              (state.isUnlocked ||
                                                  widget.lesson.price == 0)
                                              ? const Color(0xFF335EF7)
                                              : Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          boxShadow:
                                              (state.isUnlocked ||
                                                  widget.lesson.price == 0)
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF335EF7,
                                                    ).withOpacity(0.4),
                                                    blurRadius: 15,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          (state.isUnlocked ||
                                                  widget.lesson.price == 0)
                                              ? Icons.play_arrow_rounded
                                              : Icons.lock_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    if (state.isUnlocked ||
                                        widget.lesson.price == 0)
                                      Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'اضغط لمشاهدة الفيديو',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ),

                  // 2. Course Info
                  SliverToBoxAdapter(
                    child: CourseInfoSection(
                      lesson: widget.lesson,
                      currentStudentsCount: state.currentStudentsCount,
                    ),
                  ),

                  // 3. Tab Bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverTabBarDelegate(
                      TabBar(
                        controller: tabController,
                        labelColor: const Color(0xFF335EF7),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF335EF7),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        tabs: const [
                          Tab(text: 'About'),
                          Tab(text: 'Lessons'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                  ),

                  // 4. Tab Content
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          CourseAboutTab(
                            lesson: widget.lesson,
                            teacherImageUrl: state.teacherImageUrl,
                            teacherSubject: state.teacherSubject,
                            isDescriptionExpanded: state.isDescriptionExpanded,
                            onToggleDescription: () =>
                                cubit.toggleDescription(),
                          ),
                          CourseLessonsTab(
                            lesson: widget.lesson,
                            isUnlocked: state.isUnlocked,
                            onPlayVideo: (url) => cubit.playVideo(url),
                            onPaymentRequired: () =>
                                showPaymentRequiredSnackBar(
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
                            lessonId: widget.lesson.id,
                            commentController: commentController,
                            onSubmitComment: () async {
                              final text = commentController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('اكتب تعليقك أولاً'),
                                  ),
                                );
                                return;
                              }
                              try {
                                await cubit.submitComment(text);
                                commentController.clear();
                                FocusScope.of(context).unfocus();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'تم إضافة تعليقك بنجاح ✓',
                                      ),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('خطأ في إرسال التعليق: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 5. Sticky Bottom Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => handleVideoTap(
                      context: context,
                      cubit: cubit,
                      state: state,
                      lessonPrice: widget.lesson.price,
                      videoUrl: widget.lesson.videoUrl,
                      requiresExam: widget.lesson.requiresExam,
                      prerequisiteExamId: widget.lesson.prerequisiteExamId,
                      minimumPassScore: widget.lesson.minimumPassScore,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (state.isUnlocked || widget.lesson.price == 0)
                          ? (widget.lesson.requiresExam && !state.hasPassedExam
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF4CAF50))
                          : const Color(0xFF335EF7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          (state.isUnlocked || widget.lesson.price == 0)
                              ? (widget.lesson.requiresExam &&
                                        !state.hasPassedExam
                                    ? Icons.quiz_rounded
                                    : Icons.play_circle_fill_rounded)
                              : Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (state.isUnlocked || widget.lesson.price == 0)
                              ? (widget.lesson.requiresExam &&
                                        !state.hasPassedExam
                                    ? 'امتحان قبلي مطلوب - ابدأ الآن'
                                    : 'مشاهدة الفيديو')
                              : 'اشتراك - ${(widget.lesson.hasDiscount && widget.lesson.discountPrice != null) ? widget.lesson.discountPrice!.toStringAsFixed(0) : widget.lesson.price.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
