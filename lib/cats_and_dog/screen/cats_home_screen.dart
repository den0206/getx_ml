import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class CatsAndDogsHomeScreen extends StatefulWidget {
  CatsAndDogsHomeScreen({Key? key}) : super(key: key);

  @override
  _CatsAndDogsHomeScreenState createState() => _CatsAndDogsHomeScreenState();
}

class _CatsAndDogsHomeScreenState extends State<CatsAndDogsHomeScreen> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

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
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "Cats and Dogs Detector",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
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
                          Image.asset(
                            "assets/cats_and_dogs/cat_dog_icon.png",
                          ),
                          SizedBox(
                            height: 47.0,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 280,
                            child: Image.file(_image),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          _output.isNotEmpty
                              ? Text(
                                  "${_output[0]["label"]}",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                )
                              : Container(),
                          SizedBox(
                            height: 22,
                          )
                        ],
                      ),
                    ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      capturePhoneCamera();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Camera",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      capturePhoneGallery();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Gallery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Future<void> capturePhoneCamera() async {
    XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
    });

    detectImage(_image);
  }

  Future<void> capturePhoneGallery() async {
    XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
    });

    detectImage(_image);
  }

  Future<void> loadModel() async {
    String? output = await Tflite.loadModel(
      model: "assets/cats_and_dogs/model_unquant.tflite",
      labels: "assets/cats_and_dogs/cats_and_dogs_labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );

    print(output);
  }

  Future<void> detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output == null) return;
    setState(() {
      _output = output;
      _loading = false;
    });
  }
}
