import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

// 제미나이 모델 생성 및 프롬포트
class GeminiService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
  );

  static Future<String> generateText(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  XFile? _image; // 이미지 변수 선언

  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화

  // 갤러리 이미지 함수 생성
  Future getGalleryImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  // 카메라 이미지 함수 생성
  Future getCameraImage() async {
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          // 카메라, 갤러리 선택버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: getGalleryImage,
                child: Text('gallery'),
              ),
              SizedBox(width: 30),
              ElevatedButton(onPressed: getCameraImage, child: Text('camera')),
            ],
          ),

          Container(),
        ],
      ),
    );
  }
}
