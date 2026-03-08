import 'package:flutter/material.dart';
import 'home_course_horizontal_card.dart';

class HomeRecommendedSection extends StatelessWidget {
  const HomeRecommendedSection({super.key});

  static const _courses = [
    (
      'المحاضرة الأولى',
      'مراجعة عامة على الوحدة الأولى',
      'ساعتان',
      'أ. عمرو العارف',
      0.1,
      'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?q=80&w=600&auto=format&fit=crop',
    ),
    (
      'المحاضرة الثانية',
      'شرح درس التشبيه والاستعارة',
      'ساعة ونصف',
      'أ. عمرو العارف',
      0.0,
      'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=600&auto=format&fit=crop',
    ),
    (
      'حل الواجب',
      'حل وتفسير واجب المحاضرة الأولى',
      '٤٥ دقيقة',
      'أ. عمرو العارف',
      0.0,
      'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=600&auto=format&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          height: 268,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final (cat, title, lessons, instructor, progress, imageUrl) =
                  _courses[i];
              return HomeCourseHorizontalCard(
                imageUrl: imageUrl,
                category: cat,
                title: title,
                lessons: lessons,
                instructor: instructor,
                progress: progress,
              );
            },
          ),
        ),
      ],
    );
  }
}
