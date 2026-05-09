import 'package:alaref/core/utils/helper/functions.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/presentation/widgets/youtube_player_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// شاشة عرض فيديو لعنصر من الباقة/الكورس
class PackageItemVideoScreen extends StatelessWidget {
  final PackageItem item;
  final String teacherName;

  const PackageItemVideoScreen({
    super.key,
    required this.item,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    final videoId = extractYoutubeVideoId(item.videoUrl) ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          if (videoId.isNotEmpty)
            YoutubePlayerView(videoId: videoId, autoPlay: true)
          else
            const Center(
              child: Text(
                'رابط الفيديو غير متاح',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

          // Top overlay controls
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 12.sh),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40.sw,
                      height: 40.sw,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.sw,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sw),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.spScaled,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          teacherName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12.spScaled,
                          ),
                        ),
                      ],
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
}
