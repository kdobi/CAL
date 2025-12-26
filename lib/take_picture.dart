import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_ai/firebase_ai.dart';

// ✅ Gemini 모델 생성 및 이미지 분석 서비스
class GeminiService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
  );

  static Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    const fixedPrompt = '''
이 사진이 음식이라면 분석해줘.
- 음식/재료 추정
- 대략적인 칼로리 범위(불확실하면 범위로)
- 주의할 점(알레르기/나트륨/당류 등) 있으면 함께
한국어로 간단히.
''';

    final response = await _model.generateContent([
      Content.multi([
        TextPart(fixedPrompt),
        InlineDataPart(mimeType, imageBytes),
      ]),
    ]);

    return response.text ?? '분석 결과 없음';
  }
}

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  final ImagePicker picker = ImagePicker();

  XFile? _image;
  String _analysisResult = '이미지를 선택하면 자동으로 분석됩니다.';
  bool _loading = false;

  Future<void> _analyzeSelectedImage(XFile image) async {
    setState(() {
      _loading = true;
      _analysisResult = '';
    });

    try {
      final bytes = await image.readAsBytes();
      final result = await GeminiService.analyzeImage(
        imageBytes: bytes,
        mimeType: image.mimeType ?? 'image/jpeg',
      );

      if (!mounted) return;
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analysisResult = '에러 발생: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> getGalleryImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = image;
    });

    await _analyzeSelectedImage(image);
  }

  Future<void> getCameraImage() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _image = image;
    });

    await _analyzeSelectedImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음식 사진 분석')),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // ✅ 카메라/갤러리 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loading ? null : getGalleryImage,
                child: const Text('gallery'),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                onPressed: _loading ? null : getCameraImage,
                child: const Text('camera'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),

          const SizedBox(height: 16),

          // ✅ 결과 표시 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_image != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_image!.path),
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: SizedBox(
                        height: 220,
                        child: Center(child: Text('사진을 선택하세요')),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Text(
                    '분석 결과',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_analysisResult, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
