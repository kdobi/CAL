import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_ai/firebase_ai.dart';

// ✅ Gemini 모델 생성 및 이미지 분석 서비스
class GeminiService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    // static의 경우 공용으로 사용해야할 때 보통 사용하며 중복생성을 방지하고 재사용에 용이하다.
    // 그래서 네트워크 클라이언트/모델처럼 “하나만” 유지할 객체에서도 사용한다
  );

  static Future<String> analyzeImage({
    required Uint8List
    imageBytes, // [255, 06, 13, ...] - Ram상에 올라온 이미지 그 자체, Ai가 이미지 경로를 알 수 없기 때문.
    required String
    mimeType, // 어떤 이미지인지 설명 (image/jpeg = 사진),  (image/png = PNG 이미지)
  }) async {
    const fixedPrompt = ''' 
이 사진이 음식이라면 분석해줘.
- 음식/재료 추정
- 대략적인 칼로리 범위(불확실하면 범위로)
- 주의할 점(알레르기/나트륨/당류 등) 있으면 함께
한국어로 간단히. 
'''; // 추후 프롬포트 디테일하기 수정할 것.

    final response = await _model.generateContent([
      Content.multi([
        // 단일 데이터여서 stream 사용 X
        TextPart(fixedPrompt), // 명령 프롬포트 전달
        InlineDataPart(mimeType, imageBytes), // 이미지 데이터 전달 (이미지 타입, 실제 이미지 값)
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

  // 이미지가 선택 돼었을 경우 => 이미지 분석
  Future<void> _analyzeSelectedImage(XFile image) async {
    setState(() {
      _loading = true; // Gemini 분석 진행중
      _analysisResult = ''; // 모든 분석 결과 초기화
    });

    try {
      final bytes = await image.readAsBytes(); // 이미지 파일을 Ai가 인식할 수 있는 바이트로 변환
      final result = await GeminiService.analyzeImage(
        // 제미나이 호출, analyzeImage로 값 전달
        imageBytes: bytes,
        mimeType: image.mimeType ?? 'image/jpeg',
      );

      if (!mounted) return; // 사용자가 화면을 나갔을 때 크래시 방지
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

  // 갤러리 이미지 사진 가져오는 함수
  Future<void> getGalleryImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = image;
    });

    await _analyzeSelectedImage(image);
  }

  // 카메라 이미지 가져오는 함수
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
                onPressed: _loading ? null : getGalleryImage, // 로딩중 버튼 비활성화
                child: const Text('gallery'),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                onPressed: _loading ? null : getCameraImage, // 로딩중 버튼 비활성화
                child: const Text('camera'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(), // 비동기 로딩

          const SizedBox(height: 16),

          // ✅ 결과 표시 영역
          Expanded(
            child: SingleChildScrollView(
              // expand와 세트, 세로 최대 영역 차지
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_image != null)
                    Center(
                      child: ClipRRect(
                        // 모서리 둥글게
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
