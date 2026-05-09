import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/presentation/cubit/course_details_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

import 'package_item_video_screen.dart';

class PackageDetailsScreen extends StatelessWidget {
  final LessonModel package;

  const PackageDetailsScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailsCubit(lesson: package)..initialize(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _PackageDetailsView(package: package),
      ),
    );
  }
}

class _PackageDetailsView extends StatefulWidget {
  final LessonModel package;
  const _PackageDetailsView({required this.package});

  @override
  State<_PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends State<_PackageDetailsView> {
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
        lessonPrice: widget.package.price,
      );
      if (mounted) {
        _codeCtrl.clear();
        _showSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar();
      }
    } finally {
      if (mounted) {
        setState(() => _validating = false);
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.package.isCourse ? '✅ تم تفعيل الكورس بنجاح!' : '✅ تم فتح الباقة بنجاح!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('❌ الكود غير صالح أو مستخدم'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) {
          final cubit = context.read<CourseDetailsCubit>();
          final isUnlocked = state is CourseDetailsLoaded ? state.isUnlocked : false;
          final isLoading = state is! CourseDetailsLoaded;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Premium Header with Back link
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildImageHeader(),
                    _buildBackButton(),
                    _buildInfoOverlay(),
                  ],
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 70)),

              // 2. Unlock Section
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.sw),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (isLoading)
                        _buildLoadingIndicator()
                      else if (isUnlocked || widget.package.price == 0)
                        _buildUnlockedBadge()
                      else
                        _buildUnlockInput(cubit),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 3. Lessons Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sw),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF335EF7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.package.isCourse ? 'محتويات الكورس' : 'محتويات الباقة',
                        style: TextStyle(
                          fontSize: 20.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.package.packageItems.length} حصة',
                        style: TextStyle(
                          fontSize: 14.spScaled,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 4. Lessons List
              if (widget.package.packageItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.sw, vertical: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 44, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'لا يوجد محتوى في الباقة بعد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.spScaled,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sw),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = widget.package.packageItems[index];
                        return _buildLessonCard(item, isUnlocked);
                      },
                      childCount: widget.package.packageItems.length,
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

  Widget _buildImageHeader() {
    return Container(
      width: double.infinity,
      height: 320.sh,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
      ),
      child: widget.package.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.package.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
              ),
            )
          : const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      bottom: -60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.package.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.spScaled,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoBadge(Icons.person_outline, widget.package.teacherName.isNotEmpty ? widget.package.teacherName : 'المعلم'),
                const SizedBox(width: 12),
                _buildInfoBadge(Icons.payments_outlined, '${widget.package.price.toStringAsFixed(0)} EGP'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF335EF7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.spScaled,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF335EF7))),
    );
  }

  Widget _buildUnlockedBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.isCourse ? 'تم تفعيل الكورس' : 'تم تفعيل الباقة',
                  style: TextStyle(
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.spScaled,
                  ),
                ),
                Text(
                  'يمكنك الآن البدء في مشاهدة جميع المحتويات أدناه',
                  style: TextStyle(
                    color: const Color(0xFF059669),
                    fontSize: 12.spScaled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockInput(CourseDetailsCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeCtrl,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.spScaled,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'أدخل كود التفعيل هنا',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  letterSpacing: 0,
                  fontSize: 13.spScaled,
                ),
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _validating ? null : () => _validateCode(cubit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF335EF7), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF335EF7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _validating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'تفعيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.spScaled,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(PackageItem item, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLessonTap(item, isUnlocked),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lesson Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Container(
                      height: 180.sh,
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: item.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => const Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.grey),
                            )
                          : const Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.grey),
                    ),
                  ),
                  _buildLockIcon(isUnlocked),
                ],
              ),
              // Lesson Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.spScaled,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'درس فيديو',
                          style: TextStyle(fontSize: 12.spScaled, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon(bool isUnlocked) {
    if (isUnlocked || widget.package.price == 0) return const SizedBox();
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  void _handleLessonTap(PackageItem item, bool isUnlocked) {
    if (!isUnlocked && widget.package.price > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.package.isCourse ? 'يجب تفعيل الكورس بالكود أولاً' : 'يجب تفعيل الباقة بالكود أولاً'),
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
          teacherName: widget.package.teacherName,
        ),
      ),
    );
  }
}
