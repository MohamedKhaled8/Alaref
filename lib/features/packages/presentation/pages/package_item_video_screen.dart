import 'package:alaref/core/utils/helper/functions.dart';
import 'package:alaref/features/admin/dashBoard/data/models/lesson_model.dart';
import 'package:alaref/features/home/presentation/widgets/youtube_player_view.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: Center(
                child: item.videoUrl.isNotEmpty
                    ? YoutubePlayerView(
                        videoId: extractYoutubeVideoId(item.videoUrl) ?? '',
                      )
                    : const Text(
                        'لا يوجد رابط فيديو',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
