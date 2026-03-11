import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/code_model.dart';
import '../cubit/dashboard_cubit.dart';

class AdminCodesPage extends StatefulWidget {
  const AdminCodesPage({super.key});
  @override
  State<AdminCodesPage> createState() => _AdminCodesPageState();
}

class _AdminCodesPageState extends State<AdminCodesPage> {
  final _valueCtrl = TextEditingController();
  String? _selectedTeacherId;
  String _selectedTeacherName = '';
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadTeachers();
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is CodeGenerated) {
          setState(() => _generatedCode = state.code);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم توليد الكود بنجاح ✓'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توليد كود جديد',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'كل كود مسموح استخدامه مره واحده لكل طالب',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildDropdown(),
            const SizedBox(height: 16),
            _buildPriceField(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            const SizedBox(height: 32),
            if (_generatedCode != null) _buildCodeDisplay(),
            const SizedBox(height: 32),
            _buildShowAllCodesButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        List<dynamic> teachers = [];

        // Use state teachers or fallback to cached
        if (state is TeachersLoaded) {
          teachers = state.teachers;
        } else if (state is TeachersWithCodeLoaded) {
          teachers = state.teachers;
        } else if (state is CodeGenerated && state.teachers.isNotEmpty) {
          teachers = state.teachers;
        } else {
          teachers = context.read<DashboardCubit>().cachedTeachers;
        }

        if (teachers.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: const Text(
              'جاري تحميل المدرسين...',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Verify if the previously selected ID is still in the list
        if (_selectedTeacherId != null) {
          final exists = teachers.any((t) => t.id == _selectedTeacherId);
          if (!exists) {
            _selectedTeacherId = null;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTeacherId,
              isExpanded: true,
              hint: Text(
                'اختر المدرس',
                style: TextStyle(color: Colors.grey[400]),
              ),
              items: teachers
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t.id,
                      child: Text('${t.name} - ${t.subject}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  final t = teachers.firstWhere((t) => t.id == val);
                  setState(() {
                    _selectedTeacherId = val;
                    _selectedTeacherName = t.name;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceField() {
    return Container(
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
        controller: _valueCtrl,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'اكتب قيمة الحصة (مثال: 50)',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.attach_money_rounded, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final isLoading = state is DashboardLoading;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  if (_selectedTeacherId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('اختر المدرس أولاً'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  if (_valueCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('اكتب قيمة الحصة'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<DashboardCubit>().generateCode(
                    value: double.tryParse(_valueCtrl.text) ?? 0,
                    teacherId: _selectedTeacherId!,
                    teacherName: _selectedTeacherName,
                  );
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                const SizedBox(width: 10),
                const Text(
                  'توليد الكود',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'الكود الجديد',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedCode!,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _generatedCode!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم نسخ الكود ✓'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, color: Color(0xFF9C27B0), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'نسخ الكود',
                    style: TextStyle(
                      color: Color(0xFF9C27B0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowAllCodesButton() {
    return GestureDetector(
      onTap: () {
        context.read<DashboardCubit>().loadCodes();
        _showCodesDialog();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF9C27B0)),
        ),
        child: const Center(
          child: Text(
            'عرض جميع الأكواد',
            style: TextStyle(
              color: Color(0xFF9C27B0),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _showCodesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DashboardCubit>(),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'جميع الأكواد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF335EF7)),
                  );
                }
                if (state is CodesLoaded) {
                  if (state.codes.isEmpty) {
                    return const Center(child: Text('لا يوجد أكواد بعد'));
                  }
                  return ListView.builder(
                    itemCount: state.codes.length,
                    itemBuilder: (context, i) {
                      final code = state.codes[i] as CodeModel;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: code.isUsed
                              ? Colors.red.withOpacity(0.05)
                              : Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              code.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: code.isUsed
                                    ? Colors.red
                                    : const Color(0xFF4CAF50),
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${code.value.toStringAsFixed(0)} ج.م',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  code.isUsed ? 'مستخدم' : 'متاح',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: code.isUsed
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}
