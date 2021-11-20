import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class CatsBreedHomeScreen extends StatefulWidget {
  CatsBreedHomeScreen({Key? key}) : super(key: key);

  @override
  _CatsBreedHomeScreenState createState() => _CatsBreedHomeScreenState();
}

class _CatsBreedHomeScreenState extends State<CatsBreedHomeScreen> {
  File? _image;
  String result = "";
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    loadDataModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/cats_breed/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Stack(
                children: [
                  Center(
                    child: TextButton(
                      child: Container(
                        margin: EdgeInsets.only(top: 50, right: 30, left: 20),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                height: 360,
                                width: 400,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 140,
                                height: 190,
                                child: Icon(
                                  Icons.camera_sharp,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                      onPressed: () {
                        openGallery();
                      },
                      onLongPress: () {
                        openCamera();
                      },
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 90,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.blue,
                  backgroundColor: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadDataModel() async {
    String? output = await Tflite.loadModel(
      model: "assets/cats_breed/model_unquant.tflite",
      labels: "assets/cats_breed/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );

    print(output);
  }

  Future<void> doImageClasstification() async {
    if (_image == null) return;
    var recoganizer = await Tflite.runModelOnImage(
      path: _image!.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 0.0,
      imageStd: 255.0,
      asynch: true,
    );

    setState(() {
      result = "";
    });

    recoganizer?.forEach((element) {
      setState(() {
        result += element["label"] + "\n\n";
        ;
      });
    });
  }

  Future<void> openCamera() async {
    final pickedPicture = await picker.pickImage(source: ImageSource.camera);
    if (pickedPicture == null) return;

    setState(() {
      _image = File(pickedPicture.path);
      doImageClasstification();
    });
  }

  Future<void> openGallery() async {
    final pickedPicture = await picker.pickImage(source: ImageSource.gallery);
    if (pickedPicture == null) return;

    setState(() {
      _image = File(pickedPicture.path);
      doImageClasstification();
    });
  }
}
