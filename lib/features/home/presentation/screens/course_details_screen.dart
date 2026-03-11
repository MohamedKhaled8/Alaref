import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/admin/dashBoard/data/models/exam_model.dart';
import 'package:alaref/features/exams/presentation/pages/exam_taking_screen.dart';
import 'package:alaref/features/home/presentation/widgets/youtube_player_view.dart';
import 'package:alaref/core/Router/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:alaref/features/exams/presentation/widgets/cooldown_screen_content.dart';

class CourseDetailsScreen extends StatefulWidget {
  final LessonModel lesson;

  const CourseDetailsScreen({super.key, required this.lesson});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStudentsCount = 0;
  String _teacherImageUrl = '';
  String _teacherSubject = '';
  final TextEditingController _commentController = TextEditingController();

  // Video In-place state
  bool _isPlayingVideo = false;
  bool _isUnlocked = false;
  bool _isDescriptionExpanded = false;
  late String _currentVideoUrl;
  DateTime? _cooldownUntil;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentStudentsCount = widget.lesson.studentsCount;
    _currentVideoUrl = widget.lesson.videoUrl; // Initialize _currentVideoUrl
    _checkIfUnlocked();
    _loadTeacherInfo();
  }

  /// Extracts the YouTube video ID from any URL format.
  /// Supports: youtube.com/watch, youtu.be, youtube.com/embed, and iframe tags.
  String? _extractVideoId(String url) {
    if (url.trim().isEmpty) return null;

    // 1. Try to extract `src="..."` if the user pasted an entire <iframe> tag
    final iframeRegex = RegExp(r'''src=["']([^"']+)["']''');
    final iframeMatch = iframeRegex.firstMatch(url);
    if (iframeMatch != null) {
      url = iframeMatch.group(1) ?? url;
    }

    // 2. Parse out the video ID from any YouTube formats
    final youtubeRegex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final youtubeMatch = youtubeRegex.firstMatch(url);
    if (youtubeMatch != null) {
      return youtubeMatch.group(1);
    }

    return null;
  }

  bool _checkingExamStatus = true;
  bool _hasPassedExam = false;

  void _checkIfUnlocked() async {
    if (mounted) setState(() => _checkingExamStatus = true);

    bool isUnlockedResult = false;
    if (widget.lesson.price == 0) {
      isUnlockedResult = true;
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            final purchasedLessons = List<String>.from(
              data['purchasedLessons'] ?? [],
            );
            if (purchasedLessons.contains(widget.lesson.id)) {
              isUnlockedResult = true;
            }
          }
        } catch (e) {
          debugPrint('Error checking unlock status: $e');
        }
      }
    }

    if (mounted) {
      setState(() => _isUnlocked = isUnlockedResult);
    }

    // ALWAYS check exam regardless of unlocked status
    if (widget.lesson.requiresExam &&
        widget.lesson.prerequisiteExamId != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final resultsSnap = await FirebaseFirestore.instance
              .collection('exam_results')
              .where('examId', isEqualTo: widget.lesson.prerequisiteExamId)
              .where('studentId', isEqualTo: uid)
              .get();

          bool passed = false;
          DateTime? lastSubmission;

          final sortedDocs = resultsSnap.docs.toList();
          if (sortedDocs.isNotEmpty) {
            sortedDocs.sort((a, b) {
              final t1 = a.data()['submittedAt'] as Timestamp?;
              final t2 = b.data()['submittedAt'] as Timestamp?;
              if (t1 == null && t2 == null) return 0;
              if (t1 == null) return 1;
              if (t2 == null) return -1;
              return t2.compareTo(t1);
            });

            for (var doc in sortedDocs) {
              final data = doc.data();
              final score = data['score'] ?? 0;
              final totalGrade = data['totalGrade'] ?? 1;
              final pct = (score / totalGrade) * 100;
              if (pct >= widget.lesson.minimumPassScore) {
                passed = true;
                break;
              }
            }

            if (!passed) {
              final lastDocData = sortedDocs.first.data();
              if (lastDocData['submittedAt'] != null) {
                lastSubmission = (lastDocData['submittedAt'] as Timestamp)
                    .toDate();
              }
            }
          }

          DateTime? nextRetake;
          if (!passed && lastSubmission != null) {
            final examDoc = await FirebaseFirestore.instance
                .collection('exams')
                .doc(widget.lesson.prerequisiteExamId)
                .get();
            if (examDoc.exists) {
              final cd = examDoc.data()?['retakeCooldownSeconds'] ?? 0;
              if (cd > 0) {
                final possibleRetake = lastSubmission.add(
                  Duration(seconds: cd),
                );
                if (possibleRetake.isAfter(DateTime.now())) {
                  nextRetake = possibleRetake;
                }
              }
            }
          }

          if (mounted) {
            setState(() {
              _hasPassedExam = passed;
              _cooldownUntil = nextRetake;
              _checkingExamStatus = false;
            });
          }
        } catch (e) {
          debugPrint('Error checking exam status: $e');
          if (mounted) {
            setState(() => _checkingExamStatus = false);
          }
        }
      } else {
        if (mounted) setState(() => _checkingExamStatus = false);
      }
    } else {
      // Doesn't require exam
      if (mounted) setState(() => _checkingExamStatus = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _loadTeacherInfo() async {
    if (widget.lesson.teacherId.isEmpty) return;
    try {
      final teacherDoc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(widget.lesson.teacherId)
          .get();
      if (teacherDoc.exists && mounted) {
        final data = teacherDoc.data()!;
        setState(() {
          _teacherImageUrl = data['imageUrl'] ?? '';
          _teacherSubject = data['subject'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading teacher info: $e');
    }
  }

  void _showCodeEntryModal(BuildContext context, String videoUrl) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ادخل الكود',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'برجاء إدخال كود الدفع لمشاهدة هذا الفيديو.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter your Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () async {
                final enteredCode = codeController.text.trim();
                if (enteredCode.isNotEmpty) {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final codesSnapshot = await FirebaseFirestore.instance
                        .collection('codes')
                        .where('code', isEqualTo: enteredCode)
                        .limit(1)
                        .get();

                    if (codesSnapshot.docs.isEmpty) {
                      Navigator.pop(context); // close loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الكود غير صحيح')),
                      );
                      return;
                    }

                    final codeDoc = codesSnapshot.docs.first;
                    final codeData = codeDoc.data();

                    if (codeData['isUsed'] == true) {
                      Navigator.pop(context); // close loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('هذا الكود مستخدم من قبل'),
                        ),
                      );
                      return;
                    }

                    final lessonPrice = widget.lesson.hasDiscount
                        ? (widget.lesson.discountPrice ?? widget.lesson.price)
                        : widget.lesson.price;
                    final codeValue = (codeData['value'] as num).toDouble();

                    if (codeValue != lessonPrice) {
                      Navigator.pop(context); // close loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'قيمة الكود (${codeValue.toStringAsFixed(0)}) لا تطابق سعر الحصة (${lessonPrice.toStringAsFixed(0)})',
                          ),
                        ),
                      );
                      return;
                    }

                    // Success scenarios logic
                    // Update code as used
                    await FirebaseFirestore.instance
                        .collection('codes')
                        .doc(codeDoc.id)
                        .update({
                          'isUsed': true,
                          'usedBy': FirebaseAuth.instance.currentUser?.uid,
                          'usedAt': FieldValue.serverTimestamp(),
                        });

                    // Add lesson to user purchased array
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                            'purchasedLessons': FieldValue.arrayUnion([
                              widget.lesson.id,
                            ]),
                          });
                    }

                    // Safely close loader and modal
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) Navigator.pop(context);

                    _showSuccessAnimation(context, videoUrl);
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context); // close loader
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال كود صحيح')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF335EF7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'تأكيد',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessAnimation(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () async {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext); // Close animation dialog safely
          }

          if (mounted) {
            setState(() {
              _isUnlocked = true;
              _currentStudentsCount++;
            });
          }

          try {
            await FirebaseFirestore.instance
                .collection('lessons')
                .doc(widget.lesson.id)
                .update({'studentsCount': FieldValue.increment(1)});
          } catch (e) {
            debugPrint('Failed to update students count: $e');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم فتح الفيديو بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie celebration animation
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.network(
                    'https://assets1.lottiefiles.com/packages/lf20_touohxv0.json', // generic fireworks/success animation
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تم التفعيل بنجاح!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_person_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'محتوى مدفوع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'يجب الدفع لمشاهدة هذا الفيديو.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _showCodeEntryModal(context, widget.lesson.videoUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE91E63),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'شراء',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ], // Children
        ),
        backgroundColor: const Color(0xFFE91E63), // Distinctive elegant color
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
        elevation: 10,
      ),
    );
  }

  void _handleVideoTap([String? customUrl]) {
    final videoToPlay = customUrl ?? widget.lesson.videoUrl;

    if (widget.lesson.price == 0 || _isUnlocked) {
      if (customUrl == null &&
          widget.lesson.requiresExam &&
          widget.lesson.prerequisiteExamId != null) {
        // If main video, use the precalculated _hasPassedExam
        if (_hasPassedExam) {
          setState(() {
            _currentVideoUrl = videoToPlay;
            _isPlayingVideo = true;
          });
        } else {
          // Re-check just in case, or navigate to exam
          _checkAndHandleExam(
            examId: widget.lesson.prerequisiteExamId!,
            minScore: widget.lesson.minimumPassScore,
            onPassed: () {
              setState(() {
                _hasPassedExam = true;
                _currentVideoUrl = videoToPlay;
                _isPlayingVideo = true;
              });
            },
          );
        }
      } else {
        // For custom URLs (package items), check dynamic exam if needed
        setState(() {
          _currentVideoUrl = videoToPlay;
          _isPlayingVideo = true;
        });
      }
    } else {
      _showPaymentRequiredSnackBar(context);
    }
  }

  /// Check if student passed the prerequisite exam
  Future<void> _checkAndHandleExam({
    required String examId,
    required int minScore,
    required VoidCallback onPassed,
    bool recheckOnly = false,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Show loading dialog for immediate feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF335EF7)),
      ),
    );

    try {
      // Check if student already passed this exam
      final resultsSnap = await FirebaseFirestore.instance
          .collection('exam_results')
          .where('examId', isEqualTo: examId)
          .where('studentId', isEqualTo: uid)
          .get();

      bool passed = false;
      for (var doc in resultsSnap.docs) {
        final data = doc.data();
        final score = data['score'] ?? 0;
        final totalGrade = data['totalGrade'] ?? 1;
        final pct = (score / totalGrade) * 100;
        if (pct >= minScore) {
          passed = true;
          break;
        }
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (passed) {
        onPassed();
      } else if (!recheckOnly) {
        // Load exam and navigate to it directly
        // We show another spinner briefly for loading the actual exam doc
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: Color(0xFF335EF7)),
            ),
          );
        }

        final examDoc = await FirebaseFirestore.instance
            .collection('exams')
            .doc(examId)
            .get();

        if (mounted) Navigator.pop(context); // close exam doc loading dialog

        if (examDoc.exists && mounted) {
          final exam = ExamModel.fromMap(examDoc.data()!, examDoc.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam)),
          ).then((_) {
            // Re-check after returning
            _checkIfUnlocked();
            _checkAndHandleExam(
              examId: examId,
              minScore: minScore,
              recheckOnly: true,
              onPassed: () {
                if (mounted) {
                  setState(() {
                    _hasPassedExam = true;
                  });
                  onPassed();
                }
              },
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Make sure to close loading dialog on error
      }
      debugPrint('Error checking exam: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingExamStatus) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF335EF7)),
        ),
      );
    }

    if (widget.lesson.requiresExam &&
        widget.lesson.prerequisiteExamId != null &&
        !_hasPassedExam) {
      if (_cooldownUntil != null && _cooldownUntil!.isAfter(DateTime.now())) {
        return CooldownScreenContent(
          nextRetakeTime: _cooldownUntil!,
          onExit: () => Navigator.pop(context),
        );
      }
      return _buildExamGateScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          false, // Prevents layout shrinking when keyboard is open
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Cover Image / Video Area
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF1A1D2E), // Dark header color
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _isPlayingVideo
                      ? YoutubePlayerView(
                          videoId: _extractVideoId(_currentVideoUrl) ?? '',
                        )
                      : GestureDetector(
                          onTap: _handleVideoTap,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Thumbnail
                              if (widget.lesson.imageUrl.startsWith('http'))
                                Image.network(
                                  widget.lesson.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.black87),
                                )
                              else
                                Container(color: Colors.black87),

                              // Dark Overlay
                              Container(color: Colors.black.withOpacity(0.4)),

                              // Loading indicator if checking
                              if (_checkingExamStatus) ...[
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ] else if ((_isUnlocked ||
                                      widget.lesson.price == 0) &&
                                  widget.lesson.requiresExam &&
                                  !_hasPassedExam) ...[
                                // Show "Exam Required" directly in the player area!
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.lock_person_rounded,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'يتطلب اجتياز الامتحان أولاً',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _handleVideoTap();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFF6B35,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: const Icon(Icons.quiz_rounded),
                                        label: const Text(
                                          'افتح الامتحان',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                // Play / Lock Button
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color:
                                          (_isUnlocked ||
                                              widget.lesson.price == 0)
                                          ? const Color(0xFF335EF7)
                                          : Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      boxShadow:
                                          (_isUnlocked ||
                                              widget.lesson.price == 0)
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF335EF7,
                                                ).withOpacity(0.4),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Icon(
                                      (_isUnlocked || widget.lesson.price == 0)
                                          ? Icons.play_arrow_rounded
                                          : Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),

                                // "Tap to watch" label at bottom
                                if (_isUnlocked || widget.lesson.price == 0)
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'اضغط لمشاهدة الفيديو',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                ),
              ),

              // 2. Course Info Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.lesson.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Color(0xFF335EF7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tags & Rating
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF335EF7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'UI/UX Design',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF335EF7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8 (4,479 reviews)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (widget.lesson.hasDiscount &&
                                    widget.lesson.discountPrice != null)
                                ? '${widget.lesson.discountPrice!.toStringAsFixed(0)} ج.م'
                                : '${widget.lesson.price.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF335EF7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.lesson.hasDiscount &&
                              widget.lesson.discountPrice != null)
                            Text(
                              '${widget.lesson.price.toStringAsFixed(0)} ج.م',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats row (Students, Hours, Certificate)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildStatsInfo(),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF335EF7),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF335EF7),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Lessons'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),

              // 4. Tab Bar View Content
              SliverFillRemaining(
                child: Padding(
                  // Add bottom padding for the sticky button
                  padding: const EdgeInsets.only(bottom: 100),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(),
                      _buildLessonsTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 5. Sticky Bottom Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  _handleVideoTap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isUnlocked || widget.lesson.price == 0)
                      ? (widget.lesson.requiresExam && !_hasPassedExam
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF4CAF50))
                      : const Color(0xFF335EF7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (_isUnlocked || widget.lesson.price == 0)
                          ? (widget.lesson.requiresExam && !_hasPassedExam
                                ? Icons.quiz_rounded
                                : Icons.play_circle_fill_rounded)
                          : Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (_isUnlocked || widget.lesson.price == 0)
                          ? (widget.lesson.requiresExam && !_hasPassedExam
                                ? 'امتحان قبلي مطلوب - ابدأ الآن'
                                : 'مشاهدة الفيديو')
                          : 'اشتراك - ${(widget.lesson.hasDiscount && widget.lesson.discountPrice != null) ? widget.lesson.discountPrice!.toStringAsFixed(0) : widget.lesson.price.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  List<Widget> _buildStatsInfo() {
    return [
      _statItem(
        Icons.people_alt_outlined,
        '$_currentStudentsCount$_studentsLabel',
      ),
      _statItem(Icons.access_time_outlined, 'فيديو'),
      _statItem(Icons.find_in_page_outlined, 'شهادة إتمام'),
    ];
  }

  String get _studentsLabel {
    if (_currentStudentsCount == 0) return ' طلبة';
    if (_currentStudentsCount == 1) return ' طالب';
    if (_currentStudentsCount == 2) return ' طالبان';
    if (_currentStudentsCount >= 3 && _currentStudentsCount <= 10)
      return ' طلبة';
    return ' طالب';
  }

  Widget _statItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Mentor
        const Text(
          'Mentor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: _teacherImageUrl.startsWith('http')
                  ? NetworkImage(_teacherImageUrl)
                  : null,
              child: !_teacherImageUrl.startsWith('http')
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.teacherName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  Text(
                    _teacherSubject.isNotEmpty ? _teacherSubject : 'مدرس',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // About Course
        const Text(
          'About Course',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.description.isNotEmpty
                  ? widget.lesson.description
                  : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
              maxLines: _isDescriptionExpanded ? null : 3,
              overflow: _isDescriptionExpanded ? null : TextOverflow.fade,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _isDescriptionExpanded ? 'Show less' : 'Show more',
                  style: const TextStyle(
                    color: Color(0xFF335EF7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tools
        const Text(
          'Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.design_services,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Figma',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLessonsTab() {
    bool isPackage = widget.lesson.isPackage;
    int itemsCount = isPackage ? widget.lesson.packageItems.length : 1;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$itemsCount Lessons',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const Text(
              'See All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Section 1 - Introduction',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2E),
              ),
            ),
            Text(
              '15 mins',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF335EF7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (isPackage)
          ...widget.lesson.packageItems.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            // First item usually free or unlocked if bought
            bool isLocked =
                !_isUnlocked && widget.lesson.price > 0 && index > 0;
            return _buildLessonTile(
              index: index + 1,
              title: item.title,
              duration: '10 mins',
              isLocked: isLocked,
              videoUrl: item.videoUrl,
              requiresExam: item.requiresExam,
              examId: item.prerequisiteExamId,
              minScore: item.minimumPassScore,
            );
          }).toList()
        else
          _buildLessonTile(
            index: 1,
            title: widget.lesson.title,
            duration: '15 mins',
            isLocked: !_isUnlocked && widget.lesson.price > 0,
            videoUrl: widget.lesson.videoUrl,
            requiresExam: widget.lesson.requiresExam,
            examId: widget.lesson.prerequisiteExamId,
            minScore: widget.lesson.minimumPassScore,
          ),
      ],
    );
  }

  Widget _buildLessonTile({
    required int index,
    required String title,
    required String duration,
    required bool isLocked,
    required String videoUrl,
    bool requiresExam = false,
    String? examId,
    int minScore = 50,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showPaymentRequiredSnackBar(context);
        } else if (requiresExam && examId != null) {
          // Must pass exam first BEFORE setting it as current playing video
          _checkAndHandleExam(
            examId: examId,
            minScore: minScore,
            onPassed: () {
              // Now we can safe-play
              setState(() {
                _currentVideoUrl = videoUrl;
                _isPlayingVideo = true;
              });
            },
          );
        } else {
          // Play video directly
          setState(() {
            _currentVideoUrl = videoUrl;
            _isPlayingVideo = true;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey[100]
                    : const Color(0xFF335EF7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : const Color(0xFF335EF7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (requiresExam && examId != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.quiz_rounded,
                                size: 12,
                                color: Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'امتحان قبلي ($minScore%)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isLocked
                  ? Icons.lock_outline
                  : (requiresExam && examId != null
                        ? Icons.quiz_outlined
                        : Icons.play_circle_fill),
              color: isLocked
                  ? Colors.grey
                  : (requiresExam && examId != null
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF335EF7)),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Comment Input
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF335EF7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'اكتب تعليقك هنا...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: const Color(0xFF335EF7),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _submitComment,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),

        // Comments List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lessons')
                .doc(widget.lesson.id)
                .collection('reviews')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF335EF7)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا يوجد تعليقات بعد',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'كن أول من يكتب تعليق!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[350],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final reviews = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index].data() as Map<String, dynamic>;
                  final userName = review['userName'] ?? 'مستخدم';
                  final userPhoto = review['userPhoto'] ?? '';
                  final comment = review['comment'] ?? '';
                  final createdAt = review['createdAt'] as Timestamp?;
                  final timeAgo = createdAt != null
                      ? _getTimeAgo(createdAt.toDate())
                      : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(
                                0xFF335EF7,
                              ).withOpacity(0.1),
                              backgroundImage: userPhoto.isNotEmpty
                                  ? NetworkImage(userPhoto)
                                  : null,
                              child: userPhoto.isEmpty
                                  ? Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF335EF7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1A1D2E),
                                    ),
                                  ),
                                  if (timeAgo.isNotEmpty)
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF335EF7,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${review['rating'] ?? 5}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1D2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          comment,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF424242),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اكتب تعليقك أولاً')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }

    // Get user data from Firestore
    String userName = user.displayName ?? 'مستخدم';
    String userPhoto = user.photoURL ?? '';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'] ?? userName;
        userPhoto = userDoc.data()?['photoUrl'] ?? userPhoto;
      }
    } catch (_) {}

    try {
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lesson.id)
          .collection('reviews')
          .add({
            'userId': user.uid,
            'userName': userName,
            'userPhoto': userPhoto,
            'comment': text,
            'rating': 5,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _commentController.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إضافة تعليقك بنجاح ✓'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إرسال التعليق: $e')));
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildExamGateScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.15),
                      const Color(0xFFFF6B35).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Color(0xFFFF6B35),
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'امتحان قبلي مطلوب! 📝',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'يجب عليك اجتياز الامتحان القبلي بنسبة لا تقل عن ${widget.lesson.minimumPassScore}% قبل أن تتمكن من دخول هذه الصفحة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to exam
                    _checkAndHandleExam(
                      examId: widget.lesson.prerequisiteExamId!,
                      minScore: widget.lesson.minimumPassScore,
                      onPassed: () {
                        setState(() {
                          _hasPassedExam = true;
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFFFF6B35).withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    'ابدأ الامتحان الآن',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.bottomNavBar, (_) => false),
                child: const Text(
                  'تراجع (العودة إلى الرئيسية)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Delegate to make TabBar sticky inside nested scroll view
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
