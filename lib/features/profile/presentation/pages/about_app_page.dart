import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const _darkText = Color(0xFF1A1D2E);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'عن منصة العارف',
            style: TextStyle(
              color: _darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF335EF7).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 48,
                    color: Color(0xFF335EF7),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'منصة العارف',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'منصة تعليمية تهدف إلى تقديم محتوى دروس وباقات تعليمية وامتحانات إلكترونية '
                'لمتابعة تقدم الطالب في مادة واحدة أو عدة مواد، مع لوحة لمعلمي المنصة '
                'لإدارة المحتوى والطلاب.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              _Bullet(
                text:
                    'مشاهدة الدروس وتتبع آخر الجلسات التي فتحتها.',
              ),
              _Bullet(
                text: 'الاشتراك في الباقات وحل الامتحانات المعتمدة.',
              ),
              _Bullet(
                text: 'عرض النتائج والشهادات من صفحة حسابك.',
              ),
              const SizedBox(height: 28),
              Text(
                'الإصدار',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: Color(0xFF335EF7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
