import 'package:alaref/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_lesson_horizontal_card.dart';

class HomePackagesSection extends StatelessWidget {
  const HomePackagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final packages = state.lessons.where((l) => l.isPackage).toList();

        if (packages.isEmpty) return const SizedBox.shrink();

        final cardWidth = MediaQuery.of(context).size.width * 0.78;

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
