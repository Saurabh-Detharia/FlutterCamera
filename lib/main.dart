import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newcamera/player.dart';
import 'package:newcamera/recording_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {

  List<CameraDescription> cameras;
  MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecordingState()),
      ],
      child: MaterialApp(
        home: CameraApp(cameras),
      ),
    );
  }
}

class CameraApp extends StatefulWidget {

  List<CameraDescription> cameras;
  CameraApp(this.cameras);

  @override
  State<StatefulWidget> createState() {
    return CameraAppState();
  }
}

class CameraAppState extends State<CameraApp> {
  String videoPath = "";

  late RecordingState recordingStateProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      recordingStateProvider = Provider.of<RecordingState>(context, listen: false);
      initCamera(false);
    });
  }

  @override
  void dispose() {
    recordingStateProvider.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Consumer<RecordingState>(
          builder: (context, provider, child) {
            return provider != null &&
                    provider.cameraController != null &&
                    provider.cameraController.value.isInitialized
                ? CameraPreview(provider.cameraController, child: Icon(
              Icons.ac_unit,
              color: Colors.red,
              size: 100.0,
            ),)
                : Center(
                child: CircularProgressIndicator(

                ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // controller.pausePreview();
                setState(() {
                  recordingStateProvider.isFrontCam = !recordingStateProvider.isFrontCam;
                });
                initCamera(true);
                Fluttertoast.showToast(
                  msg: recordingStateProvider.isFrontCam ? "Front camera" : "Back camera",
                );
              },
              child: Icon(CupertinoIcons.switch_camera),
            ),
            SizedBox(
              height: 10.0,
            ),
            FloatingActionButton(
              onPressed: () {
                setZoomLevel();
              },
              child: Icon(CupertinoIcons.zoom_in),
            ),
            SizedBox(
              height: 10.0,
            ),
            FloatingActionButton(
              onPressed: () async {
                if (recordingStateProvider.cameraController.value.isInitialized &&
                    recordingStateProvider.cameraController.value.isRecordingVideo) {
                  var recordingFile = await recordingStateProvider.cameraController.stopVideoRecording();

                  Fluttertoast.showToast(
                    msg: "Recording stopped",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  int _time = DateTime.now().millisecondsSinceEpoch;

                  final Directory? extDir = Platform.isAndroid
                      ? await getExternalStorageDirectory()
                      : await getApplicationDocumentsDirectory();
                  final String dirPath = '${extDir!.path}/Movies';
                  await Directory(dirPath).create(recursive: true);
                  String filePath = '$dirPath/soda_$_time.mp4';

                  File outFile = File(recordingFile.path).copySync(filePath);
                  videoPath = outFile.path;
                  print('file exists:: ${outFile.exists()}');
                } else {
                  // await _initializeControllerFuture;
                  recordingStateProvider.cameraController.startVideoRecording();
                  Fluttertoast.showToast(
                    msg: "Recording started",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                }
              },
              child: Consumer<RecordingState>(
                builder: (context, provider, child) {
                  return Icon(
                    provider.cameraController != null && provider.cameraController.value.isInitialized && provider.cameraController.value.isRecordingVideo
                        ? CupertinoIcons.pause
                        : CupertinoIcons.video_camera_solid,
                    color: Colors.white,
                  );
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            FloatingActionButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => VideoPlayerScreen(videoPath),
                  ),
                );
              },
              child: Icon(
                CupertinoIcons.play_rectangle,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initCamera(bool isFlipping) async {
    CameraDescription camera = recordingStateProvider.isFrontCam ? widget.cameras[1] : widget.cameras[0];
    recordingStateProvider.cameraController = CameraController(camera, ResolutionPreset.max);
  }

  Future<void> setZoomLevel() async {
    double maxZoomLevel = await recordingStateProvider.cameraController.getMaxZoomLevel();
    print("max zoom level: $maxZoomLevel");
    recordingStateProvider.cameraController.setZoomLevel(maxZoomLevel);
  }
}
