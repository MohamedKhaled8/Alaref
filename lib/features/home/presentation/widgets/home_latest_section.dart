import 'package:flutter/material.dart';
import 'home_latest_card.dart';

class HomeLatestSection extends StatelessWidget {
  const HomeLatestSection({super.key});

  static const _items = [
    (
      'امتحان',
      'امتحان شامل على الوحدة الأولى',
      '٥٠ سؤال - ٦٠ دقيقة',
      'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=600&auto=format&fit=crop',
    ),
    (
      'مذكرة',
      'الخلاصة في النحو - الجزء الأول',
      '١٢٠ صفحة (PDF)',
      'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=600&auto=format&fit=crop',
    ),
    (
      'تدريب',
      'تدريبات متحررة على النصوص',
      'متاح الآن للحل',
      'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?q=80&w=600&auto=format&fit=crop',
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
            children: [
              const Icon(
                Icons.note_alt_rounded,
                size: 20,
                color: Color(0xFF335EF7),
              ),
              const SizedBox(width: 8),
              const Text(
                'أحدث الإضافات',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D2E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 245,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final (cat, title, lessons, imageUrl) = _items[i];
              return HomeLatestCard(
                category: cat,
                title: title,
                lessons: lessons,
                imageUrl: imageUrl,
              );
            },
          ),
        ),
      ],
    );
  }
}
