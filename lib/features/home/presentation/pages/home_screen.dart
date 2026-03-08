import 'package:flutter/material.dart';
import '../widgets/animated_section.dart';
import '../widgets/home_welcome_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_instructor_banner.dart';
import '../widgets/home_subjects_section.dart';
import '../widgets/home_today_progress.dart';
import '../widgets/home_recommended_section.dart';
import '../widgets/home_packages_section.dart';
import '../widgets/home_popular_section.dart';
import '../widgets/home_latest_section.dart';

// ============================================
// 1. HOME SCREEN — منصة تعليمية (تصميم كامل)
// ============================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _visibleSections = 0;
  late AnimationController _progressAnimCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: 2 / 5).animate(
      CurvedAnimation(parent: _progressAnimCtrl, curve: Curves.easeOutCubic),
    );
    _progressAnimCtrl.forward();
    for (int i = 0; i <= 9; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) setState(() => _visibleSections = i);
      });
    }
  }

  @override
  void dispose() {
    _progressAnimCtrl.dispose();
    super.dispose();
  }

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // —— 1. هيدر ترحيبي ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 1,
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
                visible: _visibleSections > 2,
                child: const HomeInstructorBanner(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 4. الوصول السريع (المواد/الأقسام) ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 3,
                child: const HomeSubjectsSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 5. شريط تقدم اليوم ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 4,
                child: HomeTodayProgress(progressAnimation: _progressAnim),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 6. محاضرات الأسبوع ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 5,
                child: const HomeRecommendedSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 7. باقات مميزة ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 7,
                child: const HomePackagesSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 9. أهم الكورسات ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 8,
                child: const HomePopularSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // —— 10. أحدث الإضافات ——
            SliverToBoxAdapter(
              child: AnimatedSection(
                visible: _visibleSections > 9,
                child: const HomeLatestSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
