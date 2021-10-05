import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen(this.videoPath, {Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(
      File(widget.videoPath),
    )..initialize().then((value) {
        setState(() {});
        videoPlayerController..play();
      });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
                videoPlayerController.value.isInitialized
            ? VideoPlayer(videoPlayerController)
            : Center(
                  child: CircularProgressIndicator(),
                ),
          SafeArea(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  CupertinoIcons.back,
                  color: Colors.black,
                ),
              ),
            ),
          ),
              ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.pause();
    videoPlayerController.dispose();
  }
}
