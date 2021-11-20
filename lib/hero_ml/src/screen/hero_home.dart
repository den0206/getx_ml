import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HeroHomeScreen extends StatefulWidget {
  const HeroHomeScreen({Key? key}) : super(key: key);

  @override
  State<HeroHomeScreen> createState() => _HeroHomeScreenState();
}

class _HeroHomeScreenState extends State<HeroHomeScreen> {
  Future<File>? imageFile;
  File? _image;
  String result = "";
  ImagePicker? imagePicker;

  @override
  void initState() {
    super.initState();

    imagePicker = ImagePicker();
    loadMLModelFile();
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Stack(
                children: [
                  Center(
                    child: TextButton(
                      child: Container(
                          margin: EdgeInsets.only(
                            top: 30,
                            right: 35,
                            left: 18,
                          ),
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
                                    Icons.camera_alt_rounded,
                                    color: Colors.black,
                                  ),
                                )),
                      onPressed: () {
                        galleryImage();
                      },
                      onLongPress: () {
                        capturePhoto();
                      },
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 160,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.pink,
                  backgroundColor: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> galleryImage() async {
    XFile? pickedImage =
        await imagePicker!.pickImage(source: ImageSource.gallery);

    _image = File(pickedImage!.path);
    setState(() {
      _image;
      clastificationImage();
    });
  }

  Future<void> capturePhoto() async {
    XFile? pickedImage =
        await imagePicker!.pickImage(source: ImageSource.camera);

    _image = File(pickedImage!.path);

    setState(() {
      _image;
      clastificationImage();
    });
  }

  loadMLModelFile() async {
    String? output = await Tflite.loadModel(
      model: "assets/model_marvel.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );

    print(output);
  }

  clastificationImage() async {
    var recognizer = await Tflite.runModelOnImage(
        path: _image!.path,
        imageMean: 0.0,
        imageStd: 255,
        numResults: 1,
        threshold: 0.1,
        asynch: true);

    print(recognizer!.length.toString());

    setState(() {
      result = "";
    });

    recognizer.forEach((element) {
      setState(() {
        print(element.toString());
        result += element["label"] + "\n\n";
      });
    });
  }
}
