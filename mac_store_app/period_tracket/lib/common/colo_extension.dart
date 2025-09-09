import 'package:flutter/material.dart';

class TColor {
  // Màu hồng chính theo yêu cầu
  static Color get primaryColor1 =>
      const Color(0xFFFF9AAD); // Pink như trong hình
  static Color get primaryColor2 =>
      const Color(0xFFFF7A9A); // Pink đậm hơn một chút

  // Gradient hồng pastel
  static List<Color> get primaryG => [primaryColor1, primaryColor2];

  // Màu đen nhạt hơn để hài hòa với theme pastel
  static Color get black => const Color(0xFF2D2D2D);

  // Màu xám nhẹ với tone hồng
  static Color get gray => const Color(0xFFB8A5A5);

  // Màu trắng
  static Color get white => Colors.white;

  // Màu nền nhẹ với tone hồng tương tự
  static Color get lightGray => const Color(0xFFFFF0F3);

  // Thêm một số màu hồng tương tự để sử dụng
  static Color get softPink => const Color(0xFFFFCDD2); // Hồng nhẹ
  static Color get blushPink => const Color(0xFFFFADB7); // Hồng trung bình
  static Color get rosePink => const Color(0xFFFF8A9B); // Hồng đậm
  static Color get coral => const Color(0xFFFF6B7A); // Hồng coral
}
