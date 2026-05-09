import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import '../manager/lessons_cubit.dart';
import 'package:alaref/features/lessons/presentation/manager/lessons_state.dart';
import 'package:alaref/features/home/presentation/widgets/home_lesson_horizontal_card.dart';

import 'package:alaref/core/utils/di/get_it.dart';

class LatestLessonsSectionWidget extends StatelessWidget {
  const LatestLessonsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LessonsCubit>()..loadLessons(),
      child: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (context, state) {
          var lessons = state.lessons
              .where((l) =>
                  l.isActive == true &&
                  l.isPackage != true &&
                  l.isCourse != true)
              .take(10)
              .toList();

          final showSkeleton = state.isLoading && lessons.isEmpty;

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
                          Icons.star_rounded,
                          size: 22.sw,
                          color: const Color(0xFFFFC107),
                        ),
                        SizedBox(width: 8.sw),
                        Text(
                          'أحدث الحصص',
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.sw),
                  child: Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: i < 2 ? 14.sh : 0),
                        child: _SkeletonListCard(),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 22.sw),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14.sh),
                  itemBuilder: (context, i) {
                    final lesson = lessons[i];
                    return HomeLessonHorizontalCard(lesson: lesson);
                  },
                ),
            ],
          );
        },
      ),
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
          height: 100.sh,
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
            padding: EdgeInsets.all(14.sw),
            child: Row(
              children: [
                Container(
                  width: 56.sw,
                  height: 56.sh,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                SizedBox(width: 14.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14.sh,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      SizedBox(height: 10.sh),
                      Container(
                        width: 120.sw,
                        height: 10.sh,
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
