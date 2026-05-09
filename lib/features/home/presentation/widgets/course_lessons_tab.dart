import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class CourseLessonsTab extends StatelessWidget {
  final LessonModel lesson;
  final bool isUnlocked;
  final void Function(String videoUrl) onPlayVideo;
  final VoidCallback onPaymentRequired;
  final void Function({
    required String examId,
    required int minScore,
    required VoidCallback onPassed,
  })
  onCheckExam;

  const CourseLessonsTab({
    super.key,
    required this.lesson,
    required this.isUnlocked,
    required this.onPlayVideo,
    required this.onPaymentRequired,
    required this.onCheckExam,
  });

  @override
  Widget build(BuildContext context) {
    final isPackage = lesson.isPackage;
    final itemsCount = isPackage ? lesson.packageItems.length : 1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.sw),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemsCount حصة',
                style: TextStyle(
                  fontSize: 17.spScaled,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1D2E),
                ),
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
          SizedBox(height: 16.sh),

          // ─── Progress bar (decorative) ───
          Container(
            height: 6.sh,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2FF),
              borderRadius: BorderRadius.circular(3.sh),
            ),
            child: FractionallySizedBox(
              widthFactor: isUnlocked || lesson.price == 0 ? 0.35 : 0.0,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF335EF7), Color(0xFF7B8FF7)],
                  ),
                  borderRadius: BorderRadius.circular(3.sh),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.sh),
          Text(
            isUnlocked || lesson.price == 0 ? '35% تم إنجازه' : 'اشترك للبدء',
            style: TextStyle(fontSize: 12.spScaled, color: Colors.grey[400]),
          ),
          SizedBox(height: 20.sh),

          // ─── Lessons List ───
          if (isPackage)
            ...lesson.packageItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              bool isLocked = !isUnlocked && lesson.price > 0 && index > 0;
              return _LessonCard(
                index: index + 1,
                title: item.title,
                duration: '10 دقيقة',
                isLocked: isLocked,
                videoUrl: item.videoUrl,
                requiresExam: item.requiresExam,
                examId: item.prerequisiteExamId,
                minScore: item.minimumPassScore,
                onTap: () {
                  if (isLocked) {
                    onPaymentRequired();
                  } else if (item.requiresExam &&
                      item.prerequisiteExamId != null) {
                    onCheckExam(
                      examId: item.prerequisiteExamId!,
                      minScore: item.minimumPassScore,
                      onPassed: () => onPlayVideo(item.videoUrl),
                    );
                  } else {
                    onPlayVideo(item.videoUrl);
                  }
                },
              );
            })
          else
            _LessonCard(
              index: 1,
              title: lesson.title,
              duration: '15 دقيقة',
              isLocked: !isUnlocked && lesson.price > 0,
              videoUrl: lesson.videoUrl,
              requiresExam: lesson.requiresExam,
              examId: lesson.prerequisiteExamId,
              minScore: lesson.minimumPassScore,
              onTap: () {
                if (!isUnlocked && lesson.price > 0) {
                  onPaymentRequired();
                } else if (lesson.requiresExam &&
                    lesson.prerequisiteExamId != null) {
                  onCheckExam(
                    examId: lesson.prerequisiteExamId!,
                    minScore: lesson.minimumPassScore,
                    onPassed: () => onPlayVideo(lesson.videoUrl),
                  );
                } else {
                  onPlayVideo(lesson.videoUrl);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int index;
  final String title;
  final String duration;
  final bool isLocked;
  final String videoUrl;
  final bool requiresExam;
  final String? examId;
  final int minScore;
  final VoidCallback onTap;

  const _LessonCard({
    required this.index,
    required this.title,
    required this.duration,
    required this.isLocked,
    required this.videoUrl,
    this.requiresExam = false,
    this.examId,
    this.minScore = 50,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.sh),
        padding: EdgeInsets.all(16.sw),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.sw),
          border: Border.all(
            color: isLocked
                ? Colors.grey.withOpacity(0.1)
                : const Color(0xFF335EF7).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Index circle
            Container(
              width: 44.sw,
              height: 44.sw,
              decoration: BoxDecoration(
                gradient: isLocked
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF335EF7), Color(0xFF7B8FF7)],
                      ),
                color: isLocked ? const Color(0xFFF5F5F5) : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLocked
                    ? Icon(
                        Icons.lock_outline,
                        color: Colors.grey[400],
                        size: 18.sw,
                      )
                    : Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 14.spScaled,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 14.sw),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.spScaled,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                  SizedBox(height: 6.sh),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.sw,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4.sw),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12.spScaled,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (requiresExam && examId != null) ...[
                        SizedBox(width: 8.sw),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sw,
                            vertical: 3.sh,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.sw),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.quiz_rounded,
                                size: 12.sw,
                                color: const Color(0xFFFF6B35),
                              ),
                              SizedBox(width: 4.sw),
                              Text(
                                'امتحان ($minScore%)',
                                style: TextStyle(
                                  fontSize: 10.spScaled,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Play icon
            Container(
              width: 40.sw,
              height: 40.sw,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey[100]
                    : const Color(0xFF335EF7).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isLocked
                      ? Icons.lock_outline
                      : (requiresExam && examId != null
                            ? Icons.quiz_outlined
                            : Icons.play_arrow_rounded),
                  color: isLocked
                      ? Colors.grey[400]
                      : (requiresExam && examId != null
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF335EF7)),
                  size: 22.sw,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
