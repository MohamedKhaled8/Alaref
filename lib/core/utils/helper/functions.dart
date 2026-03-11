/// يستخرج Video ID من أي رابط يوتيوب
/// يدعم: youtube.com/watch, youtu.be, youtube.com/embed, و iframe tags
String? extractYoutubeVideoId(String url) {
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

/// يحسب الوقت المنقضي من تاريخ معين ويعرضه بالعربية
String getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 60) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
