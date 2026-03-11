import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                context.read<DashboardCubit>().loadUsers(searchQuery: query);
              },
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو الإيميل أو الرقم...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
        // Users List
        Expanded(
          child: BlocConsumer<DashboardCubit, DashboardState>(
            listener: (context, state) {
              if (state is UserUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم تحديث البيانات بنجاح ✓'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                context.read<DashboardCubit>().loadUsers();
              } else if (state is DashboardError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: ${state.message}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF335EF7)),
                );
              }
              if (state is UsersLoaded) {
                if (state.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد مستخدمين',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index] as Map<String, dynamic>;
                    return _UserCard(
                      user: user,
                      onEdit: () => _showEditDialog(context, user),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['name'] ?? '');
    final phoneCtrl = TextEditingController(text: user['phone'] ?? '');
    final parentPhoneCtrl = TextEditingController(
      text: user['parentPhone'] ?? '',
    );
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    String stage = user['stage'] ?? 'primary';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF335EF7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF335EF7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'تعديل بيانات الطالب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EditField(controller: nameCtrl, label: 'الاسم'),
                    const SizedBox(height: 12),
                    _EditField(controller: emailCtrl, label: 'الإيميل'),
                    const SizedBox(height: 12),
                    _EditField(controller: phoneCtrl, label: 'رقم الهاتف'),
                    const SizedBox(height: 12),
                    _EditField(
                      controller: parentPhoneCtrl,
                      label: 'رقم ولي الأمر',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: stage,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: const [
                            DropdownMenuItem(
                              value: 'primary',
                              child: Text('الابتدائية'),
                            ),
                            DropdownMenuItem(
                              value: 'preparatory',
                              child: Text('الإعدادية'),
                            ),
                            DropdownMenuItem(
                              value: 'secondary',
                              child: Text('الثانوية'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => stage = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardCubit>().updateUser(user['uid'], {
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'phone': phoneCtrl.text,
                      'parentPhone': parentPhoneCtrl.text,
                      'stage': stage,
                    });
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF335EF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'حفظ التعديلات',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;

  const _UserCard({required this.user, required this.onEdit});

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'primary':
        return 'ابتدائي';
      case 'preparatory':
        return 'إعدادي';
      case 'secondary':
        return 'ثانوي';
      default:
        return 'غير محدد';
    }
  }

  String _getInitial(dynamic name) {
    if (name == null) return '?';
    final str = name.toString();
    return str.isNotEmpty ? str.substring(0, 1) : '?';
  }

  Color _stageColor(String? stage) {
    switch (stage) {
      case 'primary':
        return const Color(0xFF4CAF50);
      case 'preparatory':
        return const Color(0xFFFF9800);
      case 'secondary':
        return const Color(0xFF335EF7);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stageStr = user['stage'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
            child: Text(
              _getInitial(user['name']),
              style: const TextStyle(
                color: Color(0xFF335EF7),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'بدون اسم',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _stageColor(stageStr).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _stageLabel(stageStr),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _stageColor(stageStr),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.phone_rounded,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user['phone'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF335EF7).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Color(0xFF335EF7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _EditField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
