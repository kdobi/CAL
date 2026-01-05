import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calorie_calculation/kcal.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ✅ Gemini 모델 생성 및 이미지 분석 서비스
class GeminiService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
  );

  static Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    const fixedPrompt = '''
이 사진이 음식이라면 아래 JSON 형식으로만 답해줘. 다른 문장/설명/마크다운 절대 금지.

{
  "food": "음식명 간결하게",
  "kcal": 0,
  "carbs_g": 0,
  "protein_g": 0,
  "fat_g": 0,
  "sugar_g": 0,
  "notes": "주의할 점(알레르기/나트륨/당류 등) 상세하게, 없으면 빈 문자열"
}

규칙:
- 숫자는 정수/소수 가능
- 추정치면 그대로 숫자로 입력
- 모르면 null로 입력
- 반드시 JSON만 출력
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

/// ✅ 파싱된 영양 정보 모델
class NutritionResult {
  final String? food;
  final double? kcal;
  final double? carbsG;
  final double? proteinG;
  final double? fatG;
  final double? sugarG;
  final String? notes;

  const NutritionResult({
    this.food,
    this.kcal,
    this.carbsG,
    this.proteinG,
    this.fatG,
    this.sugarG,
    this.notes,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory NutritionResult.fromJson(Map<String, dynamic> json) {
    return NutritionResult(
      food: json['food']?.toString(),
      kcal: _toDouble(json['kcal']),
      carbsG: _toDouble(json['carbs_g']),
      proteinG: _toDouble(json['protein_g']),
      fatG: _toDouble(json['fat_g']),
      sugarG: _toDouble(json['sugar_g']),
      notes: json['notes']?.toString(),
    );
  }
}

/// ✅ Gemini 응답에서 JSON 객체만 추출
String extractJsonObject(String text) {
  final trimmed = text.trim(); // 앞뒤 공백 제거

  final noFence = trimmed
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();

  final start = noFence.indexOf('{');
  final end = noFence.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) {
    throw FormatException('JSON 객체를 찾지 못했습니다: $text');
  }
  return noFence.substring(start, end + 1);
}

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  final ImagePicker picker = ImagePicker();

  XFile? _image;

  bool _loading = false;
  NutritionResult? _nutrition;

  // 선택된 이미지 분석하는 함수
  Future<void> _analyzeSelectedImage(XFile image) async {
    setState(() {
      _loading = true;
      _nutrition = null;
    });

    try {
      final bytes = await image.readAsBytes();
      final resultText = await GeminiService.analyzeImage(
        imageBytes: bytes,
        mimeType: image.mimeType ?? 'image/jpeg',
      );

      final jsonOnly = extractJsonObject(resultText); // { json : 이것만 받아옴 }
      final Map<String, dynamic> map = jsonDecode(jsonOnly);
      final nutrition = NutritionResult.fromJson(map);

      if (!mounted) return;

      setState(() {
        _nutrition = nutrition;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Kcal(
            food: nutrition.food ?? '',
            imagePath: _image!.path,
            kcal: nutrition.kcal ?? 0,
            carbs: nutrition.carbsG ?? 0,
            protein: nutrition.proteinG ?? 0,
            fat: nutrition.fatG ?? 0,
            sugar: nutrition.sugarG ?? 0,
            notes: nutrition.notes ?? '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  // 갤러리 이미지 받아오는 함수
  Future<void> getGalleryImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = image;
    });

    await _analyzeSelectedImage(image);
  }

  // 카메라 이미지 받아오는 함수
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
      appBar: AppBar(
        title: const Text('음식 사진 분석'),
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70, bottom: 110),
            child: !_loading
                // 이미지가 등록되지 않았을때 메인화면
                ? SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_size_select_actual_rounded,
                          size: 48,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '사진을 등록해주세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  )
                // ✅ 분석(로딩) 중일 때 이미지 보여주기
                : ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    child: Image.file(
                      File(_image!.path),
                      width: MediaQuery.of(context).size.width - 30,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          SizedBox(
            height: 2,
            child: Stack(
              children: [
                Container(color: Colors.grey[300]),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : getGalleryImage,
                    child: const Icon(
                      Icons.picture_in_picture_alt_rounded,
                      color: Colors.black,
                    ),
                  ),
                  const Text('사진첩'),
                ],
              ),
              const SizedBox(width: 80),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : getCameraImage,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  const Text('카메라'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
