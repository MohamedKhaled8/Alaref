import 'package:alaref/core/utils/config/space.dart';
import 'package:alaref/core/utils/constant/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class SideMenuItemWidget extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final int selectedIndex;
  final VoidCallback onTap;

  const SideMenuItemWidget({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sw),
      child: Material(
        color: ColorsManager.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.0),
          highlightColor: ColorsManager.sideMenuAccent.withOpacity(0.1),
          splashColor: ColorsManager.sideMenuAccent.withOpacity(0.2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: 5.0.sw,
              vertical: 14.0.sh,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorsManager.sideMenuAccent.withOpacity(0.15)
                  : ColorsManager.transparent,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: isSelected
                    ? ColorsManager.sideMenuAccent.withOpacity(0.5)
                    : ColorsManager.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 26.0.sp,
                  color: isSelected ? ColorsManager.sideMenuAccent : ColorsManager.white70,
                ),
                horizintalSpace(5),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? ColorsManager.sideMenuAccent
                          : ColorsManager.white,
                      fontSize: 16.0.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
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
