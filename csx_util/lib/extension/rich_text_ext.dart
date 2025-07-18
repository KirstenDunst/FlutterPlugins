import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 富文本计算
class RichModel {
  String contentStr;
  TextStyle textStyle;
  VoidCallback? tap;

  RichModel({required this.contentStr, required this.textStyle, this.tap});

  InlineSpan toTextSpan() {
    return TextSpan(
      text: contentStr,
      style: textStyle,
      recognizer: TapGestureRecognizer()..onTap = tap,
    );
  }
}

extension RichModelList on List<RichModel> {
  TextSpan toTextSpan() {
    return TextSpan(children: map((e) => e.toTextSpan()).toList());
  }
}
