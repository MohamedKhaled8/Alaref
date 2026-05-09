import 'package:alaref/core/utils/constant/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../widgets/animated_section.dart';
import '../widgets/home_welcome_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_instructor_banner.dart';
import '../widgets/home_subjects_section.dart';
import '../widgets/home_recommended_section.dart';

import 'package:alaref/core/utils/di/get_it.dart';
import 'package:alaref/features/packages/presentation/widgets/packages_section_widget.dart';
import 'package:alaref/features/lessons/presentation/widgets/latest_lessons_section_widget.dart';
import '../widgets/home_side_menu_widget.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

// ============================================
// 1. HOME SCREEN — منصة تعليمية (تصميم كامل)
// ============================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..startEntranceAnimation(),
      child: HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      key: context.read<HomeCubit>().sideMenuKey,
      menu: const HomeSideMenuWidget(),
      type: SideMenuType.slideNRotate,
      inverse: true,
      background: ColorsManager.sideMenuBackground,
      radius: BorderRadius.circular(30.0),
      child: Scaffold(
        backgroundColor: ColorsManager.homeScaffoldBackground,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final visibleSections = state.visibleSections;
              return CustomScrollView(
                cacheExtent: 1000, // Keep off-screen widgets alive longer
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: stv(
                        context: context,
                        mobile: otv(
                          context: context,
                          portrait: 20.sh,
                          landscape: 10.sh,
                        ),
                        tablet: 30.sh,
                        desktop: 40.sh,
                      ),
                    ),
                  ),
                  // —— 1. هيدر ترحيبي ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 0,
                      child: Column(
                        children: [
                          HomeWelcomeHeader(
                            greeting: context.read<HomeCubit>().greeting,
                            onMenuTap: context.read<HomeCubit>().toggleMenu,
                          ),
                          SizedBox(
                            height: stv(
                              context: context,
                              mobile: otv(
                                context: context,
                                portrait: 16.sh,
                                landscape: 8.sh,
                              ),
                              tablet: 24.sh,
                              desktop: 32.sh,
                            ),
                          ),
                          const HomeSearchBar(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: stv(
                        context: context,
                        mobile: otv(
                          context: context,
                          portrait: 20.sh,
                          landscape: 10.sh,
                        ),
                        tablet: 30.sh,
                        desktop: 40.sh,
                      ),
                    ),
                  ),

                  // —— 4. صورة الأستاذ عمرو ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 3,
                      child: const HomeInstructorBanner(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: stv(
                        context: context,
                        mobile: otv(
                          context: context,
                          portrait: 24.sh,
                          landscape: 12.sh,
                        ),
                        tablet: 34.sh,
                        desktop: 44.sh,
                      ),
                    ),
                  ),
                  // —— 5. الوصول السريع (المواد/الأقسام) ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 4,
                      child: const HomeSubjectsSection(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.sh)),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: stv(
                        context: context,
                        mobile: otv(
                          context: context,
                          portrait: 24.sh,
                          landscape: 12.sh,
                        ),
                        tablet: 34.sh,
                        desktop: 44.sh,
                      ),
                    ),
                  ),
                  // —— 8. محاضرات الأسبوع ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 7,
                      child: const HomeRecommendedSection(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.sh)),
                  // —— 10. الباقات المميزة ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 9,
                      child: const PackagesSectionWidget(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.sh)),

                  // —— 9. أحدث الحصص (Recent) ——
                  SliverToBoxAdapter(
                    child: AnimatedSection(
                      visible: visibleSections > 8,
                      child: const LatestLessonsSectionWidget(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: stv(
                        context: context,
                        mobile: otv(
                          context: context,
                          portrait: 32.sh,
                          landscape: 16.sh,
                        ),
                        tablet: 42.sh,
                        desktop: 52.sh,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
