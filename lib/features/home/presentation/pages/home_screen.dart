import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../widgets/animated_section.dart';
import '../widgets/home_welcome_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_instructor_banner.dart';
import '../widgets/home_subjects_section.dart';

import '../widgets/home_recommended_section.dart';

import '../widgets/home_popular_section.dart';
import '../widgets/home_latest_section.dart';

// ============================================
// 1. HOME SCREEN — منصة تعليمية (تصميم كامل)
// ============================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..startEntranceAnimation(),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح النور';
    if (h < 17) return 'مساء النور';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final visibleSections = state.visibleSections;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // —— 1. هيدر ترحيبي ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 0,
                    child: Column(
                      children: [
                        HomeWelcomeHeader(greeting: _greeting),
                        const SizedBox(height: 16),
                        const HomeSearchBar(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // —— 3. صورة الأستاذ عمرو (صورة فقط) ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 1,
                    child: const HomeInstructorBanner(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // —— 4. الوصول السريع (المواد/الأقسام) ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 2,
                    child: const HomeSubjectsSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // —— 6. محاضرات الأسبوع ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 4,
                    child: const HomeRecommendedSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // —— 9. الباقات (التي تم اختيارها كباقة) ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 5,
                    child: const HomeLatestSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // —— 10. أحدث الحصص (الحصص العادية) ——
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    visible: visibleSections > 6,
                    child: const HomePopularSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }
}
