import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class CourseAboutTab extends StatelessWidget {
  final LessonModel lesson;
  final String teacherImageUrl;
  final String teacherSubject;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  const CourseAboutTab({
    super.key,
    required this.lesson,
    required this.teacherImageUrl,
    required this.teacherSubject,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.sw),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Teacher Card ───
          _SectionTitle('الأستاذ'),
          SizedBox(height: 12.sh),
          Container(
            padding: EdgeInsets.all(16.sw),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(20.sw),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.sw,
                  backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
                  backgroundImage: teacherImageUrl.startsWith('http')
                      ? NetworkImage(teacherImageUrl)
                      : null,
                  child: !teacherImageUrl.startsWith('http')
                      ? Icon(
                          Icons.person,
                          color: const Color(0xFF335EF7),
                          size: 24.sw,
                        )
                      : null,
                ),
                SizedBox(width: 14.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.teacherName,
                        style: TextStyle(
                          fontSize: 16.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1D2E),
                        ),
                      ),
                      SizedBox(height: 2.sh),
                      Text(
                        teacherSubject.isNotEmpty ? teacherSubject : 'مدرس',
                        style: TextStyle(
                          fontSize: 13.spScaled,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40.sw,
                  height: 40.sw,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.sw),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: const Color(0xFF335EF7),
                    size: 20.sw,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.sh),

          // ─── Description ───
          _SectionTitle('نبذة عن الحصة'),
          SizedBox(height: 12.sh),
          Container(
            padding: EdgeInsets.all(16.sw),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.sw),
              border: Border.all(color: Colors.grey.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.description.isNotEmpty
                      ? lesson.description
                      : 'لا يوجد وصف متاح لهذه الحصة.',
                  style: TextStyle(
                    fontSize: 14.spScaled,
                    color: const Color(0xFF666666),
                    height: 1.7,
                  ),
                  maxLines: isDescriptionExpanded ? null : 4,
                  overflow: isDescriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (lesson.description.length > 120) ...[
                  SizedBox(height: 8.sh),
                  GestureDetector(
                    onTap: onToggleDescription,
                    child: Text(
                      isDescriptionExpanded ? 'عرض أقل' : 'عرض المزيد',
                      style: TextStyle(
                        color: const Color(0xFF335EF7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.spScaled,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.sh),

          // ─── What You'll Learn ───
          _SectionTitle('ماذا ستتعلم'),
          SizedBox(height: 12.sh),
          _LearnItem(Icons.check_circle_rounded, 'فهم مفاهيم الحصة الأساسية'),
          _LearnItem(Icons.check_circle_rounded, 'حل التمارين العملية'),
          _LearnItem(Icons.check_circle_rounded, 'التحضير للامتحان بثقة'),
          _LearnItem(Icons.check_circle_rounded, 'مراجعة شاملة للمادة'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.spScaled,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1D2E),
      ),
    );
  }
}

class _LearnItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LearnItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.sw,
            height: 24.sw,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.sw),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 14.sw),
          ),
          SizedBox(width: 12.sw),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.spScaled,
                color: const Color(0xFF424242),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
