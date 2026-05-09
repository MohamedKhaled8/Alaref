import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeInstructorBanner extends StatelessWidget {
  const HomeInstructorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.sw),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/png/عمرو.png',
            width: double.infinity,
            fit: BoxFit.contain,
            cacheWidth: 800,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
