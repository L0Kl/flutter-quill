import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoApp extends StatefulWidget {
  const YoutubeVideoApp(
      {required this.videoUrl,
      required this.context,
      required this.readOnly,
      super.key});

  final String videoUrl;
  final BuildContext context;
  final bool readOnly;

  @override
  YoutubeVideoAppState createState() => YoutubeVideoAppState();
}

class YoutubeVideoAppState extends State<YoutubeVideoApp> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyles = DefaultStyles.getInstance(context);
    final youtubeController = _youtubeController;

    if (youtubeController == null) {
      if (widget.readOnly) {
        return RichText(
          text: TextSpan(
              text: widget.videoUrl,
              style: defaultStyles.link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(Uri.parse(widget.videoUrl))),
        );
      }

      return RichText(
          text: TextSpan(text: widget.videoUrl, style: defaultStyles.link));
    }

    return SizedBox(
      height: 300,
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: youtubeController,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return Column(
            children: [
              // some widgets
              player,
              //some other widgets
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _youtubeController?.dispose();
  }
}