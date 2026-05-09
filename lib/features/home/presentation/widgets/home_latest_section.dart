import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'home_latest_card.dart';

class HomeLatestSection extends StatelessWidget {
  const HomeLatestSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for latest items as they are currently not provided by a cubit
    final latestItems = [
      {
        'category': 'حصص جديدة',
        'title': 'مراجعة شهر مارس - منهج القواعد والأساليب',
        'lessons': '١٢ حصة',
        'imageUrl': 'https://images.unsplash.com/photo-1596496131158-005072046422?q=80&w=400&auto=format&fit=crop',
      },
      {
        'category': 'تأسيس',
        'title': 'كورس تأسيس القراءة والكتابة - الحروف المتشابهة',
        'lessons': '٨ حصص',
        'imageUrl': 'https://images.unsplash.com/photo-1627556704302-624286467c65?q=80&w=400&auto=format&fit=crop',
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
                    Icons.new_releases_rounded,
                    size: 22.sw,
                    color: const Color(0xFF00C853),
                  ),
                  SizedBox(width: 8.sw),
                  Text(
                    'أحدث الإضافات',
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 22.sw, right: 22.sw, bottom: 10.sh),
          child: Row(
            children: latestItems.map((item) => Padding(
              padding: EdgeInsets.only(left: 16.sw),
              child: HomeLatestCard(
                category: item['category']!,
                title: item['title']!,
                lessons: item['lessons']!,
                imageUrl: item['imageUrl']!,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
