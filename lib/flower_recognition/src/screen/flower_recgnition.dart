import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class FlowerRecgnitionHome extends StatefulWidget {
  FlowerRecgnitionHome({Key? key}) : super(key: key);

  @override
  _FlowerRecgnitionHomeState createState() => _FlowerRecgnitionHomeState();
}

class _FlowerRecgnitionHomeState extends State<FlowerRecgnitionHome> {
  final ImagePicker picker = ImagePicker();
  File? _image;
  String result = "";

  bool get _loading {
    return _image == null;
  }

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              "GetX",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 40,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Flower Detrection",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: _loading
                  ? Container(
                      width: 350,
                      child: Column(
                        children: [
                          Image.asset("assets/flower_recognition/flowers.png"),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Image.file(_image!),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          result.isNotEmpty
                              ? Text(result,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ))
                              : Container()
                        ],
                      ),
                    ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.fromSize(
                    size: Size(100, 100),
                    child: ClipOval(
                      child: Material(
                        color: Colors.orange,
                        child: InkWell(
                          splashColor: Colors.green,
                          onTap: () {
                            openPicker(ImageSource.camera);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 40,
                              ),
                              Text("Camera"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  SizedBox.fromSize(
                    size: Size(100, 100),
                    child: ClipOval(
                      child: Material(
                        color: Colors.orange,
                        child: InkWell(
                          splashColor: Colors.green,
                          onTap: () {
                            openPicker(ImageSource.gallery);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo,
                                size: 40,
                              ),
                              Text("Gallery"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/flower_recognition/model_unquant.tflite",
      labels: "assets/flower_recognition/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> openPicker(ImageSource source) async {
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
      recognitionFlower();
    });
  }

  Future<void> recognitionFlower() async {
    if (_image == null) return;
    var recognizer = await Tflite.runModelOnImage(
      path: _image!.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
      asynch: true,
    );

    result = "";
    recognizer?.forEach(
      (element) {
        setState(() {
          result += element["label"] + "\n\n";
        });
      },
    );
  }
}
