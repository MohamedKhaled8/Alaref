import 'package:flutter/material.dart';

class HomeInstructorBanner extends StatelessWidget {
  const HomeInstructorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/png/عمرو.png',
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
