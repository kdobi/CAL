import 'dart:io';
import 'package:flutter/material.dart';

class Kcal extends StatelessWidget {
  final String food;
  final String imagePath;
  final double kcal;
  final double carbs;
  final double protein;
  final double fat;
  final double sugar;
  final String notes;

  const Kcal({
    super.key,
    required this.food,
    required this.imagePath,
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food), backgroundColor: Colors.blue[200]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                ),
              ),
            ),

            SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단: "식단 기록" + kcal(우측)
                    Row(
                      children: [
                        const Text(
                          '식단 기록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${kcal.toStringAsFixed(0)}kcal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // 영양소 4개 + 당류
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutrientItem(
                          label: '탄수화물',
                          valueText: '${carbs.toStringAsFixed(1)}g',
                          icon: Icons.rice_bowl,
                          color: Colors.green,
                        ),
                        _nutrientItem(
                          label: '단백질',
                          valueText: '${protein.toStringAsFixed(1)}g',
                          icon: Icons.egg_alt,
                          color: Colors.orange,
                        ),
                        _nutrientItem(
                          label: '지방',
                          valueText: '${fat.toStringAsFixed(1)}g',
                          icon: Icons.water_drop,
                          color: Colors.amber,
                        ),
                        _nutrientItem(
                          label: '당류',
                          valueText: '${sugar.toStringAsFixed(1)}g',
                          icon: Icons.cookie,
                          color: Colors.brown,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      ' * 주의사항 * ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientItem({
    required String label,
    required String valueText,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 26, color: color),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          valueText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
