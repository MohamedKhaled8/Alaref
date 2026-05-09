import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:alaref/features/auth/data/models/user_model.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:alaref/features/profile/presentation/pages/about_app_page.dart';
import 'package:alaref/features/profile/presentation/pages/help_support_page.dart';
import 'package:alaref/features/profile/presentation/pages/my_certificates_page.dart';
import 'package:alaref/features/profile/presentation/pages/personal_info_page.dart';
import 'package:alaref/features/profile/utils/academic_stage_label.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primaryBlue = Color(0xFF335EF7);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول لعرض الملف الشخصي')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(authUser.uid)
            .snapshots(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting &&
              !userSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          final data = userSnap.data?.data();
          final UserModel userModel = data != null
              ? UserModel.fromMap(data, authUser.uid)
              : UserModel(
                  uid: authUser.uid,
                  name: authUser.displayName ?? 'مستخدم',
                  email: authUser.email ?? '',
                  phone: '',
                  parentPhone: '',
                  stage: AcademicStage.primary,
                  studentCode: authUser.uid.length >= 8
                      ? authUser.uid.substring(0, 8).toUpperCase()
                      : authUser.uid.toUpperCase(),
                  password: '',
                );

          final displayName = userModel.name.isNotEmpty
              ? userModel.name
              : (authUser.displayName ?? 'مستخدم');
          final subtitle = academicStageLabel(userModel.stage);
          final photoUrl = authUser.photoURL;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(authUser.uid)
                .collection('recent_sessions')
                .snapshots(),
            builder: (context, sessSnap) {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('exam_results')
                    .where('studentId', isEqualTo: authUser.uid)
                    .snapshots(),
                builder: (context, examSnap) {
                  final sessionDocs = sessSnap.data?.docs ?? [];
                  final lessonIds = <String>{};
                  for (final d in sessionDocs) {
                    final id = d.data()['lessonId'] as String? ?? '';
                    if (id.isNotEmpty) lessonIds.add(id);
                  }
                  final lessonCount = lessonIds.length;
                  final sessionCount = sessionDocs.length;

                  final examDocs = examSnap.data?.docs ?? [];
                  var passedCount = 0;
                  for (final d in examDocs) {
                    final r = ExamResult.fromMap(d.data());
                    if (r.totalGrade > 0 && r.percentage >= 50) {
                      passedCount++;
                    }
                  }

                  final estimatedMinutes = sessionCount * 20;
                  final hoursLabel = estimatedMinutes >= 60
                      ? (estimatedMinutes / 60).toStringAsFixed(1)
                      : estimatedMinutes.toString();
                  final hoursTitle =
                      estimatedMinutes >= 60 ? 'ساعة (تقريبية)' : 'دقيقة (تقريبية)';

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF335EF7)
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: _Avatar(
                                      photoUrl: photoUrl,
                                      name: displayName,
                                    ),
                                  ),
                                  Material(
                                    color: const Color(0xFF335EF7),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'تغيير صورة الملف الشخصي سيُفعّل لاحقاً',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      customBorder: const CircleBorder(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1D2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ProfileStatCard(
                                    title: 'دروس',
                                    value: '$lessonCount',
                                    icon: Icons.menu_book_rounded,
                                    color: const Color(0xFF335EF7),
                                  ),
                                  const SizedBox(width: 12),
                                  _ProfileStatCard(
                                    title: hoursTitle,
                                    value: hoursLabel,
                                    icon: Icons.timer_rounded,
                                    color: const Color(0xFFFF9800),
                                  ),
                                  const SizedBox(width: 12),
                                  _ProfileStatCard(
                                    title: 'نجاح',
                                    value: '$passedCount',
                                    icon: Icons.workspace_premium_rounded,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const Text(
                              'إعدادات الحساب',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ProfileMenuItem(
                              title: 'المعلومات الشخصية',
                              icon: Icons.person_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PersonalInfoPage(),
                                  ),
                                );
                              },
                            ),
                            _ProfileMenuItem(
                              title: 'شهاداتي الدراسية',
                              icon: Icons.card_membership_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const MyCertificatesPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'التطبيق',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ProfileMenuItem(
                              title: 'عن منصة العارف',
                              icon: Icons.info_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AboutAppPage(),
                                  ),
                                );
                              },
                            ),
                            _ProfileMenuItem(
                              title: 'المساعدة والدعم',
                              icon: Icons.help_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const HelpSupportPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            Material(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      Routes.loginPage,
                                      (route) => false,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout_rounded,
                                          color: Colors.red),
                                      SizedBox(width: 10),
                                      Text(
                                        'تسجيل الخروج',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _Avatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 108,
          height: 108,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _InitialsCircle(name: name);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 108,
              height: 108,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF335EF7),
                ),
              ),
            );
          },
        ),
      );
    }
    return _InitialsCircle(name: name);
  }
}

class _InitialsCircle extends StatelessWidget {
  final String name;

  const _InitialsCircle({required this.name});

  String _initials() {
    final t = name.trim();
    if (t.isEmpty) return '؟';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final w = parts[0];
      return w.isNotEmpty ? w.substring(0, 1).toUpperCase() : '؟';
    }
    final first = parts.first;
    final last = parts.last;
    if (first.isEmpty || last.isEmpty) return '؟';
    return '${first.substring(0, 1)}${last.substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 54,
      backgroundColor: const Color(0xFF335EF7).withOpacity(0.12),
      child: Text(
        _initials(),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF335EF7),
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF475569), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
