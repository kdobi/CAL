import 'package:flutter/material.dart';
import 'package:calorie_calculation/take_picture.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TakePicture(),
    );
  }
}