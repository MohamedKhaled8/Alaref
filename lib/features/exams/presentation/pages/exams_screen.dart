import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alaref/features/exams/presentation/cubit/exams_cubit.dart';
import 'package:alaref/features/exams/presentation/widgets/exams_header.dart';
import 'package:alaref/features/exams/presentation/widgets/exams_tab_bar.dart';
import 'package:alaref/features/exams/presentation/widgets/exams_empty_view.dart';
import 'package:alaref/features/exams/presentation/widgets/exam_card.dart';

/// الصفحة الرئيسية — بنك الامتحانات
class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamsCubit()..loadExams(),
      child: const ExamsScreenView(),
    );
  }
}

/// الـ View — StatelessWidget بتقرأ من الـ Cubit فقط
class ExamsScreenView extends StatelessWidget {
  static const primaryColor = Color(0xFF335EF7);

  const ExamsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: BlocBuilder<ExamsCubit, ExamsState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header ──────────────────────────
                  SliverToBoxAdapter(
                    child: ExamsHeader(
                      totalExams: state is ExamsLoaded ? state.exams.length : 0,
                      takenCount: state is ExamsLoaded
                          ? state.takenExamIds.length
                          : 0,
                    ),
                  ),
                  // ── Tabs ────────────────────────────
                  SliverToBoxAdapter(
                    child: ExamsTabBar(
                      selectedTab: state is ExamsLoaded ? state.selectedTab : 0,
                      onTabChanged: (tab) {
                        context.read<ExamsCubit>().selectTab(tab);
                      },
                    ),
                  ),
                  // ── Content ─────────────────────────
                  if (state is ExamsLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (state is ExamsError)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else if (state is ExamsLoaded && state.filteredExams.isEmpty)
                    const SliverFillRemaining(child: ExamsEmptyView())
                  else if (state is ExamsLoaded)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final exam = state.filteredExams[i];
                          final isTaken = state.takenExamIds.contains(exam.id);
                          final score = state.scores[exam.id];
                          final visible = i < state.visibleCount;

                          return AnimatedOpacity(
                            opacity: visible ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            child: AnimatedSlide(
                              offset: visible
                                  ? Offset.zero
                                  : const Offset(0, 0.12),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              child: ExamCard(
                                exam: exam,
                                isTaken: isTaken,
                                score: score,
                                onReturn: () {
                                  context.read<ExamsCubit>().loadExams();
                                },
                              ),
                            ),
                          );
                        }, childCount: state.filteredExams.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
