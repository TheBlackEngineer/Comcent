import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieListItem extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool showControls;

  const ChewieListItem({Key key, @required this.videoPlayerController, this.showControls})
      : super(key: key);

  @override
  _ChewieListItemState createState() => _ChewieListItemState();
}

class _ChewieListItemState extends State<ChewieListItem> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: true,
      looping: false,
      showControls: widget.showControls == null ? true : widget.showControls,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Video not found',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
