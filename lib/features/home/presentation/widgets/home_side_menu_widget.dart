import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:alaref/core/utils/constant/color_manager.dart';
import 'package:alaref/core/utils/config/space.dart';
import 'package:alaref/features/sessions/presentation/pages/recent_sessions_screen.dart';
import '../cubit/home_cubit.dart';

class HomeSideMenuWidget extends StatelessWidget {
  const HomeSideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.0.sw, right: 20.0.sw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Profile Section ──
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A65FF), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A65FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: ColorsManager.white,
                  radius: 38.0,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Text(
                        state.userName.isEmpty ? "طالبنا البطل" : state.userName,
                        style: const TextStyle(
                          color: ColorsManager.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "الكود: #${state.studentCode.isEmpty ? 'AL12345' : state.studentCode}",
                          style: const TextStyle(
                            color: ColorsManager.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20.sh),

              // ── Divider ──
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.white.withOpacity(0),
                      ColorsManager.white.withOpacity(0.15),
                      ColorsManager.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.sh),

              // ── Menu Items ──
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _DrawerItem(
                            index: 0,
                            title: "الوضع الليلي",
                            icon: Icons.dark_mode_outlined,
                            selectedIndex: state.selectedMenuIndex,
                            onTap: () => context
                                .read<HomeCubit>()
                                .updateSelectedMenuIndex(0),
                          ),
                          _DrawerItem(
                            index: 1,
                            title: "تغيير اللغة",
                            icon: Icons.language_rounded,
                            selectedIndex: state.selectedMenuIndex,
                            onTap: () => context
                                .read<HomeCubit>()
                                .updateSelectedMenuIndex(1),
                          ),
                          _DrawerItem(
                            index: 2,
                            title: "أحدث الجلسات",
                            icon: Icons.play_circle_outline_rounded,
                            selectedIndex: state.selectedMenuIndex,
                            onTap: () {
                              context
                                  .read<HomeCubit>()
                                  .updateSelectedMenuIndex(2);
                              // Close menu then navigate
                              context.read<HomeCubit>().toggleMenu();
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        transitionDuration:
                                            const Duration(milliseconds: 350),
                                        reverseTransitionDuration:
                                            const Duration(milliseconds: 300),
                                        pageBuilder: (_, __, ___) =>
                                            const RecentSessionsScreen(),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                          return FadeTransition(
                                            opacity: CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          _DrawerItem(
                            index: 3,
                            title: "الكتب والمذكرات",
                            icon: Icons.menu_book_rounded,
                            selectedIndex: state.selectedMenuIndex,
                            onTap: () => context
                                .read<HomeCubit>()
                                .updateSelectedMenuIndex(3),
                          ),
                          _DrawerItem(
                            index: 4,
                            title: "بنك الأسئلة",
                            icon: Icons.quiz_outlined,
                            selectedIndex: state.selectedMenuIndex,
                            onTap: () => context
                                .read<HomeCubit>()
                                .updateSelectedMenuIndex(4),
                          ),
                          SizedBox(height: 16.sh),
                          // ── Divider ──
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorsManager.white.withOpacity(0),
                                  ColorsManager.white.withOpacity(0.1),
                                  ColorsManager.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.sh),
                          _DrawerItem(
                            index: 5,
                            title: "تسجيل الخروج",
                            icon: Icons.logout_rounded,
                            selectedIndex: state.selectedMenuIndex,
                            isDestructive: true,
                            onTap: () => context
                                .read<HomeCubit>()
                                .updateSelectedMenuIndex(5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Version ──
              Padding(
                padding: EdgeInsets.only(top: 8.sh),
                child: Text(
                  "v1.0.0",
                  style: TextStyle(
                    color: ColorsManager.white.withOpacity(0.25),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final int selectedIndex;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.selectedIndex,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    final Color activeColor = isDestructive
        ? const Color(0xFFFF5252)
        : ColorsManager.sideMenuAccent;

    final Color iconColor = isSelected
        ? activeColor
        : (isDestructive
              ? const Color(0xFFFF5252).withOpacity(0.7)
              : ColorsManager.white70);

    final Color textColor = isSelected
        ? activeColor
        : (isDestructive
              ? const Color(0xFFFF5252).withOpacity(0.7)
              : ColorsManager.white);

    return Padding(
      padding: EdgeInsets.only(bottom: 6.sh),
      child: Material(
        color: ColorsManager.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          highlightColor: activeColor.withOpacity(0.08),
          splashColor: activeColor.withOpacity(0.12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: 14.0.sw,
              vertical: 13.0.sh,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.12)
                  : ColorsManager.transparent,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected
                    ? activeColor.withOpacity(0.3)
                    : ColorsManager.white.withOpacity(0.03),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.15)
                        : ColorsManager.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                horizintalSpace(4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
