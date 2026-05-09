import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/courses/presentation/pages/course_subject_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// بطاقة مادة دراسية — تركيز على اسم المادة وليس شكل الباقة.
class CourseSubjectCard extends StatelessWidget {
  final LessonModel course;

  const CourseSubjectCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final n = course.packageItems.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.sw),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 320),
              pageBuilder: (_, __, ___) =>
                  CourseSubjectDetailsScreen(course: course),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.sw),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.sw),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 110.sw,
                  height: 110.sh,
                  child: course.imageUrl.isNotEmpty &&
                          course.imageUrl.startsWith('http')
                      ? Image.network(
                          course.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ph(),
                        )
                      : _ph(),
                ),
              ),
              SizedBox(width: 14.sw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sw,
                        vertical: 4.sh,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF335EF7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.sw),
                      ),
                      child: Text(
                        'مادة دراسية',
                        style: TextStyle(
                          fontSize: 11.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF335EF7),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sh),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.spScaled,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1D2E),
                        height: 1.25,
                      ),
                    ),
                    if (course.teacherName.isNotEmpty) ...[
                      SizedBox(height: 6.sh),
                      Text(
                        course.teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.spScaled,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: 10.sh),
                    Row(
                      children: [
                        Icon(
                          n > 0
                              ? Icons.playlist_play_rounded
                              : Icons.info_outline_rounded,
                          size: 18,
                          color: n > 0
                              ? const Color(0xFF335EF7)
                              : Colors.grey[500],
                        ),
                        SizedBox(width: 6.sw),
                        Expanded(
                          child: Text(
                            n > 0
                                ? '$n حصة متاحة'
                                : 'لا توجد حصص بعد — قريباً',
                            style: TextStyle(
                              fontSize: 12.spScaled,
                              fontWeight: FontWeight.w600,
                              color: n > 0
                                  ? const Color(0xFF335EF7)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${course.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18.spScaled,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  Text(
                    'ج.م',
                    style: TextStyle(
                      fontSize: 11.spScaled,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ph() {
    return Container(
      color: const Color(0xFFEEF4FF),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Color(0xFF335EF7),
          size: 36,
        ),
      ),
    );
  }
}
