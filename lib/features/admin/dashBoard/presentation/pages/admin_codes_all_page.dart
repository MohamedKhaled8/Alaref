import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../data/models/code_model.dart';
import '../cubit/dashboard_cubit.dart';

class AdminCodesAllPage extends StatefulWidget {
  const AdminCodesAllPage({super.key});

  @override
  State<AdminCodesAllPage> createState() => _AdminCodesAllPageState();
}

class _AdminCodesAllPageState extends State<AdminCodesAllPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadCodes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('جميع الأكواد والسجلات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1D2E),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF335EF7)));
                }
                if (state is CodesLoaded) {
                  final filteredCodes = state.codes.where((codeItem) {
                    final code = codeItem as CodeModel;
                    final query = _searchQuery.toLowerCase();
                    return code.code.toLowerCase().contains(query) ||
                        (code.usedByStudentName?.toLowerCase().contains(query) ?? false) ||
                        (code.usedByStudentPhone?.toLowerCase().contains(query) ?? false) ||
                        (code.usedByStudentCode?.toLowerCase().contains(query) ?? false) ||
                        code.teacherName.toLowerCase().contains(query);
                  }).toList();

                  if (filteredCodes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('لا يوجد نتائج تطابق بحثك', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCodes.length,
                    itemBuilder: (context, index) {
                      final code = filteredCodes[index] as CodeModel;
                      return _CodeLogCard(code: code);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: _searchCtrl,
          textAlign: TextAlign.right,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: const InputDecoration(
            hintText: 'بحث بالكود، الطالب، الرقم، أو المدرس...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Cairo'),
            prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF335EF7), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _CodeLogCard extends StatelessWidget {
  final CodeModel code;
  const _CodeLogCard({required this.code});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm:ss a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: code.isUsed ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  code.code,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: code.isUsed ? Colors.red : const Color(0xFF4CAF50),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: code.isUsed ? Colors.red : const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code.isUsed ? 'مستخدم' : 'متاح',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _LogItem(label: 'المدرس:', value: code.teacherName, icon: Icons.school_rounded),
                const SizedBox(height: 8),
                _LogItem(label: 'القيمة:', value: '${code.value.toStringAsFixed(0)} ج.م', icon: Icons.payments_rounded),
                const SizedBox(height: 8),
                _LogItem(label: 'تاريخ الإنشاء:', value: dateFormat.format(code.createdAt), icon: Icons.calendar_today_rounded),
                
                if (code.isUsed) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('بيانات الاستخدام:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF335EF7))),
                    ),
                  ),
                  _LogItem(label: 'الطالب:', value: code.usedByStudentName ?? 'غير معروف', icon: Icons.person_rounded),
                  const SizedBox(height: 8),
                  _LogItem(label: 'كود الطالب:', value: code.usedByStudentCode ?? '---', icon: Icons.tag_rounded),
                  const SizedBox(height: 8),
                  _LogItem(label: 'رقم الهاتف:', value: code.usedByStudentPhone ?? '---', icon: Icons.phone_android_rounded),
                  const SizedBox(height: 8),
                  _LogItem(label: 'وقت الاستخدام:', value: code.usedAt != null ? dateFormat.format(code.usedAt!) : '---', icon: Icons.timer_rounded, valueColor: Colors.deepOrange),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _LogItem({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1A1D2E),
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
