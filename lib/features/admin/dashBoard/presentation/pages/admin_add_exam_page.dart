import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alaref/core/utils/services/imgbb_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/exam_model.dart';
import '../cubit/dashboard_cubit.dart';

class AdminAddExamPage extends StatefulWidget {
  const AdminAddExamPage({super.key});

  @override
  State<AdminAddExamPage> createState() => _AdminAddExamPageState();
}

class _QuestionData {
  final questionCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final gradeCtrl = TextEditingController(text: '1');
  final correctCtrl = TextEditingController();
  String type = 'text_mcq';
  List<TextEditingController> choicesCtrls = [TextEditingController()];
}

class _AdminAddExamPageState extends State<AdminAddExamPage>
    with SingleTickerProviderStateMixin {
  final titleCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: '30');
  final cooldownCtrl = TextEditingController(text: '0');
  String cooldownUnit = 'ساعات';
  String selectedStage = 'primary';
  String? selectedTeacherId;
  String selectedTeacherName = '';
  DateTime? scheduledDate;
  bool isComprehensive = false;
  List<_QuestionData> questions = [_QuestionData()];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    context.read<DashboardCubit>().loadTeachers();
  }

  @override
  void dispose() {
    _animController.dispose();
    _animController.dispose();
    titleCtrl.dispose();
    durationCtrl.dispose();
    cooldownCtrl.dispose();
    for (var q in questions) {
      q.questionCtrl.dispose();
      q.imageCtrl.dispose();
      q.gradeCtrl.dispose();
      q.correctCtrl.dispose();
      for (var c in q.choicesCtrls) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // ─── Design Constants ───────────────────────────────────────
  static const _primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const _accentColor = Color(0xFFE91E63);
  static const _secondaryColor = Color(0xFF335EF7);
  static const _bgColor = Color(0xFFF0F2F8);
  static const _cardColor = Colors.white;
  static const _darkText = Color(0xFF1A1D2E);

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _accentColor),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(scheduledDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: _accentColor),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          scheduledDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium App Bar ──────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: _primaryGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إضافة امتحان جديد 📝',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'قم بتجهيز الامتحان للطلاب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Body Content ─────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Basic Info Card ────────────────────
                    _buildGlassCard(
                      icon: Icons.edit_note_rounded,
                      title: 'بيانات الامتحان',
                      color: _accentColor,
                      children: [
                        _buildPremiumTextField(
                          controller: titleCtrl,
                          label: 'عنوان الامتحان',
                          icon: Icons.title_rounded,
                          hint: 'مثال: امتحان شامل متقدم',
                        ),
                        const SizedBox(height: 16),
                        _buildPremiumTextField(
                          controller: durationCtrl,
                          label: 'مدة الامتحان (بالدقائق)',
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                          hint: '30',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: _bgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'امتحان شامل؟',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _darkText,
                              ),
                            ),
                            subtitle: Text(
                              isComprehensive
                                  ? 'نعم، يظهر في قسم الامتحانات الشاملة'
                                  : 'لا، امتحان عادي (حصة أو باقة)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            value: isComprehensive,
                            activeColor: _accentColor,
                            onChanged: (val) {
                              setState(() {
                                isComprehensive = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildPremiumTextField(
                                controller: cooldownCtrl,
                                label: 'مهلة إعادة الامتحان (للراسبين)',
                                icon: Icons.lock_clock_rounded,
                                keyboardType: TextInputType.number,
                                hint: '0',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: _buildPremiumDropdown<String>(
                                value: cooldownUnit,
                                label: 'الوحدة',
                                icon: Icons.access_time_filled,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ثواني',
                                    child: Text('ثواني'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'دقائق',
                                    child: Text('دقائق'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ساعات',
                                    child: Text('ساعات'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'أيام',
                                    child: Text('أيام'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'شهور',
                                    child: Text('شهور'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => cooldownUnit = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Settings Card ────────────────────
                    _buildGlassCard(
                      icon: Icons.settings_rounded,
                      title: 'التصنيفات والموعد',
                      color: _secondaryColor,
                      children: [
                        _buildPremiumDropdown<String>(
                          value: selectedStage,
                          label: 'المرحلة الدراسية',
                          icon: Icons.school_outlined,
                          items: const [
                            DropdownMenuItem(
                              value: 'primary',
                              child: Text('المرحلة الابتدائية'),
                            ),
                            DropdownMenuItem(
                              value: 'preparatory',
                              child: Text('المرحلة الإعدادية'),
                            ),
                            DropdownMenuItem(
                              value: 'secondary',
                              child: Text('المرحلة الثانوية'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedStage = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<DashboardCubit, DashboardState>(
                          builder: (context, state) {
                            List<dynamic> teachers = [];
                            if (state is TeachersLoaded) {
                              teachers = state.teachers;
                            } else if (state is TeachersWithCodeLoaded) {
                              teachers = state.teachers;
                            } else if (state is CodeGenerated &&
                                state.teachers.isNotEmpty) {
                              teachers = state.teachers;
                            } else {
                              teachers = context
                                  .read<DashboardCubit>()
                                  .cachedTeachers;
                            }

                            if (teachers.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'جاري تحميل المدرسين...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            if (selectedTeacherId != null &&
                                !teachers.any(
                                  (t) => t.id == selectedTeacherId,
                                )) {
                              selectedTeacherId = null;
                            }

                            return _buildPremiumDropdown<String>(
                              value: selectedTeacherId,
                              label: 'المدرس',
                              icon: Icons.person_outline_rounded,
                              hint: 'اختر المدرس',
                              items: teachers.map((t) {
                                return DropdownMenuItem<String>(
                                  value: t.id,
                                  child: Text('${t.name} - ${t.subject}'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final t = teachers.firstWhere(
                                    (t) => t.id == val,
                                  );
                                  setState(() {
                                    selectedTeacherId = val;
                                    selectedTeacherName = t.name;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDateTime,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: scheduledDate != null
                                  ? const Color(0xFFFF6B35).withOpacity(0.08)
                                  : _bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: scheduledDate != null
                                    ? const Color(0xFFFF6B35).withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheduledDate != null
                                        ? const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: scheduledDate != null
                                        ? const Color(0xFFFF6B35)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'موعد بدء الامتحان (اختياري)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: scheduledDate != null
                                              ? const Color(0xFFFF6B35)
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scheduledDate != null
                                            ? "${scheduledDate!.year}/${scheduledDate!.month.toString().padLeft(2, '0')}/${scheduledDate!.day.toString().padLeft(2, '0')} ${scheduledDate!.hour.toString().padLeft(2, '0')}:${scheduledDate!.minute.toString().padLeft(2, '0')}"
                                            : 'اضغط لاختيار موعد',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: scheduledDate != null
                                              ? _darkText
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Questions ────────────────────
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(
                        'أسئلة الامتحان',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...questions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final q = entry.value;
                      return _buildQuestionCard(i, q);
                    }),

                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () =>
                          setState(() => questions.add(_QuestionData())),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accentColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: _accentColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'إضافة سؤال إضافي',
                              style: const TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Save Button ────────────────────────
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveExam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'نشر الامتحان وإرساله',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // ═══════════════════════════════════════════════════════════
  // ─── Question Card ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  Widget _buildQuestionCard(int index, _QuestionData q) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'سؤال ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (questions.length > 1)
                IconButton(
                  onPressed: () => setState(() => questions.removeAt(index)),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: q.questionCtrl,
            label: 'نص السؤال',
            icon: Icons.help_outline,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildPremiumImagePicker(q.imageCtrl, 'صورة مساعدة للسؤال (اختياري)'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPremiumTextField(
                  controller: q.gradeCtrl,
                  label: 'درجة السؤال',
                  icon: Icons.grade_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildPremiumDropdown<String>(
                  value: q.type,
                  label: 'نوع السؤال',
                  icon: Icons.api_rounded,
                  items: const [
                    DropdownMenuItem(
                      value: 'image_mcq',
                      child: Text('صورة + اختيارات'),
                    ),
                    DropdownMenuItem(
                      value: 'image_essay',
                      child: Text('صورة + إجابة مقالي'),
                    ),
                    DropdownMenuItem(
                      value: 'text_mcq',
                      child: Text('نص + اختيارات'),
                    ),
                    DropdownMenuItem(
                      value: 'mixed',
                      child: Text('طبيعة مختلطة'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => q.type = val);
                  },
                ),
              ),
            ],
          ),
          if (q.type == 'image_mcq' ||
              q.type == 'text_mcq' ||
              q.type == 'mixed') ...[
            const SizedBox(height: 16),
            const Text(
              'الاختيارات:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            ...q.choicesCtrls.asMap().entries.map((cEntry) {
              int cIdx = cEntry.key;
              TextEditingController cCtrl = cEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPremiumTextField(
                        controller: cCtrl,
                        label: 'الاختيار ${cIdx + 1}',
                        icon: Icons.done_all_rounded,
                      ),
                    ),
                    if (q.choicesCtrls.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            q.choicesCtrls[cIdx].dispose();
                            q.choicesCtrls.removeAt(cIdx);
                          });
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              );
            }),
            InkWell(
              onTap: () {
                setState(() {
                  q.choicesCtrls.add(TextEditingController());
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Icon(Icons.add, color: _secondaryColor, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'إضافة اختيار إضافي',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildPremiumTextField(
            controller: q.correctCtrl,
            label: 'الإجابة الصحيحة كاملة ومطابقة!',
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Premium UI Components ────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: _darkText),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accentColor, size: 20),
          ),
          filled: true,
          fillColor: _bgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accentColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accentColor, size: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      isDense: true,
                      hint: hint != null
                          ? Text(
                              hint,
                              style: TextStyle(color: Colors.grey[400]),
                            )
                          : null,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(fontSize: 14, color: _darkText),
                      items: items,
                      onChanged: onChanged,
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

  Widget _buildPremiumImagePicker(
    TextEditingController controller,
    String label,
  ) {
    final bool hasImage = controller.text.isNotEmpty;
    return InkWell(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            controller.text = image.path;
          });
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage
                ? Colors.green.withOpacity(0.5)
                : _accentColor.withOpacity(0.15),
            width: hasImage ? 2 : 1.5,
          ),
          boxShadow: [
            if (hasImage)
              BoxShadow(
                color: Colors.green.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: controller.text.startsWith('http')
                    ? Image.network(
                        controller.text,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(controller.text),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: _accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveExam() async {
    if (titleCtrl.text.isNotEmpty) {
      // Setup loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        List<ExamQuestion> finalQuestions = [];
        for (var q in questions) {
          String? uploadedImageUrl;

          if (q.imageCtrl.text.isNotEmpty) {
            if (q.imageCtrl.text.startsWith('http')) {
              uploadedImageUrl = q.imageCtrl.text;
            } else {
              // It's a local file path, upload to ImgBB
              final file = File(q.imageCtrl.text);
              if (await file.exists()) {
                final url = await ImgbbService.uploadImage(file.path);
                uploadedImageUrl = url;
              }
            }
          }

          finalQuestions.add(
            ExamQuestion(
              questionText: q.questionCtrl.text,
              imageUrl: uploadedImageUrl,
              type: ExamQuestion.fromMap({'type': q.type}).type,
              grade: int.tryParse(q.gradeCtrl.text) ?? 1,
              choices: q.choicesCtrls
                  .map((c) => c.text.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
              correctAnswer: q.correctCtrl.text.trim(),
            ),
          );
        }

        int cdVal = int.tryParse(cooldownCtrl.text) ?? 0;
        int cdSecs = 0;
        switch (cooldownUnit) {
          case 'ثواني':
            cdSecs = cdVal;
            break;
          case 'دقائق':
            cdSecs = cdVal * 60;
            break;
          case 'ساعات':
            cdSecs = cdVal * 3600;
            break;
          case 'أيام':
            cdSecs = cdVal * 86400;
            break;
          case 'شهور':
            cdSecs = cdVal * 86400 * 30;
            break;
        }

        final exam = ExamModel(
          id: '',
          title: titleCtrl.text,
          durationMinutes: int.tryParse(durationCtrl.text) ?? 30,
          teacherId: selectedTeacherId ?? '',
          teacherName: selectedTeacherName,
          stage: selectedStage,
          createdAt: DateTime.now(),
          scheduledDate: scheduledDate,
          retakeCooldownSeconds: cdSecs,
          isComprehensive: isComprehensive,
          questions: finalQuestions,
        );

        if (mounted) {
          context.read<DashboardCubit>().addExam(exam);
          Navigator.pop(context); // close loading
          Navigator.pop(context); // close screen
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ أثناء الرفع: $e')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('برجاء إدخال عنوان الامتحان على الأقل'),
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
