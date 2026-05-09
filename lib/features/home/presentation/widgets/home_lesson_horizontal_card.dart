import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/courses/presentation/pages/course_subject_details_screen.dart';
import 'package:alaref/features/home/presentation/screens/course_details_screen.dart';
import 'package:alaref/features/packages/presentation/pages/package_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeLessonHorizontalCard extends StatelessWidget {
  final LessonModel lesson;

  const HomeLessonHorizontalCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Width only set when used in horizontal scroll via parent
      margin: EdgeInsets.only(bottom: 8.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.sw),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.sw,
            offset: Offset(0, 4.sh),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.sw),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.sw),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, __, ___) {
                  if (lesson.isCourse == true) {
                    return CourseSubjectDetailsScreen(course: lesson);
                  }
                  if (lesson.isPackage == true) {
                    return PackageDetailsScreen(package: lesson);
                  }
                  return CourseDetailsScreen(lesson: lesson);
                },
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Image & Badges (fixed height)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.sw),
                    ),
                    child: SizedBox(
                      height: otv(
                        context: context,
                        portrait: 160.sh,
                        landscape: 200.sh,
                      ),
                      width: double.infinity,
                      child:
                          (lesson.imageUrl.isNotEmpty &&
                              lesson.imageUrl.startsWith('http'))
                          ? Image.network(
                              lesson.imageUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.sw),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4],
                        ),
                      ),
                    ),
                  ),
                  // Package / Course badge (كورس = مادة + حصص)
                  if (lesson.isPackage == true || lesson.isCourse == true)
                    Positioned(
                      top: 12.sh,
                      right: 12.sw,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sw,
                          vertical: 6.sh,
                        ),
                        decoration: BoxDecoration(
                          color: lesson.isCourse == true
                              ? const Color(0xFF335EF7)
                              : const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12.sw),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              lesson.isCourse == true
                                  ? Icons.menu_book_rounded
                                  : Icons.layers_rounded,
                              color: Colors.white,
                              size: 14.sw,
                            ),
                            SizedBox(width: 4.sw),
                            Text(
                              lesson.isCourse == true
                                  ? (lesson.packageItems.isEmpty
                                        ? 'مادة — لا حصص بعد'
                                        : 'مادة (${lesson.packageItems.length} حصص)')
                                  : 'باقة (${lesson.packageItems.length} حصص)',
                              style: TextStyle(
                                fontSize: 12.spScaled,
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
              _buildCardContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sw, vertical: 6.sh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 16.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D2E),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.sh),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sw,
                        vertical: 3.sh,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF335EF7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.sw),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 13.sw,
                            color: const Color(0xFF335EF7),
                          ),
                          SizedBox(width: 4.sw),
                          Flexible(
                            child: Text(
                              lesson.teacherName,
                              style: TextStyle(
                                fontSize: 11.spScaled,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF335EF7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.sw),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'السعر',
                    style: TextStyle(
                      fontSize: 10.spScaled,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lesson.hasDiscount && lesson.discountPrice != null) ...[
                    Text(
                      '${lesson.price.toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        fontSize: 12.spScaled,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.sh),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lesson.hasDiscount && lesson.discountPrice != null
                            ? lesson.discountPrice!.toStringAsFixed(0)
                            : lesson.price.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 20.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9800),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: 3.sw),
                      Text(
                        'ج.م',
                        style: TextStyle(
                          fontSize: 12.spScaled,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.sh),
          Text(
            lesson.description,
            style: TextStyle(
              fontSize: 12.spScaled,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.sh),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 3.sh),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF335EF7).withOpacity(0.05),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.sw),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.sh),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 350),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 300,
                    ),
                    pageBuilder: (_, __, ___) {
                      if (lesson.isCourse == true) {
                        return CourseSubjectDetailsScreen(course: lesson);
                      }
                      if (lesson.isPackage == true) {
                        return PackageDetailsScreen(package: lesson);
                      }
                      return CourseDetailsScreen(lesson: lesson);
                    },
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontSize: 13.spScaled,
                  color: const Color(0xFF335EF7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_rounded,
              size: 40.sw,
              color: Colors.grey[300],
            ),
            SizedBox(height: 8.sh),
            Text(
              'لا توجد صورة',
              style: TextStyle(color: Colors.grey[400], fontSize: 13.spScaled),
            ),
          ],
        ),
      ),
    );
  }
}
