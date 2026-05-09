import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class CourseInfoSection extends StatelessWidget {
  final LessonModel lesson;
  final int currentStudentsCount;

  const CourseInfoSection({
    super.key,
    required this.lesson,
    required this.currentStudentsCount,
  });

  String get _studentsLabel {
    if (currentStudentsCount == 0) return 'طالب';
    if (currentStudentsCount == 1) return 'طالب';
    if (currentStudentsCount == 2) return 'طالبان';
    if (currentStudentsCount >= 3 && currentStudentsCount <= 10) return 'طلاب';
    return 'طالب';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sw),
      padding: EdgeInsets.all(20.sw),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.sw),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title + Bookmark ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 22.spScaled,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1D2E),
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 12.sw),
              Container(
                width: 40.sw,
                height: 40.sw,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(12.sw),
                ),
                child: Icon(
                  Icons.bookmark_border_rounded,
                  color: const Color(0xFF335EF7),
                  size: 22.sw,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sh),

          // ─── Rating + Students ───
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sw, vertical: 4.sh),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8.sw),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.orange, size: 16.sw),
                    SizedBox(width: 4.sw),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 13.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D2E),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.sw),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sw, vertical: 4.sh),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(8.sw),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      color: const Color(0xFF335EF7),
                      size: 14.sw,
                    ),
                    SizedBox(width: 4.sw),
                    Text(
                      '$currentStudentsCount $_studentsLabel',
                      style: TextStyle(
                        fontSize: 12.spScaled,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF335EF7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.sw),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sw, vertical: 4.sh),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8.sw),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: const Color(0xFF4CAF50),
                      size: 14.sw,
                    ),
                    SizedBox(width: 4.sw),
                    Text(
                      'شهادة',
                      style: TextStyle(
                        fontSize: 12.spScaled,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sh),

          // ─── Price ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (lesson.hasDiscount && lesson.discountPrice != null)
                    ? '${lesson.discountPrice!.toStringAsFixed(0)}'
                    : '${lesson.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32.spScaled,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF335EF7),
                ),
              ),
              SizedBox(width: 4.sw),
              Text(
                'ج.م',
                style: TextStyle(
                  fontSize: 16.spScaled,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF335EF7),
                ),
              ),
              if (lesson.hasDiscount && lesson.discountPrice != null) ...[
                SizedBox(width: 12.sw),
                Text(
                  '${lesson.price.toStringAsFixed(0)} ج.م',
                  style: TextStyle(
                    fontSize: 16.spScaled,
                    color: Colors.grey[400],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
