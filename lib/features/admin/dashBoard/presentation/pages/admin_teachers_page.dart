import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/teacher_model.dart';
import '../cubit/dashboard_cubit.dart';
import 'admin_add_teacher_page.dart';

class AdminTeachersPage extends StatefulWidget {
  const AdminTeachersPage({super.key});

  @override
  State<AdminTeachersPage> createState() => _AdminTeachersPageState();
}

class _AdminTeachersPageState extends State<AdminTeachersPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is TeacherAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إضافة المدرس بنجاح ✓'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<DashboardCubit>().loadTeachers();
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
        return Column(
          children: [
            // Add Teacher Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: GestureDetector(
                onTap: () {
                  final dashboardCubit = context.read<DashboardCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: dashboardCubit,
                        child: const AdminAddTeacherPage(),
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      dashboardCubit.loadTeachers();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'إضافة مدرس جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Teachers List
            Expanded(
              child: state is DashboardLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF335EF7),
                      ),
                    )
                  : state is TeachersLoaded
                  ? state.teachers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا يوجد مدرسين بعد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.teachers.length,
                            itemBuilder: (context, index) {
                              final teacher = state.teachers[index];
                              return _TeacherCard(teacher: teacher);
                            },
                          )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
            backgroundImage:
                teacher.imageUrl.isNotEmpty &&
                    Uri.tryParse(teacher.imageUrl)?.hasAbsolutePath == true
                ? NetworkImage(teacher.imageUrl)
                : null,
            child:
                teacher.imageUrl.isEmpty ||
                    Uri.tryParse(teacher.imageUrl)?.hasAbsolutePath != true
                ? Text(
                    teacher.name.isNotEmpty ? teacher.name[0] : '?',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF335EF7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        teacher.subject,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF335EF7),
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
                      teacher.phone,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
