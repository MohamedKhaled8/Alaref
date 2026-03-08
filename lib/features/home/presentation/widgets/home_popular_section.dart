import 'package:flutter/material.dart';
import 'home_popular_card.dart';

class HomePopularSection extends StatelessWidget {
  const HomePopularSection({super.key});

  static const _list = [
    (
      'الصف الثالث الثانوي',
      'باقة مراجعة ليلة الامتحان الشاملة',
      '١٥٠ ج.م',
      '٢٥٠ ج.م',
      '4.9',
      '٨,٢٨٩',
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=400&auto=format&fit=crop',
    ),
    (
      'الصف الثاني الثانوي',
      'كورس البلاغة والنصوص المكثف',
      '١٢٠ ج.م',
      '١٨٠ ج.م',
      '4.9',
      '٦,١٨٢',
      'https://images.unsplash.com/photo-1544377193-33dcf4d6fb3a?q=80&w=400&auto=format&fit=crop',
    ),
    (
      'الصف الأول الثانوي',
      'تأسيس شامل في قواعد النحو والصرف',
      '١٠٠ ج.م',
      '١٥٠ ج.م',
      '4.8',
      '٧,٩٣٨',
      'https://images.unsplash.com/photo-1510070112810-dca17634f664?q=80&w=400&auto=format&fit=crop',
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
                    Icons.star_rounded,
                    size: 22,
                    color: Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'أهم الكورسات',
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
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final (cat, title, curr, old, rating, students, imageUrl) =
                _list[i];
            return HomePopularCard(
              category: cat,
              title: title,
              currentPrice: curr,
              oldPrice: old,
              rating: rating,
              students: students,
              imageUrl: imageUrl,
            );
          },
        ),
      ],
    );
  }
}
