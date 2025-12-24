import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: getGalleryImage,
                child: Text('gallery'),
              ),
              ElevatedButton(onPressed: getCameraImage, child: Text('camera')),
            ],
          ),
        ],
      ),
    );
  }
}
