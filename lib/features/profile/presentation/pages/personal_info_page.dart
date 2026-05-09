import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alaref/features/auth/data/models/user_model.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';
import 'package:alaref/features/profile/utils/academic_stage_label.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  static const _primaryBlue = Color(0xFF335EF7);
  static const _darkText = Color(0xFF1A1D2E);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(child: Text('يجب تسجيل الدخول أولاً')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'المعلومات الشخصية',
            style: TextStyle(
              color: _darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(authUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              );
            }

            final data = snapshot.data?.data();
            final model = data != null
                ? UserModel.fromMap(data, authUser.uid)
                : UserModel(
                    uid: authUser.uid,
                    name: authUser.displayName ?? 'مستخدم',
                    email: authUser.email ?? '',
                    phone: '',
                    parentPhone: '',
                    stage: AcademicStage.primary,
                    studentCode:
                        authUser.uid.length >= 8
                            ? authUser.uid.substring(0, 8).toUpperCase()
                            : authUser.uid.toUpperCase(),
                    password: '',
                  );

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _InfoTile(
                  label: 'الاسم الكامل',
                  value: model.name.isNotEmpty
                      ? model.name
                      : (authUser.displayName ?? '—'),
                  icon: Icons.badge_outlined,
                ),
                _InfoTile(
                  label: 'البريد الإلكتروني',
                  value: model.email.isNotEmpty
                      ? model.email
                      : (authUser.email ?? '—'),
                  icon: Icons.email_outlined,
                  onCopy:
                      model.email.isNotEmpty ||
                              (authUser.email?.isNotEmpty ?? false)
                          ? () => _copy(
                                context,
                                model.email.isNotEmpty
                                    ? model.email
                                    : authUser.email!,
                              )
                          : null,
                ),
                _InfoTile(
                  label: 'رقم الهاتف',
                  value: model.phone.isNotEmpty ? model.phone : '—',
                  icon: Icons.phone_android_rounded,
                ),
                _InfoTile(
                  label: 'هاتف ولي الأمر',
                  value: model.parentPhone.isNotEmpty ? model.parentPhone : '—',
                  icon: Icons.contact_phone_outlined,
                ),
                _InfoTile(
                  label: 'المرحلة الدراسية',
                  value: academicStageLabel(model.stage),
                  icon: Icons.school_outlined,
                ),
                _InfoTile(
                  label: 'كود الطالب',
                  value: model.studentCode.isNotEmpty
                      ? model.studentCode
                      : '—',
                  icon: Icons.qr_code_2_rounded,
                  onCopy: model.studentCode.isNotEmpty
                      ? () => _copy(context, model.studentCode)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'لتعديل هذه البيانات تواصل مع الدعم أو الإدارة.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onCopy;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF475569), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(Icons.copy_rounded, color: Colors.grey[500]),
                  tooltip: 'نسخ',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
