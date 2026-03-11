import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/exam_model.dart';
import '../cubit/dashboard_cubit.dart';

class AdminAddLessonPage extends StatefulWidget {
  final LessonModel? lessonToEdit;
  const AdminAddLessonPage({super.key, this.lessonToEdit});

  @override
  State<AdminAddLessonPage> createState() => _AdminAddLessonPageState();
}

class _PackageItemData {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final videoCtrl = TextEditingController();
  final minScoreCtrl = TextEditingController(text: '50');
  bool requiresExam = false;
  String? selectedExamId;
}

class _AdminAddLessonPageState extends State<AdminAddLessonPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final videoCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final minScoreCtrl = TextEditingController(text: '50');
  final discountValCtrl = TextEditingController();
  bool isPackage = false;
  bool hasDiscount = false;
  String discountType = 'percentage'; // or 'fixed'
  bool requiresExam = false;
  String? selectedExamId;
  String selectedStage = 'primary';
  String? selectedTeacherId;
  String selectedTeacherName = '';
  List<_PackageItemData> packageItems = [];

  List<ExamModel> _exams = [];
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
    _loadExams();

    if (widget.lessonToEdit != null) {
      final lesson = widget.lessonToEdit!;
      titleCtrl.text = lesson.title;
      descCtrl.text = lesson.description;
      imageCtrl.text = lesson.imageUrl;
      videoCtrl.text = lesson.videoUrl;
      priceCtrl.text = lesson.price.toString();
      isPackage = lesson.isPackage;
      hasDiscount = lesson.hasDiscount;
      if (hasDiscount && lesson.discountPrice != null && lesson.price > 0) {
        // Try to reverse calculate if it was a percentage or fixed
        discountType = 'fixed';
        discountValCtrl.text = lesson.discountPrice!.toString();
      }
      requiresExam = lesson.requiresExam;
      selectedExamId = lesson.prerequisiteExamId;
      minScoreCtrl.text = lesson.minimumPassScore.toString();
      selectedStage = lesson.stage;
      selectedTeacherId = lesson.teacherId;
      selectedTeacherName = lesson.teacherName;
      for (var item in lesson.packageItems) {
        final data = _PackageItemData();
        data.titleCtrl.text = item.title;
        data.descCtrl.text = item.description;
        data.imageCtrl.text = item.imageUrl;
        data.videoCtrl.text = item.videoUrl;
        data.requiresExam = item.requiresExam;
        data.selectedExamId = item.prerequisiteExamId;
        data.minScoreCtrl.text = item.minimumPassScore.toString();
        packageItems.add(data);
      }
    }
  }

  void _loadExams() async {
    try {
      // Fetch ALL exams without orderBy to include old exams
      // that may not have 'createdAt' field (Firestore excludes
      // documents missing the orderBy field).
      final snap = await context
          .read<DashboardCubit>()
          .firestore
          .collection('exams')
          .get();
      if (mounted) {
        final exams = snap.docs
            .map((d) => ExamModel.fromMap(d.data(), d.id))
            .toList();
        // Sort locally: newest first
        exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _exams = exams;
        });
      }
    } catch (e) {
      debugPrint('Error loading exams: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    imageCtrl.dispose();
    videoCtrl.dispose();
    priceCtrl.dispose();
    minScoreCtrl.dispose();
    for (var item in packageItems) {
      item.titleCtrl.dispose();
      item.descCtrl.dispose();
      item.imageCtrl.dispose();
      item.videoCtrl.dispose();
      item.minScoreCtrl.dispose();
    }
    super.dispose();
  }

  // ─── Design Constants ───────────────────────────────────────
  static const _primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF335EF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const _accentColor = Color(0xFF6C5CE7);
  static const _secondaryColor = Color(0xFF335EF7);
  static const _pinkAccent = Color(0xFFE91E63);
  static const _successColor = Color(0xFF00C853);
  static const _bgColor = Color(0xFFF0F2F8);
  static const _cardColor = Colors.white;
  static const _darkText = Color(0xFF1A1D2E);

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
                    // Background pattern
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
                    // Title
                    Positioned(
                      bottom: 20,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lessonToEdit != null
                                ? 'تعديل بيانات الحصة ✏️'
                                : 'رفع حصة أو باقة جديدة 🚀',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'قم بملء البيانات التالية بعناية',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Image Picker ───────────────────────
                      _buildSectionTitle('📸 صورة الحصة / الباقة'),
                      const SizedBox(height: 10),
                      _buildPremiumImagePicker(
                        imageCtrl,
                        'اختر صورة الحصة أو الباقة',
                      ),
                      const SizedBox(height: 24),

                      // ─── Basic Info Card ────────────────────
                      _buildGlassCard(
                        icon: Icons.edit_note_rounded,
                        title: 'البيانات الأساسية',
                        color: _accentColor,
                        children: [
                          _buildPremiumTextField(
                            controller: titleCtrl,
                            label: 'اسم الحصة / الباقة',
                            icon: Icons.title_rounded,
                            hint: 'مثال: حصة الرياضيات - الفصل الأول',
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: descCtrl,
                            label: 'الوصف',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            hint: 'وصف مختصر للحصة أو الباقة...',
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: videoCtrl,
                            label: 'رابط الفيديو الترويجي أو الرئيسي',
                            icon: Icons.play_circle_outline_rounded,
                            hint: 'https://youtube.com/...',
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: priceCtrl,
                            label: 'السعر (ج.م)',
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            hint: '0',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ─── Classification Card ────────────────
                      _buildGlassCard(
                        icon: Icons.category_outlined,
                        title: 'التصنيفات والإعدادات',
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
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _accentColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'جاري تحميل المدرسين...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
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
                          _buildPremiumSwitch(
                            label: 'يوجد خصم',
                            icon: Icons.discount_outlined,
                            value: hasDiscount,
                            color: _successColor,
                            onChanged: (val) =>
                                setState(() => hasDiscount = val),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildPremiumDropdown<String>(
                                    value: discountType,
                                    label: 'نوع الخصم',
                                    icon: Icons.percent_rounded,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'percentage',
                                        child: Text('نسبة مئوية (%)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'fixed',
                                        child: Text('السعر النهائي (ج.م)'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => discountType = val);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: _buildPremiumTextField(
                                    controller: discountValCtrl,
                                    label: discountType == 'percentage'
                                        ? 'النسبة'
                                        : 'السعر',
                                    icon: Icons.edit_note_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildPremiumSwitch(
                            label: 'هذه باقة (Package) تحتوي على عدة حصص',
                            icon: Icons.inventory_2_outlined,
                            value: isPackage,
                            color: _pinkAccent,
                            onChanged: (val) => setState(() => isPackage = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ─── Prerequisite Exam (Non-Package) ─────
                      if (!isPackage) ...[
                        _buildGlassCard(
                          icon: Icons.quiz_outlined,
                          title: 'الامتحان القبلي (اختياري)',
                          color: const Color(0xFFFF6B35),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B35).withOpacity(0.08),
                                    const Color(0xFFFF6B35).withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: const Color(0xFFFF6B35),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'لو فعلت الامتحان القبلي، الطالب لازم يجتاز الامتحان بدرجة معينة قبل ما يقدر يفتح الفيديو.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPremiumSwitch(
                              label: 'تفعيل امتحان قبلي',
                              icon: Icons.assignment_turned_in_outlined,
                              value: requiresExam,
                              color: const Color(0xFFFF6B35),
                              onChanged: (val) =>
                                  setState(() => requiresExam = val),
                            ),
                            if (requiresExam) ...[
                              const SizedBox(height: 16),
                              _buildExamDropdown(
                                selectedExamId: selectedExamId,
                                onChanged: (val) =>
                                    setState(() => selectedExamId = val),
                              ),
                              const SizedBox(height: 12),
                              _buildPremiumTextField(
                                controller: minScoreCtrl,
                                label: 'أقل درجة للنجاح (%)',
                                icon: Icons.percent_rounded,
                                keyboardType: TextInputType.number,
                                hint: '50',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ─── Package Items ──────────────────────
                      if (isPackage) ...[
                        _buildSectionTitle('📦 محتويات الباقة'),
                        const SizedBox(height: 12),
                        ...packageItems.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return _buildPackageItemCard(i, item);
                        }),
                        const SizedBox(height: 12),
                        _buildAddButton(
                          label: 'إضافة حصة للباقة',
                          icon: Icons.add_circle_outline_rounded,
                          color: _pinkAccent,
                          onTap: () => setState(
                            () => packageItems.add(_PackageItemData()),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ─── Save Button ────────────────────────
                      const SizedBox(height: 12),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Premium UI Components ────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _darkText,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

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
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
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
                ? _successColor.withOpacity(0.5)
                : _accentColor.withOpacity(0.15),
            width: hasImage ? 2 : 1.5,
            // dashed effect simulated with dotted pattern
          ),
          boxShadow: [
            BoxShadow(
              color: hasImage
                  ? _successColor.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
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
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(controller.text),
                        width: double.infinity,
                        height: 200,
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
                      Icons.cloud_upload_outlined,
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
                  const SizedBox(height: 4),
                  Text(
                    'اضغط هنا لاختيار صورة من المعرض',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
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
              color: _secondaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _secondaryColor, size: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildPremiumSwitch({
    required String label,
    required IconData icon,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.08) : _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? color.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value
                    ? color.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: value ? color : Colors.grey, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: value ? color : Colors.grey[700],
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamDropdown({
    required String? selectedExamId,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildPremiumDropdown<String>(
      value: selectedExamId,
      label: 'اختر الامتحان',
      icon: Icons.assignment_outlined,
      hint: 'اختر الامتحان القبلي',
      items: _exams.map((exam) {
        return DropdownMenuItem<String>(
          value: exam.id,
          child: Text(
            '${exam.title} (${exam.totalGrade} درجة)',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPackageItemCard(int index, _PackageItemData item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkAccent.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _pinkAccent.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_pinkAccent, Color(0xFFFF5252)],
                      ),
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
                    'حصة ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pinkAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => packageItems.removeAt(index)),
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
            controller: item.titleCtrl,
            label: 'اسم الفيديو',
            icon: Icons.ondemand_video_rounded,
          ),
          const SizedBox(height: 12),
          _buildPremiumTextField(
            controller: item.descCtrl,
            label: 'الوصف',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 12),
          _buildPremiumImagePicker(item.imageCtrl, 'صورة مصغرة (اختياري)'),
          const SizedBox(height: 12),
          _buildPremiumTextField(
            controller: item.videoCtrl,
            label: 'رابط الفيديو',
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 16),

          // ─── Prerequisite Exam for this item ──────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      color: const Color(0xFFFF6B35),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'امتحان قبلي للحصة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPremiumSwitch(
                  label: 'تفعيل امتحان قبلي',
                  icon: Icons.assignment_turned_in_outlined,
                  value: item.requiresExam,
                  color: const Color(0xFFFF6B35),
                  onChanged: (val) => setState(() => item.requiresExam = val),
                ),
                if (item.requiresExam) ...[
                  const SizedBox(height: 12),
                  _buildExamDropdown(
                    selectedExamId: item.selectedExamId,
                    onChanged: (val) =>
                        setState(() => item.selectedExamId = val),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumTextField(
                    controller: item.minScoreCtrl,
                    label: 'أقل درجة للنجاح (%)',
                    icon: Icons.percent_rounded,
                    keyboardType: TextInputType.number,
                    hint: '50',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
        onPressed: _saveLesson,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              widget.lessonToEdit != null
                  ? 'حفظ التعديلات'
                  : 'حفظ ورفع الحصة / الباقة',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Save Logic ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  void _saveLesson() {
    if (titleCtrl.text.isEmpty ||
        videoCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text('برجاء إدخال جميع البيانات (الاسم، الفيديو، السعر)'),
            ],
          ),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Validate exam selection when requiresExam is on
    if (!isPackage && requiresExam && selectedExamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.quiz_outlined, color: Colors.white),
              const SizedBox(width: 8),
              const Text('برجاء اختيار الامتحان القبلي'),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    double basePrice = double.tryParse(priceCtrl.text) ?? 0;
    double? finalDiscountPrice;
    if (hasDiscount) {
      double val = double.tryParse(discountValCtrl.text) ?? 0;
      if (discountType == 'percentage') {
        finalDiscountPrice = basePrice - (basePrice * (val / 100));
      } else {
        finalDiscountPrice = val;
      }
    }

    final lesson = LessonModel(
      id: widget.lessonToEdit?.id ?? '',
      title: titleCtrl.text,
      description: descCtrl.text,
      imageUrl: imageCtrl.text,
      videoUrl: videoCtrl.text,
      price: basePrice,
      hasDiscount: hasDiscount,
      discountPrice: finalDiscountPrice,
      teacherId: selectedTeacherId ?? '',
      teacherName: selectedTeacherName,
      isPackage: isPackage,
      stage: selectedStage,
      createdAt: widget.lessonToEdit?.createdAt ?? DateTime.now(),
      requiresExam: isPackage ? false : requiresExam,
      prerequisiteExamId: isPackage ? null : selectedExamId,
      minimumPassScore: isPackage
          ? 50
          : (int.tryParse(minScoreCtrl.text) ?? 50),
      packageItems: packageItems.map((item) {
        return PackageItem(
          title: item.titleCtrl.text,
          description: item.descCtrl.text,
          imageUrl: item.imageCtrl.text,
          videoUrl: item.videoCtrl.text,
          requiresExam: item.requiresExam,
          prerequisiteExamId: item.selectedExamId,
          minimumPassScore: int.tryParse(item.minScoreCtrl.text) ?? 50,
        );
      }).toList(),
    );

    if (widget.lessonToEdit != null) {
      context.read<DashboardCubit>().updateLesson(
        widget.lessonToEdit!.id,
        lesson,
      );
    } else {
      context.read<DashboardCubit>().addLesson(lesson);
    }

    Navigator.pop(context);
  }
}
