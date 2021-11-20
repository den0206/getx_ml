import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class ClassicObjectsHome extends StatefulWidget {
  ClassicObjectsHome({Key? key}) : super(key: key);

  @override
  _ClassicObjectsHomeState createState() => _ClassicObjectsHomeState();
}

class _ClassicObjectsHomeState extends State<ClassicObjectsHome> {
  CameraImage? imgCamera;
  late CameraController cameraController;
  String result = "";
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/classic_objects/jarvis.jpg"),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      color: Colors.black87,
                      height: 320,
                      width: 360,
                      child: Image.asset("assets/classic_objects/camera.jpg"),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      child: Container(
                        height: 270,
                        width: 360,
                        margin: EdgeInsets.only(top: 35),
                        child: imgCamera == null
                            ? Container(
                                height: 270,
                                width: 360,
                                child: Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.pink,
                                  size: 50,
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
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initCamera() async {
    final camera = await availableCameras();

    cameraController = CameraController(
      camera[0],
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
          runModelFlame();
        }
      });
    });
  }

  Future<void> loadDataModel() async {
    await Tflite.loadModel(
      model: "assets/classic_objects/mobilenet_v1_1.0_224.tflite",
      labels: "assets/classic_objects/mobilenet_v1_1.0_224.txt",
    );
  }

  runModelFlame() async {
    if (imgCamera != null) {
      var recoganizations = await Tflite.runModelOnFrame(
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

      result = "";

      recoganizations?.forEach(
        (element) {
          result += element["label"] +
              "  " +
              (element["confidence"] as double).toStringAsFixed(2) +
              "\n\n";
        },
      );

      /// update ui
      setState(() {
        result;
      });

      _isWorking = false;
    }
  }
}
