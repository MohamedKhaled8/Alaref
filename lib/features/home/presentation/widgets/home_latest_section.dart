import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import 'home_lesson_horizontal_card.dart';

class HomeLatestSection extends StatelessWidget {
  const HomeLatestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final packages = state.lessons
            .where((l) => l.isActive && l.isPackage)
            .take(5)
            .toList();

        if (packages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: Color(0xFF335EF7),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'الباقات',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
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
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 40,
                                  color: Color(0xFF335EF7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'لا توجد باقات حالياً',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1D2E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ترقبوا أقوى العروض قريباً 🚀',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        final cardWidth = MediaQuery.of(context).size.width * 0.78;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: Color(0xFF335EF7),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'الباقات',
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 22, right: 22, bottom: 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < packages.length; i++) ...[
                      SizedBox(
                        width: cardWidth,
                        child: HomeLessonHorizontalCard(lesson: packages[i]),
                      ),
                      if (i < packages.length - 1) const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
