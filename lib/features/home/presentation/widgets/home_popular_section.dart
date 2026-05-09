import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'home_popular_card.dart';

class HomePopularSection extends StatelessWidget {
  const HomePopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for popular items as they are currently not provided by a cubit
    final popularItems = [
      {
        'category': 'لغة عربية',
        'title': 'كورس النحو الشامل للمرحلة الإعدادية - الحصص الكاملة',
        'currentPrice': '250 ج.م',
        'oldPrice': '400 ج.م',
        'rating': '4.9',
        'students': '1,250',
        'imageUrl': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=400&auto=format&fit=crop',
      },
      {
        'category': 'بلاغة',
        'title': 'سلسلة تبسيط البلاغة للثانوية العامة - الجزء الأول',
        'currentPrice': '180 ج.م',
        'oldPrice': '300 ج.م',
        'rating': '4.8',
        'students': '850',
        'imageUrl': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=400&auto=format&fit=crop',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.sw),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 22.sw,
                    color: const Color(0xFF335EF7),
                  ),
                  SizedBox(width: 8.sw),
                  Text(
                    'الكورسات الشائعة',
                    style: TextStyle(
                      fontSize: 17.spScaled,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                ],
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
        ),
        SizedBox(height: 16.sh),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.sw),
          child: Column(
            children: popularItems.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 14.sh),
              child: HomePopularCard(
                category: item['category']!,
                title: item['title']!,
                currentPrice: item['currentPrice']!,
                oldPrice: item['oldPrice']!,
                rating: item['rating']!,
                students: item['students']!,
                imageUrl: item['imageUrl']!,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
