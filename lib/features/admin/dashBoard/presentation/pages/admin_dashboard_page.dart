import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alaref/core/Router/routes.dart';
import '../cubit/dashboard_cubit.dart';
import 'admin_users_page.dart';
import 'admin_teachers_page.dart';
import 'admin_courses_videos_page.dart';
import 'admin_codes_page.dart';
import 'admin_exams_settings_page.dart';
import 'admin_statistics_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardCubit(firestore: FirebaseFirestore.instance)
            ..loadStatistics(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late final _pages = [
    AdminStatisticsPage(onNavigate: _switchPage),
    const AdminUsersPage(),
    const AdminTeachersPage(),
    const AdminCoursesVideosPage(),
    const AdminCodesPage(),
    const AdminExamsSettingsPage(),
  ];

  final _menuItems = [
    {'icon': Icons.dashboard_rounded, 'label': 'الإحصائيات'},
    {'icon': Icons.people_alt_rounded, 'label': 'المستخدمين'},
    {'icon': Icons.person_add_rounded, 'label': 'المدرسين'},
    {'icon': Icons.video_library_rounded, 'label': 'الكورسات'},
    {'icon': Icons.qr_code_rounded, 'label': 'الأكواد'},
    {'icon': Icons.quiz_rounded, 'label': 'الامتحانات'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchPage(int index) {
    if (_selectedIndex == index) return;
    _fadeCtrl.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _fadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            _menuItems[_selectedIndex]['label'] as String,
            style: const TextStyle(
              color: Color(0xFF1A1D2E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    size: 18,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.loginPage,
                      (route) => false,
                    );
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'لوحة تحكم الإدارة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context); // Close Drawer
                            _switchPage(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          tileColor: isSelected
                              ? const Color(0xFF335EF7).withOpacity(0.1)
                              : Colors.transparent,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF335EF7)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF335EF7)
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: FadeTransition(opacity: _fadeAnim, child: _pages[_selectedIndex]),
      ),
    );
  }
}
