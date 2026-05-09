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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index] as Map<String, dynamic>;
                    return _UserCard(user: user);
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
}

class _UserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _isExpanded = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _parentPhoneCtrl;
  late TextEditingController _emailCtrl;
  late String _stage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user['name'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.user['phone'] ?? '');
    _parentPhoneCtrl = TextEditingController(text: widget.user['parentPhone'] ?? '');
    _emailCtrl = TextEditingController(text: widget.user['email'] ?? '');
    _stage = widget.user['stage'] ?? 'primary';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'primary': return 'ابتدائي';
      case 'preparatory': return 'إعدادي';
      case 'secondary': return 'ثانوي';
      default: return 'غير محدد';
    }
  }

  Color _stageColor(String? stage) {
    switch (stage) {
      case 'primary': return const Color(0xFF4CAF50);
      case 'preparatory': return const Color(0xFFFF9800);
      case 'secondary': return const Color(0xFF335EF7);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row (Tap to expand/collapse)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
                    child: Text(
                      (widget.user['name'] ?? '?').toString().substring(0, 1),
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
                          widget.user['name'] ?? 'بدون اسم',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user['email'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        if (!_isExpanded) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _stageColor(_stage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _stageLabel(_stage),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _stageColor(_stage),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.phone_rounded, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                widget.user['phone'] ?? '',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content (Edit Form)
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _EditField(controller: _nameCtrl, label: 'الاسم الكامل', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    _EditField(controller: _emailCtrl, label: 'البريد الإلكتروني', icon: Icons.alternate_email_rounded),
                    const SizedBox(height: 12),
                    _EditField(controller: _phoneCtrl, label: 'رقم الهاتف الشخصي', icon: Icons.phone_android_rounded),
                    const SizedBox(height: 12),
                    _EditField(controller: _parentPhoneCtrl, label: 'رقم هاتف ولي الأمر', icon: Icons.family_restroom_rounded),
                    const SizedBox(height: 12),
                    
                    // Stage Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stage,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF335EF7)),
                          items: const [
                            DropdownMenuItem(value: 'primary', child: Text('المرحلة الابتدائية')),
                            DropdownMenuItem(value: 'preparatory', child: Text('المرحلة الإعدادية')),
                            DropdownMenuItem(value: 'secondary', child: Text('المرحلة الثانوية')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _stage = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isExpanded = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF6B7280))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : () async {
                              setState(() => _isSaving = true);
                              try {
                                await context.read<DashboardCubit>().updateUser(widget.user['uid'], {
                                  'name': _nameCtrl.text,
                                  'email': _emailCtrl.text,
                                  'phone': _phoneCtrl.text,
                                  'parentPhone': _parentPhoneCtrl.text,
                                  'stage': _stage,
                                });
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                    _isExpanded = false;
                                  });
                                }
                              } catch (e) {
                                if (mounted) setState(() => _isSaving = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF335EF7),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isSaving 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
  final IconData icon;

  const _EditField({required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 6),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        ),
        TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8F9FE),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF335EF7), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
