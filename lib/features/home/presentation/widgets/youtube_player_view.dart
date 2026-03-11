import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YoutubePlayerView extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool mute;

  const YoutubePlayerView({
    Key? key,
    required this.videoId,
    this.autoPlay = true,
    this.mute = false,
  }) : super(key: key);

  @override
  State<YoutubePlayerView> createState() => _YoutubePlayerViewState();
}

class _YoutubePlayerViewState extends State<YoutubePlayerView> {
  bool _isLoading = true;
  InAppWebViewController? _controller;

  String _buildHtmlPage() {
    final autoplay = widget.autoPlay ? '1' : '0';
    final mute = widget.mute ? '1' : '0';

    // Use YouTube IFrame Player API - the official way to embed YouTube videos
    // This avoids Error 150/152 by using YouTube's own JS API
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    #player { width: 100%; height: 100%; }
    iframe { width: 100% !important; height: 100% !important; }
  </style>
</head>
<body>
  <div id="player"></div>

  <script>
    // Load YouTube IFrame API
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        videoId: '${widget.videoId}',
        width: '100%',
        height: '100%',
        playerVars: {
          'autoplay': $autoplay,
          'mute': $mute,
          'controls': 1,
          'rel': 0,
          'modestbranding': 1,
          'playsinline': 1,
          'iv_load_policy': 3,
          'fs': 1,
          'cc_load_policy': 0,
          'disablekb': 0,
          'showinfo': 0
        },
        events: {
          'onReady': onPlayerReady,
          'onError': onPlayerError,
          'onStateChange': onPlayerStateChange
        }
      });
    }

    function onPlayerReady(event) {
      console.log('Player ready!');
      // Resize to fill container
      var container = document.getElementById('player');
      if (container) {
        var iframe = container.querySelector('iframe');
        if (iframe) {
          iframe.style.width = '100%';
          iframe.style.height = '100%';
        }
      }
      if ($autoplay === 1) {
        event.target.playVideo();
      }
    }

    function onPlayerError(event) {
      console.log('Player error: ' + event.data);
      // Error codes:
      // 2: invalid parameter
      // 5: HTML5 player error
      // 100: video not found
      // 101/150: video not allowed to embed

      if (event.data === 150 || event.data === 101) {
        // Embedding not allowed - try loading directly
        console.log('Embedding restricted, trying direct load...');
        document.body.innerHTML = '<iframe src="https://www.youtube.com/embed/${widget.videoId}?autoplay=$autoplay&mute=$mute&controls=1&rel=0&playsinline=1" style="width:100%;height:100%;border:none;" allow="accelerometer;autoplay;clipboard-write;encrypted-media;gyroscope;picture-in-picture" allowfullscreen></iframe>';
      }
    }

    function onPlayerStateChange(event) {
      console.log('Player state: ' + event.data);
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: _buildHtmlPage(),
                  mimeType: 'text/html',
                  encoding: 'utf-8',
                  // Don't set baseUrl to youtube.com - use a neutral one
                  baseUrl: WebUri('https://player.local'),
                ),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  allowsInlineMediaPlayback: true,
                  iframeAllowFullscreen: true,
                  allowsBackForwardNavigationGestures: false,
                  supportZoom: false,
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
                  transparentBackground: false,
                  disableHorizontalScroll: true,
                  disableVerticalScroll: true,
                  javaScriptCanOpenWindowsAutomatically: false,
                  useHybridComposition: true,
                  cacheEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  hardwareAcceleration: true,
                ),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onWebViewCreated: (controller) {
                  _controller = controller;
                },
                onLoadStop: (controller, url) async {
                  debugPrint('YouTube page loaded');
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                },
                onReceivedError: (controller, request, error) {
                  debugPrint('WebView Error: ${error.description}');
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('YT: ${consoleMessage.message}');
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF335EF7),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
