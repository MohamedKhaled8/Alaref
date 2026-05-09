import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:alaref/features/lessons/presentation/manager/lessons_cubit.dart';
import 'package:alaref/features/lessons/presentation/manager/lessons_state.dart';
import 'home_lesson_horizontal_card.dart';

import 'package:alaref/core/utils/di/get_it.dart';

class HomeRecommendedSection extends StatelessWidget {
  const HomeRecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LessonsCubit>()..loadLessons(),
      child: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (context, state) {
          var weeklyLessons = state.lessons
              .where(
                (l) =>
                    l.isActive == true &&
                    l.isPackage != true &&
                    l.isCourse != true,
              )
              .take(10)
              .toList();

          final cardWidth = stv(
            context: context,
            mobile: otv(context: context, portrait: 78.w, landscape: 45.w),
            tablet: 40.w,
            desktop: 25.w,
          );

          // Show skeleton if loading and no data yet
          final showSkeleton = state.isLoading && weeklyLessons.isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.sw),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.ondemand_video_rounded,
                          size: 20.sw,
                          color: const Color(0xFFE91E63),
                        ),
                        SizedBox(width: 8.sw),
                        Text(
                          'محاضرات الأسبوع',
                          style: TextStyle(
                            fontSize: 17.spScaled,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1D2E),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: 13.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF335EF7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sh),
              if (showSkeleton)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 22.sw,
                    right: 22.sw,
                    bottom: 8.sh,
                  ),
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: EdgeInsets.only(left: i > 0 ? 16.sw : 0),
                        child: _SkeletonCard(width: cardWidth),
                      ),
                    ),
                  ),
                )
              else
                _WeeklyLessonsCarousel(
                  weeklyLessons: weeklyLessons,
                  cardWidth: cardWidth,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyLessonsCarousel extends StatefulWidget {
  final List<dynamic> weeklyLessons;
  final double cardWidth;

  const _WeeklyLessonsCarousel({
    required this.weeklyLessons,
    required this.cardWidth,
  });

  @override
  State<_WeeklyLessonsCarousel> createState() => _WeeklyLessonsCarouselState();
}

class _WeeklyLessonsCarouselState extends State<_WeeklyLessonsCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    if (widget.weeklyLessons.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final nextPage = (_currentPage + 1) % widget.weeklyLessons.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = otv(context: context, portrait: 320.sh, landscape: 280.sh);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.weeklyLessons.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final lesson = widget.weeklyLessons[index];
              final isActive = index == _currentPage;

              return AnimatedScale(
                scale: isActive ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isActive ? 1.0 : 0.8,
                  child: Center(
                    child: SizedBox(
                      width: widget.cardWidth,
                      child: HomeLessonHorizontalCard(lesson: lesson),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.sh),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.weeklyLessons.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.sw),
              height: 6.sh,
              width: isActive ? 16.sw : 6.sw,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF335EF7)
                    : const Color(0xFFCDD5F0),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final double width;
  const _SkeletonCard({required this.width});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerColor = ColorTween(
          begin: const Color(0xFFE8EAF0),
          end: const Color(0xFFF5F6FA),
        ).evaluate(_controller)!;

        return Container(
          width: widget.width,
          height: otv(context: context, portrait: 140.sh, landscape: 180.sh),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sw),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: widget.width * 0.6,
                  height: 16.sh,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: 12.sh),
                // Subtitle skeleton
                Container(
                  width: widget.width * 0.4,
                  height: 12.sh,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                // Bottom row skeleton
                Row(
                  children: [
                    Container(
                      width: 60.sw,
                      height: 12.sh,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80.sw,
                      height: 32.sh,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
