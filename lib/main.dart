import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:getx_ml/cats_and_dog/screen/cats_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Getx ML',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CatsAndDogsHomeScreen(),
    );
  }
}
