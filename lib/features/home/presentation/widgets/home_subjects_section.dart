import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeSubjectsSection extends StatelessWidget {
  const HomeSubjectsSection({super.key});

  static const _items = [
    ('المحاضرات', Icons.play_circle_fill_rounded, Color(0xFF335EF7)),
    ('الامتحانات', Icons.quiz_rounded, Color(0xFFFF9800)),
    ('المذكرات', Icons.picture_as_pdf_rounded, Color(0xFFE91E63)),
    ('الواجبات', Icons.assignment_rounded, Color(0xFF4CAF50)),
    ('بنك الأسئلة', Icons.help_center_rounded, Color(0xFF9C27B0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.sw),
          child: Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 22.sw,
                color: const Color(0xFFFF9800),
              ),
              SizedBox(width: 8.sw),
              Text(
                'الوصول السريع',
                style: TextStyle(
                  fontSize: 17.spScaled,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1D2E),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.sh),
        SizedBox(
          height: 48.sh,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 22.sw),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.sw),
            itemBuilder: (context, i) {
              final (title, icon, color) = _items[i];
              return _SubjectChip(
                title: title,
                icon: icon,
                color: color,
                isSelected: i == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;

  const _SubjectChip({
    required this.title,
    required this.icon,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 10.sh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20.sw, color: isSelected ? Colors.white : color),
              SizedBox(width: 8.sw),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1A1D2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.spScaled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
