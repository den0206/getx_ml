import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class FruitDetectHome extends StatefulWidget {
  FruitDetectHome({Key? key}) : super(key: key);

  @override
  _FruitDetectHomeState createState() => _FruitDetectHomeState();
}

class _FruitDetectHomeState extends State<FruitDetectHome> {
  String result = "";
  bool _isWorking = false;
  CameraImage? imgCamera;
  late CameraController cameraController;

  @override
  void initState() async {
    super.initState();

    // await initCamera();
    await loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    await cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Test',
          ),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/friuts_detect/back.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 100),
                      height: 220,
                      width: 320,
                      child: Image.asset("assets/friuts_detect/frame.jpg"),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      child: Container(
                        margin: EdgeInsets.only(top: 65),
                        height: 270,
                        width: 360,
                        child: imgCamera == null
                            ? Container(
                                height: 270,
                                width: 360,
                                child: Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.pink,
                                  size: 60,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: cameraController.value.aspectRatio,
                                child: CameraPreview(cameraController),
                              ),
                      ),
                      onPressed: () {
                        initCamera();
                      },
                    ),
                  )
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 55),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
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
    setState(() {
      cameraController.startImageStream((CameraImage cameraImage) {
        if (!_isWorking) {
          _isWorking = true;
          imgCamera = cameraImage;
          detectImage();
        }
      });
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/friuts_detect/modelfruits.tflite",
      labels: "assets/friuts_detect/labelsfruits.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> detectImage() async {
    if (imgCamera == null) return;
    var recognization = await Tflite.runModelOnFrame(
      bytesList: imgCamera!.planes.map((e) => e.bytes).toList(),
      imageHeight: imgCamera!.height,
      imageWidth: imgCamera!.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );

    if (recognization == null) return;

    result = "";

    recognization.forEach((element) {
      setState(() {
        result += element["label"] +
            "  " +
            (element["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
        ;
      });
    });

    _isWorking = false;
  }
}
