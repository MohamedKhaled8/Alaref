import 'package:flutter/material.dart';
import 'home_package_card.dart';

class HomePackagesSection extends StatelessWidget {
  const HomePackagesSection({super.key});

  static const _packages = [
    (
      'باقة النحو الشاملة',
      'من الابتدائي للثانوي',
      '٢٤٠ ج.م',
      '٣٥٠ ج.م',
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=600&auto=format&fit=crop',
      [Color(0xFF335EF7), Color(0xFF5B7AFF)],
    ),
    (
      'باقة المرحلة الثانوية',
      'نحو، بلاغة، نصوص، إملاء',
      '٣٥٠ ج.م',
      '٥٠٠ ج.م',
      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=600&auto=format&fit=crop',
      [Color(0xFFE91E63), Color(0xFFFF4081)],
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
              Icon(
                Icons.card_giftcard_rounded,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              const Text(
                'باقات مميزة',
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
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _packages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final (title, subtitle, price, oldPrice, imageUrl, gradient) =
                  _packages[i];
              return HomePackageCard(
                title: title,
                subtitle: subtitle,
                price: price,
                oldPrice: oldPrice,
                imageUrl: imageUrl,
                gradient: gradient,
              );
            },
          ),
        ),
      ],
    );
  }
}
