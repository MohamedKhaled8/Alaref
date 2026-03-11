import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/presentation/pages/exam_taking_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});
  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<ExamModel> _exams = [];
  Set<String> _takenExamIds = {};
  Map<String, int> _takenScores = {};
  bool _loading = true;
  int _visibleCount = 0;
  int _selectedTab = 0; // 0: Regular, 1: Comprehensive

  static const _primary = Color(0xFF335EF7);
  static const _dark = Color(0xFF1A1D2E);
  static const _green = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    // Fetch ALL exams without orderBy to include old exams
    // that may not have 'createdAt' field.
    final examSnap = await FirebaseFirestore.instance.collection('exams').get();

    final exams = examSnap.docs
        .map((d) => ExamModel.fromMap(d.data(), d.id))
        .toList();
    // Sort locally: newest first
    exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Check which exams are already taken
    Set<String> takenIds = {};
    Map<String, int> scores = {};
    if (user != null) {
      final resultSnap = await FirebaseFirestore.instance
          .collection('exam_results')
          .where('studentId', isEqualTo: user.uid)
          .get();
      for (var doc in resultSnap.docs) {
        final data = doc.data();
        final examId = data['examId'] as String? ?? '';
        takenIds.add(examId);
        scores[examId] = (data['score'] as num?)?.toInt() ?? 0;
      }
    }

    if (mounted) {
      setState(() {
        _exams = exams;
        _takenExamIds = takenIds;
        _takenScores = scores;
        _loading = false;
      });
      _startEntranceAnimation();
    }
  }

  void _startEntranceAnimation() {
    final displayedExams = _exams
        .where(
          (e) => _selectedTab == 0 ? !e.isComprehensive : e.isComprehensive,
        )
        .toList();
    for (int i = 0; i < displayedExams.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 80), () {
        if (mounted) setState(() => _visibleCount = i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      // Background decorative element
                      Positioned(
                        top: -40,
                        left: -40,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'بنك الامتحانات',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: _dark,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_graph_rounded,
                                            color: _primary,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'طور مهاراتك بشكل مستمر',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primary.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.quiz_rounded,
                                    color: _primary,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Glassmorphism stats container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _dark.withOpacity(0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildMiniStat(
                                    icon: Icons.assignment_rounded,
                                    label: 'امتحان',
                                    value: '${_exams.length}',
                                    color: _primary,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey[200],
                                  ),
                                  _buildMiniStat(
                                    icon: Icons.check_circle_rounded,
                                    label: 'مكتمل',
                                    value: '${_takenExamIds.length}',
                                    color: _green,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey[200],
                                  ),
                                  _buildMiniStat(
                                    icon: Icons.pending_actions_rounded,
                                    label: 'متبقي',
                                    value:
                                        '${(_exams.length - _takenExamIds.length).clamp(0, 999)}',
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Tabs ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedTab = 0;
                              _visibleCount = 0;
                              _startEntranceAnimation();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? _primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'عادية (حصة أو باقة)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedTab == 0
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedTab = 1;
                              _visibleCount = 0;
                              _startEntranceAnimation();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? const Color(
                                        0xFFE91E63,
                                      ) // distinct color for comprehensive
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'امتحانات شاملة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Content ─────────────────────────
              if (_loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _primary),
                  ),
                )
              else if (_filteredExams.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            size: 56,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'لا توجد امتحانات حالياً في هذا القسم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'سيتم إضافة امتحانات قريباً',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final exam = _filteredExams[i];
                      final isTaken = _takenExamIds.contains(exam.id);
                      final score = _takenScores[exam.id];
                      final visible = i < _visibleCount;

                      return AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: const Duration(milliseconds: 400),
                        child: AnimatedSlide(
                          offset: visible ? Offset.zero : const Offset(0, 0.12),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          child: _buildExamCard(exam, isTaken, score),
                        ),
                      );
                    }, childCount: _filteredExams.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<ExamModel> get _filteredExams => _exams
      .where((e) => _selectedTab == 0 ? !e.isComprehensive : e.isComprehensive)
      .toList();

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(ExamModel exam, bool isTaken, int? score) {
    final totalGrade = exam.totalGrade;
    final pct = (isTaken && totalGrade > 0 && score != null)
        ? (score / totalGrade * 100)
        : 0.0;
    final passed = pct >= 50;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam)),
            );
            _loadData();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isTaken
                  ? Border.all(color: _green.withOpacity(0.3), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isTaken ? _green : _primary).withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Exam icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isTaken
                            ? const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF335EF7), Color(0xFF5B7AFF)],
                              ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isTaken
                            ? Icons.check_circle_rounded
                            : Icons.quiz_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Exam info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _dark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (exam.teacherName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                exam.teacherName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          // Info chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildInfoChip(
                                Icons.timer_rounded,
                                '${exam.durationMinutes} دقيقة',
                              ),
                              _buildInfoChip(
                                Icons.help_outline_rounded,
                                '${exam.questions.length} سؤال',
                              ),
                              _buildInfoChip(
                                Icons.grade_rounded,
                                '$totalGrade درجة',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge or arrow
                    if (isTaken)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (passed ? _green : const Color(0xFFEF4444))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${pct.toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: passed ? _green : const Color(0xFFEF4444),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _primary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                // Show score bar if taken
                if (isTaken) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'درجتك: $score / $totalGrade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'تم الحل ✓',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation(
                        passed ? _green : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
}
