import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

class BoxAroundRecognitionHome extends StatefulWidget {
  BoxAroundRecognitionHome({Key? key}) : super(key: key);

  @override
  _BoxAroundRecognitionHomeState createState() =>
      _BoxAroundRecognitionHomeState();
}

class _BoxAroundRecognitionHomeState extends State<BoxAroundRecognitionHome> {
  double? imgHeight;
  double? imgWidth;
  CameraImage? imgCamera;
  late CameraController cameraController;

  List? resultsList;
  bool _isWorking = false;

  @override
  void initState() async {
    super.initState();

    await loadDataModel();
  }

  @override
  void dispose() async {
    super.dispose();

    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0,
      left: 0,
      width: size.width,
      height: size.height - 100,
      child: Container(
        height: size.height - 100,
        child: (!cameraController.value.isInitialized)
            ? Container()
            : AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              ),
      ),
    ));

    if (imgCamera != null) {
      stackChildren.addAll(displayBoxedAround(size));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          margin: EdgeInsets.only(top: 50),
          color: Colors.black,
          child: Stack(
            children: stackChildren,
          ),
        ),
      ),
    );
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController.initialize();

    if (!mounted) return;

    setState(() {
      cameraController.startImageStream((CameraImage cameraImage) {
        if (!_isWorking) {
          _isWorking = true;
          imgCamera = cameraImage;
          runModelOnFrame();
        }
      });
    });
  }

  Future<void> loadDataModel() async {
    await Tflite.close();

    try {
      String response;
      response = (await Tflite.loadModel(
        model: "assets/box_around_recognition/ssd_mobilenet.tflite",
        labels: "assets/box_around_recognition/ssd_mobilenet.txt",
        isAsset: true,
        useGpuDelegate: false,
      ))!;

      print(response);
    } on PlatformException {
      print("Unable to load model");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> runModelOnFrame() async {
    if (imgCamera == null) return;
    imgHeight = imgCamera!.height.toDouble();
    imgHeight = imgCamera!.width.toDouble();

    resultsList = await Tflite.detectObjectOnFrame(
      bytesList: imgCamera!.planes.map((e) => e.bytes).toList(),
      model: "SSDMobileNet",
      imageHeight: imgCamera!.height,
      imageWidth: imgCamera!.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      rotation: 90,
      threshold: 0.4,
    );

    _isWorking = false;

    setState(() {
      imgCamera;
    });
  }

  List<Widget> displayBoxedAround(Size screen) {
    if (resultsList == null) return [];
    if (imgHeight == null || imgWidth == null) return [];

    double factorX = screen.width;
    double factorY = imgHeight!;

    return resultsList!.map((result) {
      return Positioned(
        left: result["rect"]["x"] + factorX,
        top: result["rect"]["y"] + factorY,
        width: result["rect"]["w"] + factorX,
        height: result["rect"]["h"] + factorY,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.pink, width: 2)),
          child: Text(
            "${result["detectedClass"]} ${(result["confidenceInClass"] * 100).toStringAsFixed(2)} ",
            style: TextStyle(
              background: Paint()..color = Colors.pink,
              fontSize: 18,
            ),
          ),
        ),
      );
    }).toList();
  }
}
