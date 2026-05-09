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
      padding: EdgeInsets.all(
        stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
      ),
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
                  style: TextStyle(
                    fontSize: stv(
                      context: context,
                      mobile: 24.spScaled,
                      tablet: 28.spScaled,
                      desktop: 32.spScaled,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1D2E),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.bookmark_border,
                  color: const Color(0xFF335EF7),
                  size: stv(
                    context: context,
                    mobile: 24.sw,
                    tablet: 28.sw,
                    desktop: 32.sw,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sh),

          // Tags & Rating
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.sw,
                  vertical: 4.sh,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF335EF7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UI/UX Design',
                  style: TextStyle(
                    fontSize: stv(
                      context: context,
                      mobile: 12.spScaled,
                      tablet: 14.spScaled,
                      desktop: 16.spScaled,
                    ),
                    color: const Color(0xFF335EF7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12.sw),
              Icon(
                Icons.star,
                color: Colors.orange,
                size: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 20.sw,
                  desktop: 24.sw,
                ),
              ),
              SizedBox(width: 4.sw),
              Text(
                '4.8 (4,479 reviews)',
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 13.spScaled,
                    tablet: 15.spScaled,
                    desktop: 17.spScaled,
                  ),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sh),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (lesson.hasDiscount && lesson.discountPrice != null)
                    ? '${lesson.discountPrice!.toStringAsFixed(0)} ج.م'
                    : '${lesson.price.toStringAsFixed(0)} ج.م',
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 28.spScaled,
                    tablet: 34.spScaled,
                    desktop: 40.spScaled,
                  ),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF335EF7),
                ),
              ),
              SizedBox(width: 8.sw),
              if (lesson.hasDiscount && lesson.discountPrice != null)
                Text(
                  '${lesson.price.toStringAsFixed(0)} ج.م',
                  style: TextStyle(
                    fontSize: stv(
                      context: context,
                      mobile: 16.spScaled,
                      tablet: 20.spScaled,
                      desktop: 24.spScaled,
                    ),
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.sh),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                context,
                Icons.people_alt_outlined,
                '$currentStudentsCount$studentsLabel',
              ),
              _statItem(context, Icons.access_time_outlined, 'فيديو'),
              _statItem(context, Icons.find_in_page_outlined, 'شهادة إتمام'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: stv(
            context: context,
            mobile: 16.sw,
            tablet: 20.sw,
            desktop: 24.sw,
          ),
          color: Colors.grey[600],
        ),
        SizedBox(width: 4.sw),
        Text(
          text,
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 12.spScaled,
              tablet: 14.spScaled,
              desktop: 16.spScaled,
            ),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
