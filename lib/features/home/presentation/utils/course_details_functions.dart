import 'package:alaref/features/exams/presentation/pages/exam_taking_screen.dart';
import 'package:alaref/features/home/presentation/cubit/course_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// ========================
/// Course Details Functions
/// ========================

/// Handler لتشغيل الفيديو أو عرض الشراء أو فحص الامتحان
void handleVideoTap({
  required BuildContext context,
  required CourseDetailsCubit cubit,
  required CourseDetailsLoaded state,
  required double lessonPrice,
  required String videoUrl,
  required bool requiresExam,
  required String? prerequisiteExamId,
  required int minimumPassScore,
  String? customUrl,
}) {
  final videoToPlay = customUrl ?? videoUrl;

  if (lessonPrice == 0 || state.isUnlocked) {
    if (customUrl == null && requiresExam && prerequisiteExamId != null) {
      if (state.hasPassedExam) {
        cubit.playVideo(videoToPlay);
      } else {
        checkAndHandleExam(
          context: context,
          cubit: cubit,
          examId: prerequisiteExamId,
          minScore: minimumPassScore,
          onPassed: () {
            cubit.setPassedExam();
            cubit.playVideo(videoToPlay);
          },
        );
      }
    } else {
      cubit.playVideo(videoToPlay);
    }
  } else {
    showPaymentRequiredSnackBar(context: context, cubit: cubit);
  }
}

/// فحص هل الطالب اجتاز الامتحان وإن لا يوجهه للامتحان
Future<void> checkAndHandleExam({
  required BuildContext context,
  required CourseDetailsCubit cubit,
  required String examId,
  required int minScore,
  required VoidCallback onPassed,
  bool recheckOnly = false,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: Color(0xFF335EF7)),
    ),
  );

  try {
    final result = await cubit.repository.checkIfPassedExam(
      examId: examId,
      minimumPassScore: minScore,
    );

    if (context.mounted) Navigator.pop(context);

    result.fold((failure) {}, (passed) {
      if (passed) {
        onPassed();
      } else if (!recheckOnly) {
        navigateToExam(
          context: context,
          cubit: cubit,
          examId: examId,
          minScore: minScore,
          onPassed: onPassed,
        );
      }
    });
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
  }
}

/// الذهاب لصفحة الامتحان
Future<void> navigateToExam({
  required BuildContext context,
  required CourseDetailsCubit cubit,
  required String examId,
  required int minScore,
  required VoidCallback onPassed,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: Color(0xFF335EF7)),
    ),
  );

  final examResult = await cubit.repository.getExam(examId);

  if (context.mounted) Navigator.pop(context);

  examResult.fold((failure) {}, (exam) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam)),
      ).then((_) {
        cubit.refreshAfterExam();
        checkAndHandleExam(
          context: context,
          cubit: cubit,
          examId: examId,
          minScore: minScore,
          recheckOnly: true,
          onPassed: () {
            cubit.setPassedExam();
            onPassed();
          },
        );
      });
    }
  });
}

/// عرض SnackBar الدفع المطلوب
void showPaymentRequiredSnackBar({
  required BuildContext context,
  required CourseDetailsCubit cubit,
}) {
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
              showCodeEntryModal(context: context, cubit: cubit);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFE91E63),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'شراء',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE91E63),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 4),
      elevation: 10,
    ),
  );
}

/// نافذة إدخال كود الدفع
void showCodeEntryModal({
  required BuildContext context,
  required CourseDetailsCubit cubit,
  double? lessonPrice,
  bool? hasDiscount,
  double? discountPrice,
}) {
  final TextEditingController codeController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              if (enteredCode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال كود صحيح')),
                );
                return;
              }

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await cubit.redeemCode(
                  code: enteredCode,
                  lessonPrice: lessonPrice ?? 0,
                );

                if (context.mounted) Navigator.pop(context); // loader
                if (context.mounted) Navigator.pop(context); // dialog

                showSuccessAnimation(context: context);
              } catch (e) {
                if (context.mounted) Navigator.pop(context); // loader
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF335EF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

/// أنيميشن النجاح بعد التفعيل
void showSuccessAnimation({required BuildContext context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      Future.delayed(const Duration(seconds: 3), () {
        if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
          Navigator.pop(dialogContext);
        }

        if (context.mounted) {
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
                  'https://assets1.lottiefiles.com/packages/lf20_touohxv0.json',
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
