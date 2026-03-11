import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

class CourseInfoSection extends StatelessWidget {
  final LessonModel lesson;
  final int currentStudentsCount;

  const CourseInfoSection({
    super.key,
    required this.lesson,
    required this.currentStudentsCount,
  });

  String get studentsLabel {
    if (currentStudentsCount == 0) return ' طلبة';
    if (currentStudentsCount == 1) return ' طالب';
    if (currentStudentsCount == 2) return ' طالبان';
    if (currentStudentsCount >= 3 && currentStudentsCount <= 10) return ' طلبة';
    return ' طالب';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF335EF7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tags & Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF335EF7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'UI/UX Design',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF335EF7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              const Text(
                '4.8 (4,479 reviews)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (lesson.hasDiscount && lesson.discountPrice != null)
                    ? '${lesson.discountPrice!.toStringAsFixed(0)} ج.م'
                    : '${lesson.price.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF335EF7),
                ),
              ),
              const SizedBox(width: 8),
              if (lesson.hasDiscount && lesson.discountPrice != null)
                Text(
                  '${lesson.price.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                Icons.people_alt_outlined,
                '$currentStudentsCount$studentsLabel',
              ),
              _statItem(Icons.access_time_outlined, 'فيديو'),
              _statItem(Icons.find_in_page_outlined, 'شهادة إتمام'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
