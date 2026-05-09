import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.sw),
      child: Container(
        height: 52.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث عن درس، مادة أو كورس...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.spScaled,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[500],
              size: 24.sw,
            ),
            suffixIcon: Icon(
              Icons.tune_rounded,
              color: const Color(0xFF335EF7),
              size: 22.sw,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.sh,
              horizontal: 18.sw,
            ),
          ),
        ),
      ),
    );
  }
}
