import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

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

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$itemsCount Lessons',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const Text(
              'See All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Section 1 - Introduction',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2E),
              ),
            ),
            Text(
              '15 mins',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (isPackage)
          ...lesson.packageItems.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            bool isLocked = !isUnlocked && lesson.price > 0 && index > 0;
            return LessonTileItem(
              index: index + 1,
              title: item.title,
              duration: '10 mins',
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
          }).toList()
        else
          LessonTileItem(
            index: 1,
            title: lesson.title,
            duration: '15 mins',
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
    );
  }
}

class LessonTileItem extends StatelessWidget {
  final int index;
  final String title;
  final String duration;
  final bool isLocked;
  final String videoUrl;
  final bool requiresExam;
  final String? examId;
  final int minScore;
  final VoidCallback onTap;

  const LessonTileItem({
    super.key,
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey[100]
                    : const Color(0xFF335EF7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : const Color(0xFF335EF7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (requiresExam && examId != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.quiz_rounded,
                                size: 12,
                                color: Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'امتحان قبلي ($minScore%)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
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
            Icon(
              isLocked
                  ? Icons.lock_outline
                  : (requiresExam && examId != null
                        ? Icons.quiz_outlined
                        : Icons.play_circle_fill),
              color: isLocked
                  ? Colors.grey
                  : (requiresExam && examId != null
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF335EF7)),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
