import 'package:flutter/material.dart';
import 'package:alaref/features/home/presentation/pages/home_screen.dart';
import 'package:alaref/features/courses/presentation/pages/my_courses_screen.dart';

import 'package:alaref/features/exams/presentation/pages/exams_screen.dart';
import 'package:alaref/features/profile/presentation/pages/profile_screen.dart';

// ============================================
// MAIN WRAPPER (BOTTOM NAV BAR)
// ============================================
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MyCoursesScreen(),

    ExamsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF335EF7),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled, size: 24),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded, size: 24),
                label: 'الباقات',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded, size: 24),
                label: 'الامتحانات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 24),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
