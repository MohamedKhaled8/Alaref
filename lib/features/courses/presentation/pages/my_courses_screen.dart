import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/presentation/widgets/home_lesson_horizontal_card.dart';

// ============================================
// MY COURSES SCREEN - الباقات
// ============================================
class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF335EF7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'عروض مخصصة لك',
                        style: TextStyle(
                          color: Color(0xFF335EF7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الباقات المتكاملة',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اكتشف باقاتك وارتقِ بمستواك',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              sliver: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('lessons')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'حدث خطأ ما',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ),
                    );
                  }

                  final packages =
                      snapshot.data?.docs
                          .map((d) => LessonModel.fromMap(d.data(), d.id))
                          .where((l) => l.isActive && l.isPackage)
                          .toList() ??
                      [];

                  if (packages.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.8 + (value * 0.2),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0F2FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.card_giftcard_rounded,
                                        size: 50,
                                        color: Color(0xFF335EF7),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'لا توجد باقات حالياً',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1D2E),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'ترقبوا أقوى الباقات قريباً جداً 🚀\nنحن نعمل على إعداد مفاجآت رائعة لكم!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HomeLessonHorizontalCard(
                          lesson: packages[index],
                        ),
                      );
                    }, childCount: packages.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
