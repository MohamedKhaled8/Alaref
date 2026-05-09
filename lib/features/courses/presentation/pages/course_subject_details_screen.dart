import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/presentation/cubit/course_details_cubit.dart';
import 'package:alaref/features/packages/presentation/pages/package_item_video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// تفاصيل مادة (كورس) — واجهة مختلفة عن الباقات: التركيز على اسم المادة والحصص.
class CourseSubjectDetailsScreen extends StatelessWidget {
  final LessonModel course;

  const CourseSubjectDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailsCubit(lesson: course)..initialize(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _CourseSubjectDetailsView(course: course),
      ),
    );
  }
}

class _CourseSubjectDetailsView extends StatefulWidget {
  final LessonModel course;
  const _CourseSubjectDetailsView({required this.course});

  @override
  State<_CourseSubjectDetailsView> createState() =>
      _CourseSubjectDetailsViewState();
}

class _CourseSubjectDetailsViewState extends State<_CourseSubjectDetailsView> {
  final _codeCtrl = TextEditingController();
  bool _validating = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateCode(CourseDetailsCubit cubit) async {
    if (_codeCtrl.text.isEmpty) return;
    setState(() => _validating = true);
    try {
      await cubit.redeemCode(
        code: _codeCtrl.text.trim(),
        lessonPrice: widget.course.price,
      );
      if (mounted) {
        _codeCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تفعيل المادة بنجاح'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الكود غير صالح أو مستخدم'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) {
          final cubit = context.read<CourseDetailsCubit>();
          final isUnlocked =
              state is CourseDetailsLoaded ? state.isUnlocked : false;
          final isLoading = state is! CourseDetailsLoaded;
          final items = widget.course.packageItems;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: const Color(0xFF335EF7),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'مادة دراسية',
                    style: TextStyle(
                      fontSize: 14.spScaled,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.sw, 20, 20.sw, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: widget.course.imageUrl.isNotEmpty &&
                                      widget.course.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: widget.course.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          _subjectPlaceholder(),
                                    )
                                  : _subjectPlaceholder(),
                            ),
                          ),
                          SizedBox(width: 16.sw),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course.title,
                                  style: TextStyle(
                                    fontSize: 22.spScaled,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1D2E),
                                    height: 1.25,
                                  ),
                                ),
                                SizedBox(height: 8.sh),
                                if (widget.course.teacherName.isNotEmpty)
                                  Text(
                                    widget.course.teacherName,
                                    style: TextStyle(
                                      fontSize: 14.spScaled,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.course.description.isNotEmpty) ...[
                        SizedBox(height: 16.sh),
                        Text(
                          widget.course.description,
                          style: TextStyle(
                            fontSize: 14.spScaled,
                            color: Colors.grey[700],
                            height: 1.45,
                          ),
                        ),
                      ],
                      SizedBox(height: 20.sh),
                      Row(
                        children: [
                          Icon(Icons.payments_outlined,
                              size: 18, color: Colors.grey[600]),
                          SizedBox(width: 6.sw),
                          Text(
                            '${widget.course.price.toStringAsFixed(0)} ج.م',
                            style: TextStyle(
                              fontSize: 16.spScaled,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sw, vertical: 16),
                  child: Column(
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF335EF7)),
                          ),
                        )
                      else if (isUnlocked || widget.course.price == 0)
                        _unlockedBanner()
                      else
                        _unlockField(cubit),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sw),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF335EF7), size: 22),
                      SizedBox(width: 10.sw),
                      Text(
                        'حصص المادة',
                        style: TextStyle(
                          fontSize: 18.spScaled,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1D2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (items.isEmpty)
                SliverToBoxAdapter(child: _emptyLessonsHint())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sw),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _lessonRow(
                          items[index],
                          isUnlocked,
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 40.sh)),
            ],
          );
        },
      ),
    );
  }

  Widget _subjectPlaceholder() {
    return Container(
      color: const Color(0xFFE8ECF8),
      child: const Icon(Icons.menu_book_rounded,
          color: Color(0xFF335EF7), size: 36),
    );
  }

  Widget _unlockedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF10B981), size: 28),
          SizedBox(width: 12.sw),
          Expanded(
            child: Text(
              'يمكنك متابعة الحصص أدناه',
              style: TextStyle(
                color: const Color(0xFF065F46),
                fontWeight: FontWeight.w600,
                fontSize: 14.spScaled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unlockField(CourseDetailsCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeCtrl,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'كود تفعيل المادة',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.spScaled),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: _validating ? null : () => _validateCode(cubit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF335EF7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _validating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'تفعيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.spScaled,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyLessonsHint() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.sw, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 40, color: Colors.grey[400]),
            SizedBox(height: 12.sh),
            Text(
              'لا توجد حصص بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.spScaled,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 8.sh),
            Text(
              'لم يتم إضافة حصص لهذه المادة حتى الآن. ترقّب التحديثات قريباً.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spScaled,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonRow(PackageItem item, bool isUnlocked) {
    final locked = !isUnlocked && widget.course.price > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _onLessonTap(item, isUnlocked),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: item.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _miniPlaceholder(),
                          )
                        : _miniPlaceholder(),
                  ),
                ),
                SizedBox(width: 12.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.spScaled,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4.sh),
                      Text(
                        'حصة فيديو',
                        style: TextStyle(
                          fontSize: 12.spScaled,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  Icon(Icons.lock_rounded, color: Colors.grey[500], size: 20)
                else
                  const Icon(Icons.play_circle_fill_rounded,
                      color: Color(0xFF335EF7), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Icon(Icons.play_circle_outline_rounded,
          color: Colors.grey[400], size: 28),
    );
  }

  void _onLessonTap(PackageItem item, bool isUnlocked) {
    if (!isUnlocked && widget.course.price > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فعّل المادة بالكود أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageItemVideoScreen(
          item: item,
          teacherName: widget.course.teacherName,
        ),
      ),
    );
  }
}
