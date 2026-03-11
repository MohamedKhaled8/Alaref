import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import 'home_lesson_horizontal_card.dart';

class HomeRecommendedSection extends StatelessWidget {
  const HomeRecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final weeklyLessons = state.lessons
            .where((l) => l.isActive && !l.isPackage)
            .take(5)
            .toList();

        final cardWidth = MediaQuery.of(context).size.width * 0.78;

        // Show skeleton if loading and no data yet
        final showSkeleton = state.isLoading && weeklyLessons.isEmpty;

        if (!showSkeleton && weeklyLessons.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.ondemand_video_rounded,
                        size: 20,
                        color: Color(0xFFE91E63),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'محاضرات الأسبوع',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF335EF7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (showSkeleton)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 22, right: 22, bottom: 8),
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 16 : 0),
                      child: _SkeletonCard(width: cardWidth),
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 22, right: 22, bottom: 8),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < weeklyLessons.length; i++) ...[
                        SizedBox(
                          width: cardWidth,
                          child: HomeLessonHorizontalCard(
                            lesson: weeklyLessons[i],
                          ),
                        ),
                        if (i < weeklyLessons.length - 1)
                          const SizedBox(width: 16),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
          height: 180,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: widget.width * 0.6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle skeleton
                Container(
                  width: widget.width * 0.4,
                  height: 12,
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
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 32,
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
