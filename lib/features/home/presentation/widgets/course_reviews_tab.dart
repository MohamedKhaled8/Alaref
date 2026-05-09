import 'package:alaref/core/utils/helper/functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class CourseReviewsTab extends StatelessWidget {
  final String lessonId;
  final Future<void> Function(String) onSubmitComment;

  const CourseReviewsTab({
    super.key,
    required this.lessonId,
    required this.onSubmitComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Comment Input ───
        _CommentInputWidget(onSubmit: onSubmitComment),

        // ─── Comments List ───
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lessons')
                .doc(lessonId)
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
                return _EmptyReviewsState();
              }

              final reviews = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sw,
                  vertical: 8.sh,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index].data() as Map<String, dynamic>;
                  final userName = review['userName'] ?? 'مستخدم';
                  final userPhoto = review['userPhoto'] ?? '';
                  final comment = review['comment'] ?? '';
                  final createdAt = review['createdAt'] as Timestamp?;
                  final timeAgo = createdAt != null
                      ? getTimeAgo(createdAt.toDate())
                      : '';

                  return _ReviewCard(
                    userName: userName,
                    userPhoto: userPhoto,
                    comment: comment,
                    timeAgo: timeAgo,
                    rating: review['rating'] ?? 5,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ========================
/// Comment Input — Stateful widget manages its own controller ✓
/// ========================
class _CommentInputWidget extends StatefulWidget {
  final Future<void> Function(String) onSubmit;

  const _CommentInputWidget({required this.onSubmit});

  @override
  State<_CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<_CommentInputWidget> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      await widget.onSubmit(text);
      if (mounted) {
        _controller.clear();
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
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.sw, 16.sh, 20.sw, 8.sh),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(20.sw),
          border: Border.all(color: const Color(0xFF335EF7).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.sw),
            CircleAvatar(
              radius: 18.sw,
              backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: const Color(0xFF335EF7),
                size: 20.sw,
              ),
            ),
            SizedBox(width: 10.sw),
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقك هنا...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.spScaled,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.sw,
                    vertical: 14.sh,
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.sw),
              child: Material(
                color: const Color(0xFF335EF7),
                borderRadius: BorderRadius.circular(14.sw),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.sw),
                  onTap: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: EdgeInsets.all(12.sw),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20.sw,
                            height: 20.sw,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20.sw,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.sw),
          ],
        ),
      ),
    );
  }
}

/// ========================
/// Empty Reviews State
/// ========================
class _EmptyReviewsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.sw),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 40.sw,
                color: const Color(0xFF335EF7),
              ),
            ),
            SizedBox(height: 16.sh),
            Text(
              'لا يوجد تعليقات بعد',
              style: TextStyle(
                fontSize: 16.spScaled,
                color: const Color(0xFF1A1D2E),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.sh),
            Text(
              'كن أول من يكتب تعليق!',
              style: TextStyle(fontSize: 13.spScaled, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

/// ========================
/// Review Card — new design ✓
/// ========================
class _ReviewCard extends StatelessWidget {
  final String userName;
  final String userPhoto;
  final String comment;
  final String timeAgo;
  final int rating;

  const _ReviewCard({
    required this.userName,
    required this.userPhoto,
    required this.comment,
    required this.timeAgo,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sh),
      padding: EdgeInsets.all(16.sw),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.sw),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.sw,
                backgroundColor: const Color(0xFF335EF7).withOpacity(0.1),
                backgroundImage: userPhoto.isNotEmpty
                    ? NetworkImage(userPhoto)
                    : null,
                child: userPhoto.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: const Color(0xFF335EF7),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.spScaled,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.sw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.spScaled,
                        color: const Color(0xFF1A1D2E),
                      ),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11.spScaled,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sw, vertical: 4.sh),
                decoration: BoxDecoration(
                  color: const Color(0xFF335EF7).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.sw),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.orange, size: 14.sw),
                    SizedBox(width: 2.sw),
                    Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 12.spScaled,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sh),
          Text(
            comment,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.spScaled,
              color: const Color(0xFF424242),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
