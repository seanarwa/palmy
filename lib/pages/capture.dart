import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:palmy/utils/camera_scanner.dart';
import 'package:palmy/utils/text_detector_painter.dart';

class CapturePage extends StatefulWidget {
  CapturePage({Key key}) : super(key: key);

  static final String routeName = '/capture';

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {

  final TextRecognizer _textRecognizer = FirebaseVision.instance.textRecognizer();
  final CameraLensDirection _direction = CameraLensDirection.back;
  VisionText _textScanResults;
  CameraDescription _cameraDescription;
  CameraController _camera;
  bool _isDetecting = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.stopImageStream();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.paused:
        _camera.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        _camera.startImageStream(onCameraImage);
        break;
      default:
        // Do nothing.
    }
    super.didChangeAppLifecycleState(state);
  }

  void _initializeCamera() async {
    _cameraDescription = await CameraScanner.getCamera(_direction);

    _camera = CameraController(
      _cameraDescription,
      ResolutionPreset.high,
    );

    await _camera.initialize();

    _camera.startImageStream(onCameraImage);
  }

  void onCameraImage(CameraImage image) async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
    });
    VisionText result = await CameraScanner.detect(
      image: image,
      detectInImage: _getDetectionMethod(),
      imageRotation: _cameraDescription.sensorOrientation,
    );
    setState(() {
      if(result != null) {
        _textScanResults = result;
      }
      _isDetecting = false;
    });
  }

  Future<VisionText> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _textRecognizer.processImage;
  }

  Widget _renderCamera() {
    if(_camera == null) {
      return Container();
    }
    return Container(
      child: CameraPreview(_camera),
    );
  }

  Widget _renderTextResults() {
    CustomPainter painter;
    if (_textScanResults != null) {
      final Size imageSize = Size(
        _camera.value.previewSize.height - 100,
        _camera.value.previewSize.width,
      );
      painter = TextDetectorPainter(imageSize, _textScanResults);

      return CustomPaint(
        painter: painter,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _renderCamera(),
          _renderTextResults(),
        ],
      ),
    );
  }
}

