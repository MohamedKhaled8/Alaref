import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import '../manager/packages_cubit.dart';
import '../manager/packages_state.dart';
import 'package:alaref/features/home/presentation/widgets/home_lesson_horizontal_card.dart';
import 'package:alaref/core/utils/di/get_it.dart';
import 'package:alaref/core/utils/constant/color_manager.dart';

class PackagesSectionWidget extends StatelessWidget {
  const PackagesSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PackagesCubit>()..loadPackages(),
      child: BlocBuilder<PackagesCubit, PackagesState>(
        builder: (context, state) {
          final packages = state.packages;

          // Show title + empty state OR packages list
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.sw),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      size: 22.sw,
                      color: const Color(0xFFFFC107),
                    ),
                    SizedBox(width: 8.sw),
                    Text(
                      'باقات مميزة',
                      style: TextStyle(
                        fontSize: 17.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D2E),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sh),
              if (state.isLoading && packages.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (packages.isEmpty)
                _buildEmptyState(context)
              else
                _buildPackagesList(context, packages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.sw),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.sh, horizontal: 20.sw),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.03),
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
                      padding: EdgeInsets.all(20.sw),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 40.sw,
                        color: const Color(0xFF335EF7),
                      ),
                    ),
                    SizedBox(height: 20.sh),
                    Text(
                      'لا توجد باقات حالياً',
                      style: TextStyle(
                        fontSize: 16.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D2E),
                      ),
                    ),
                    SizedBox(height: 8.sh),
                    Text(
                      'ترقبوا أقوى العروض قريباً 🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.spScaled,
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
    );
  }

  Widget _buildPackagesList(BuildContext context, List packages) {
    final cardWidth = stv(
      context: context,
      mobile: otv(context: context, portrait: 78.w, landscape: 45.w),
      tablet: 40.w,
      desktop: 25.w,
    );

    return SizedBox(
      height: otv(context: context, portrait: 320.sh, landscape: 280.sh),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 22.sw, right: 22.sw, bottom: 8.sh),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < packages.length; i++) ...[
              SizedBox(
                width: cardWidth,
                child: HomeLessonHorizontalCard(lesson: packages[i]),
              ),
              if (i < packages.length - 1) SizedBox(width: 16.sw),
            ],
          ],
        ),
      ),
    );
  }
}
