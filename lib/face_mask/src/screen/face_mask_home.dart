import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class FaceMaskHome extends StatefulWidget {
  FaceMaskHome({Key? key}) : super(key: key);

  @override
  _FaceMaskHomeState createState() => _FaceMaskHomeState();
}

class _FaceMaskHomeState extends State<FaceMaskHome> {
  CameraImage? imgCamera;
  late CameraController cameraController;
  bool isWorking = false;
  String result = "";

  @override
  void initState() async {
    super.initState();

    await initCamera();
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
          title: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                result,
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black87,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Positioned(
              top: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 100,
              child: Container(
                height: MediaQuery.of(context).size.height - 100,
                child: (!cameraController.value.isInitialized)
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),
              ),
            )
          ],
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
        if (!isWorking) {
          isWorking = true;
          imgCamera = cameraImage;
          rnuModelOnFlame();
        }
      });
    });
  }

  Future<void> loadDataModel() async {
    await Tflite.loadModel(
      model: "assets/face_mask/model.tflite",
      labels: "assets/face_mask/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  rnuModelOnFlame() async {
    if (imgCamera != null) {
      var recoganizations = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((e) => e.bytes).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );

      result = "";

      recoganizations?.forEach((element) {
        result += element["label"] + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }
}
