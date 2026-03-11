import 'package:flutter/material.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';

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
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Mentor
        const Text(
          'Mentor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: teacherImageUrl.startsWith('http')
                  ? NetworkImage(teacherImageUrl)
                  : null,
              child: !teacherImageUrl.startsWith('http')
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.teacherName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  Text(
                    teacherSubject.isNotEmpty ? teacherSubject : 'مدرس',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // About Course
        const Text(
          'About Course',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description.isNotEmpty
                  ? lesson.description
                  : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
              maxLines: isDescriptionExpanded ? null : 3,
              overflow: isDescriptionExpanded ? null : TextOverflow.fade,
            ),
            GestureDetector(
              onTap: onToggleDescription,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isDescriptionExpanded ? 'Show less' : 'Show more',
                  style: const TextStyle(
                    color: Color(0xFF335EF7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tools
        const Text(
          'Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.design_services,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Figma',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
