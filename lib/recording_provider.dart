import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class RecordingState extends ChangeNotifier {

  late CameraController _cameraController;
  bool _isFrontCam = true;
  late List<CameraDescription> _cameras;

  List<CameraDescription> get cameras => _cameras;

  set cameras(List<CameraDescription> value) {
    cameras = value;
    notifyListeners();
  }

  bool get isFrontCam => _isFrontCam;

  set isFrontCam(bool value) {
    _isFrontCam = value;
    notifyListeners();
  }

  CameraController get cameraController => _cameraController;

  set cameraController(CameraController value) {
    // late CameraController oldCameraController;
    // if (_cameraController != null) {
    //   oldCameraController = _cameraController;
    //   oldCameraController.removeListener(() { });
    //   oldCameraController.pausePreview();
    //   oldCameraController.dispose();
    // }
    _cameraController = value;

    _cameraController.initialize().then((_) async {
      _cameraController.buildPreview();
      _cameraController.prepareForVideoRecording();
      notifyListeners();
    });
  }
}