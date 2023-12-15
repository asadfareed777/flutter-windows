
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

class MyVideoApp extends StatefulWidget {
  const MyVideoApp({Key? key}) : super(key: key);

  @override
  State<MyVideoApp> createState() => _MyVideoAppState();
}

class _MyVideoAppState extends State<MyVideoApp> {

  VideoPlayerController? controller;

  void reload() {
    controller?.dispose();
    controller = VideoPlayerController.file(File("C:\\Users\\Lenovo\\Downloads\\sample.mp4"));
    //controller = WinVideoPlayerController.file(File("E:\\test_youtube.mp4"));
   // controller = VideoPlayerController.networkUrl(Uri.parse("https://media.w3.org/2010/05/sintel/trailer.mp4"));
    //controller = WinVideoPlayerController.file(File("E:\\Downloads\\0.FDM\\sample-file-1.flac"));
    controller!.initialize().then((value) {
      if (controller!.value.isInitialized) {
        controller!.play();
        setState(() {});

        controller!.addListener(() {
          if (controller!.value.isCompleted) {
            log("ui: player completed, pos=${controller!.value.position}");
          }
        });
      } else {
        log("video file load failed");
      }
    }).catchError((e) {
      log("controller.initialize() error occurs: $e");
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('video_player_win example app'),
        ),
        body: Stack(children: [
          VideoPlayer(controller!),
          Positioned(
              bottom: 0,
              child: Column(children: [
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller!,
                  builder: ((context, value, child) {
                    int minute = value.position.inMinutes;
                    int second = value.position.inSeconds % 60;
                    String timeStr = "$minute:$second";
                    if (value.isCompleted) timeStr = "$timeStr (completed)";
                    return Text(timeStr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.white,
                            backgroundColor: Colors.black54));
                  }),
                ),
                ElevatedButton(
                    onPressed: () => reload(),
                    child: const Text("Reload")),
                ElevatedButton(
                    onPressed: () => controller?.play(),
                    child: const Text("Play")),
                ElevatedButton(
                    onPressed: () => controller?.pause(),
                    child: const Text("Pause")),
                ElevatedButton(
                    onPressed: () => controller?.seekTo(Duration(
                        milliseconds:
                        controller!.value.position.inMilliseconds +
                            10 * 1000)),
                    child: const Text("Forward")),
                ElevatedButton(
                    onPressed: () {
                      int ms = controller!.value.duration.inMilliseconds;
                      var tt = Duration(milliseconds: ms - 1000);
                      controller?.seekTo(tt);
                    },
                    child: const Text("End")),
              ])),
        ]),
      ),
    );
  }
}