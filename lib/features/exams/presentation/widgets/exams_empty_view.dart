import 'package:flutter/material.dart';

class ExamsEmptyView extends StatelessWidget {
  const ExamsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined, size: 56, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد امتحانات حالياً في هذا القسم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سيتم إضافة امتحانات قريباً',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
