import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Force landscape for better video experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_getEmbedUrl(widget.videoUrl)));
  }

  @override
  void dispose() {
    // Reset to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  /// Convert YouTube/Drive/Vimeo URLs to embeddable format
  String _getEmbedUrl(String url) {
    // YouTube
    final youtubeRegex = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([\w-]+)',
    );
    final youtubeMatch = youtubeRegex.firstMatch(url);
    if (youtubeMatch != null) {
      final videoId = youtubeMatch.group(1);
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0';
    }

    // Vimeo
    final vimeoRegex = RegExp(r'vimeo\.com\/(\d+)');
    final vimeoMatch = vimeoRegex.firstMatch(url);
    if (vimeoMatch != null) {
      final videoId = vimeoMatch.group(1);
      return 'https://player.vimeo.com/video/$videoId?autoplay=1';
    }

    // Google Drive
    final driveRegex = RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)');
    final driveMatch = driveRegex.firstMatch(url);
    if (driveMatch != null) {
      final fileId = driveMatch.group(1);
      return 'https://drive.google.com/file/d/$fileId/preview';
    }

    // Default: load URL as-is
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF335EF7),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل الفيديو...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
