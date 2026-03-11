import 'package:alaref/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_lesson_horizontal_card.dart';

class HomePopularSection extends StatelessWidget {
  const HomePopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final lessons = state.lessons
            .where((l) => !l.isPackage)
            .take(5)
            .toList();

        final showSkeleton = state.isLoading && lessons.isEmpty;
        if (!showSkeleton && lessons.isEmpty) return const SizedBox.shrink();

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
                        Icons.star_rounded,
                        size: 22,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'أحدث الحصص',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < 2 ? 14 : 0),
                      child: _SkeletonListCard(),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final lesson = lessons[i];
                  return HomeLessonHorizontalCard(lesson: lesson);
                },
              ),
          ],
        );
      },
    );
  }
}

class _SkeletonListCard extends StatefulWidget {
  @override
  State<_SkeletonListCard> createState() => _SkeletonListCardState();
}

class _SkeletonListCardState extends State<_SkeletonListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final c = ColorTween(
          begin: const Color(0xFFE8EAF0),
          end: const Color(0xFFF5F6FA),
        ).evaluate(_ctrl)!;

        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
