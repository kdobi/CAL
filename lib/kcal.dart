import 'dart:io';
import 'package:flutter/material.dart';

class Kcal extends StatelessWidget {
  final String analysisResult;
  final String imagePath;

  const Kcal({
    super.key,
    required this.analysisResult,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사진 분석 결과')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(30),
            child: Image.file(File(imagePath), fit: BoxFit.cover, width: 250),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.all(20),
              child: Text(analysisResult),
            ),
          ),
        ],
      ),
    );
  }
}
