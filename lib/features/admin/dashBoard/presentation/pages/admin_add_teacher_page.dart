import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/teacher_model.dart';
import '../cubit/dashboard_cubit.dart';

class AdminAddTeacherPage extends StatefulWidget {
  const AdminAddTeacherPage({super.key});

  @override
  State<AdminAddTeacherPage> createState() => _AdminAddTeacherPageState();
}

class _AdminAddTeacherPageState extends State<AdminAddTeacherPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    subjectCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'إضافة مدرس جديد',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'البيانات الأساسية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: nameCtrl,
                    label: 'اسم المدرس',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneCtrl,
                    label: 'رقم التليفون',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: subjectCtrl,
                    label: 'مدرس مادة',
                    icon: Icons.subject_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTeacher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
                ),
                child: const Text(
                  'حفظ وإضافة المدرس',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            imageCtrl.text = image.path;
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.camera_alt_outlined, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                imageCtrl.text.isEmpty
                    ? 'اختر صورة من المعرض'
                    : 'تم اختيار الصورة',
                style: TextStyle(
                  color: imageCtrl.text.isEmpty
                      ? Colors.grey[600]
                      : const Color(0xFF4CAF50),
                  fontSize: 14,
                  fontWeight: imageCtrl.text.isEmpty
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            if (imageCtrl.text.isNotEmpty)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _saveTeacher() {
    if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
      final teacher = TeacherModel(
        id: '',
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        subject: subjectCtrl.text,
        imageUrl: imageCtrl.text,
        createdAt: DateTime.now(),
      );
      context.read<DashboardCubit>().addTeacher(teacher);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('برجاء إدخال الاسم ورقم التليفون'),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
