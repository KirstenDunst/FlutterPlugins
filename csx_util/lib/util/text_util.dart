import 'package:flutter/material.dart';

class TextUtil {
  //计算文字Text大小
  static Size boundingTextSize(
    String? text,
    TextStyle style, {
    int maxLines = 2 ^ 31,
    double maxWidth = double.infinity,
    Locale? locale,
  }) {
    if (text == null || text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      locale: locale,
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return textPainter.size;
  }
}
