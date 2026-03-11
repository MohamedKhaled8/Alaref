import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/presentation/widgets/cooldown_screen_content.dart';

class ExamTakingScreen extends StatefulWidget {
  final ExamModel exam;
  const ExamTakingScreen({super.key, required this.exam});
  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with TickerProviderStateMixin {
  late Map<int, String> _answers;
  int _currentQ = 0;
  late int _remainingSeconds;
  Timer? _timer;
  bool _submitted = false;
  bool _alreadyTaken = false;
  bool _isInCooldown = false;
  DateTime? _nextRetakeTime;
  bool _checkingPrevious = true;
  int _score = 0;
  late AnimationController _resultAnimCtrl;
  late AnimationController _questionAnimCtrl;
  late Animation<Offset> _slideAnim;

  static const _primaryBlue = Color(0xFF335EF7);
  static const _darkText = Color(0xFF1A1D2E);
  static const _successGreen = Color(0xFF22C55E);
  static const _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _answers = {};
    _remainingSeconds = widget.exam.durationMinutes * 60;
    _resultAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _questionAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _questionAnimCtrl,
            curve: Curves.easeOutCubic,
          ),
        );
    _questionAnimCtrl.forward();
    _checkAlreadyTaken();
  }

  Future<void> _checkAlreadyTaken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseFirestore.instance
          .collection('exam_results')
          .where('examId', isEqualTo: widget.exam.id)
          .where('studentId', isEqualTo: user.uid)
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        final docs = snap.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['submittedAt'] as Timestamp?;
          final bTime = b.data()['submittedAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime); // descending
        });

        final data = docs.first.data();
        final previousScore = (data['score'] as num?)?.toInt() ?? 0;
        final totalGrade = widget.exam.totalGrade;
        final passed = totalGrade > 0 && previousScore >= (totalGrade / 2);

        DateTime submittedAt = DateTime.now();
        if (data['submittedAt'] != null && data['submittedAt'] is Timestamp) {
          submittedAt = (data['submittedAt'] as Timestamp).toDate();
        }

        if (passed) {
          setState(() {
            _alreadyTaken = true;
            _checkingPrevious = false;
            _score = previousScore;
            if (data['answers'] != null) {
              _answers = Map<int, String>.from(
                (data['answers'] as Map).map(
                  (k, v) => MapEntry(int.parse(k.toString()), v.toString()),
                ),
              );
            }
          });
          return;
        } else {
          // Failed. Check cooldown.
          if (widget.exam.retakeCooldownSeconds > 0) {
            final nextRetake = submittedAt.add(
              Duration(seconds: widget.exam.retakeCooldownSeconds),
            );
            if (DateTime.now().isBefore(nextRetake)) {
              setState(() {
                _checkingPrevious = false;
                _isInCooldown = true;
                _nextRetakeTime = nextRetake;
              });
              return;
            }
          }
          // Can retake!
        }
      }
    }
    if (mounted) {
      setState(() => _checkingPrevious = false);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _submit(isTimeUp: true);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resultAnimCtrl.dispose();
    _questionAnimCtrl.dispose();
    super.dispose();
  }

  void _goToQuestion(int idx) {
    _questionAnimCtrl.reset();
    setState(() => _currentQ = idx);
    _questionAnimCtrl.forward();
  }

  void _trySubmit() {
    // Check all questions are answered
    final unanswered = <int>[];
    for (int i = 0; i < widget.exam.questions.length; i++) {
      if (!_answers.containsKey(i) || _answers[i]!.trim().isEmpty) {
        unanswered.add(i + 1);
      }
    }
    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لم تجب على الأسئلة: ${unanswered.join("، ")}',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    _submit();
  }

  void _submit({bool isTimeUp = false}) {
    _timer?.cancel();
    int score = 0;
    for (int i = 0; i < widget.exam.questions.length; i++) {
      if (_answers[i] == widget.exam.questions[i].correctAnswer) {
        score += widget.exam.questions[i].grade;
      }
    }
    setState(() {
      _submitted = true;
      _score = score;
    });
    _resultAnimCtrl.forward();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = ExamResult(
        examId: widget.exam.id,
        studentId: user.uid,
        studentName: user.displayName ?? 'طالب',
        studentCode: user.uid.substring(0, 8),
        score: score,
        totalGrade: widget.exam.totalGrade,
        answers: _answers,
        submittedAt: DateTime.now(),
      );
      FirebaseFirestore.instance.collection('exam_results').add(result.toMap());
    }

    if (isTimeUp && mounted) {
      _showTimeUpDialog(score);
    }
  }

  void _showTimeUpDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _errorRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off_rounded,
                    color: _errorRed,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'انتهى الوقت! ⏰',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'درجتك: $score / ${widget.exam.totalGrade}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _errorRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: _errorRed,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'خروج من الامتحان؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'يمكنك العودة وإعادة الامتحان في أي وقت. لن تُحفظ إجاباتك الحالية.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _errorRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'خروج',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPrevious) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FF),
          body: const Center(
            child: CircularProgressIndicator(color: _primaryBlue),
          ),
        ),
      );
    }
    if (_isInCooldown) return _buildCooldownScreen();
    if (_submitted) return _buildResultScreen();
    // If _alreadyTaken is true, we redirect directly to the read-only exam view
    return _buildExamScreen();
  }

  Widget _buildCooldownScreen() {
    return CooldownScreenContent(
      nextRetakeTime: _nextRetakeTime!,
      onExit: () => Navigator.pop(context),
    );
  }

  Widget _buildExamScreen() {
    final q = widget.exam.questions[_currentQ];
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final timeText = _alreadyTaken
        ? 'منتهي'
        : '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isLow = !_alreadyTaken && _remainingSeconds < 60;
    final progress = (_currentQ + 1) / widget.exam.questions.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: Column(
            children: [
              // ── Premium Header ──────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          // Exit button
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            onPressed: _confirmExit,
                          ),
                          // Title
                          Expanded(
                            child: Text(
                              widget.exam.title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _darkText,
                              ),
                            ),
                          ),
                          // Timer badge
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isLow
                                  ? _errorRed.withOpacity(0.1)
                                  : _primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLow
                                    ? _errorRed.withOpacity(0.3)
                                    : _primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_rounded,
                                  size: 16,
                                  color: isLow ? _errorRed : _primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isLow ? _errorRed : _primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'السؤال ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${_currentQ + 1}',
                                      style: const TextStyle(
                                        color: _primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' / ${widget.exam.questions.length}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: _primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE8EEFF),
                              valueColor: const AlwaysStoppedAnimation(
                                _primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Question Content ────────────────────────────
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryBlue.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (q.imageUrl != null &&
                                  q.imageUrl!.trim().isNotEmpty &&
                                  q.imageUrl!.trim().toLowerCase() !=
                                      'null') ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    q.imageUrl!.trim(),
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 180,
                                            alignment: Alignment.center,
                                            child:
                                                const CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'تعذر تحميل الصورة',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              // Question text
                              Text(
                                q.questionText,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: _darkText,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Choices or text input
                        if (q.choices.isNotEmpty)
                          ...q.choices.map((c) => _buildChoiceItem(c))
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              enabled: !_alreadyTaken,
                              onChanged: (val) => _answers[_currentQ] = val,
                              textDirection: TextDirection.rtl,
                              maxLines: 5,
                              style: const TextStyle(
                                fontSize: 15,
                                color: _darkText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'اكتب إجابتك هنا...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Navigation Buttons ──────────────────────────
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceItem(String choice) {
    final trimmedChoice = choice.trim();
    final studentAnswer = (_answers[_currentQ] ?? "").trim();
    final selected = studentAnswer == trimmedChoice;
    final correctAnswer = widget.exam.questions[_currentQ].correctAnswer.trim();
    final isCorrect = correctAnswer == trimmedChoice;

    Color borderColor = Colors.grey.withOpacity(0.2);
    Color bgColor = Colors.white;
    Color textColor = _darkText;
    IconData? circleIcon;
    Color circleColor = Colors.transparent;

    if (_alreadyTaken) {
      if (isCorrect) {
        borderColor = _successGreen;
        bgColor = _successGreen.withOpacity(0.06);
        textColor = _successGreen;
        circleIcon = Icons.check_circle_rounded;
        circleColor = _successGreen;
      } else if (selected) {
        borderColor = _errorRed;
        bgColor = _errorRed.withOpacity(0.06);
        textColor = _errorRed;
        circleIcon = Icons.cancel_rounded;
        circleColor = _errorRed;
      } else {
        circleIcon = null;
      }
    } else {
      if (selected) {
        borderColor = _primaryBlue;
        bgColor = _primaryBlue.withOpacity(0.06);
        textColor = _primaryBlue;
        circleIcon = Icons.check_rounded;
        circleColor = _primaryBlue; // Background of the icon
      }
    }

    return GestureDetector(
      onTap: () {
        if (!_alreadyTaken) setState(() => _answers[_currentQ] = choice);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: selected || (_alreadyTaken && isCorrect) ? 2 : 1.5,
          ),
          boxShadow: [
            if (!selected && !_alreadyTaken)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _alreadyTaken && circleIcon != null
                    ? circleColor
                    : (selected && !_alreadyTaken
                          ? _primaryBlue
                          : Colors.transparent),
                border: Border.all(
                  color: _alreadyTaken && circleIcon != null
                      ? circleColor
                      : (selected && !_alreadyTaken
                            ? _primaryBlue
                            : Colors.grey.withOpacity(0.4)),
                  width: 2,
                ),
              ),
              child: circleIcon != null
                  ? Icon(circleIcon, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                choice,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected || (_alreadyTaken && isCorrect)
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLast = _currentQ == widget.exam.questions.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQ > 0) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => _goToQuestion(_currentQ - 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _primaryBlue,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'السابق',
                        style: TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                if (!isLast) {
                  _goToQuestion(_currentQ + 1);
                } else {
                  if (_alreadyTaken) {
                    Navigator.pop(context);
                  } else {
                    _trySubmit();
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLast
                        ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                        : [const Color(0xFF335EF7), const Color(0xFF5B7AFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isLast ? _successGreen : _primaryBlue)
                          .withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast
                          ? (_alreadyTaken ? 'خروج' : 'إرسال الإجابات')
                          : 'التالي',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLast
                          ? Icons.send_rounded
                          : Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 16,
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

  Widget _buildResultScreen() {
    final pct = widget.exam.totalGrade > 0
        ? (_score / widget.exam.totalGrade) * 100
        : 0.0;
    final passed = pct >= 50;
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: passed
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFFF5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _resultAnimCtrl,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Trophy / Sad icon animated
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _resultAnimCtrl,
                      curve: Curves.easeOutBack,
                    ),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: passed
                              ? [
                                  const Color(0xFF22C55E),
                                  const Color(0xFF16A34A),
                                ]
                              : [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (passed ? _successGreen : _errorRed)
                                .withOpacity(0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        passed
                            ? Icons.emoji_events_rounded
                            : Icons.sentiment_very_dissatisfied_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    passed ? '🎉 أحسنت يا بطل!' : '😢 حاول مرة أخرى',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: passed ? const Color(0xFF16A34A) : _errorRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.displayName != null
                        ? 'أهلاً ${user!.displayName}'
                        : 'نتيجتك في الامتحان',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 28),
                  // Score card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (passed ? _successGreen : _errorRed)
                              .withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_score / ${widget.exam.totalGrade}',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: passed ? _successGreen : _errorRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'درجاتك من الدرجة الكلية',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (pct / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: passed
                                        ? [
                                            const Color(0xFF22C55E),
                                            const Color(0xFF4ADE80),
                                          ]
                                        : [
                                            const Color(0xFFEF4444),
                                            const Color(0xFFF87171),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: passed ? _successGreen : _errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'صحيح',
                        value: '${_score > 0 ? _answers.length : 0}',
                        color: _successGreen,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.quiz_rounded,
                        label: 'الأسئلة',
                        value: '${widget.exam.questions.length}',
                        color: _primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        passed
                            ? Icons.play_circle_fill_rounded
                            : Icons.home_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        passed ? 'متابعة الكورس' : 'العودة للرئيسية',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: _primaryBlue.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
