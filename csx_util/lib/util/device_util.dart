import 'dart:math';
import 'package:flutter/material.dart';

/// 设备比率
class Devices {
  //像素密度
  double get pixelRatio => _pixelRatio!;

  //1像素
  double get onePx => _onePx!;

  //宽度
  double get width => _screenWidth!;

  //高度
  double get height => _screenHeight!;

  //宽度比率
  double get ratioWidth => _ratioWidth!;

  //高度比率
  double get ratioHeight => _ratioHeight!;

  //状态栏高度（顶部安全区域高度）
  double get statusHeight => _statusHeight!;

  //左侧安全区域的宽度
  double get safeLeftHeight => _safeLeftHeight!;

  //右侧安全区域的宽度
  double get safeRightHeight => _safeRightHeight!;

  //底部安全区域的高度
  double get safeBottomHeight => _safeBottomHeight!;

  static double? _pixelRatio;
  static double? _onePx;
  static double? _screenWidth;
  static double? _screenHeight;
  static double? _ratioWidth;
  static double? _ratioHeight;
  static double? _statusHeight;
  static double? _safeLeftHeight;
  static double? _safeRightHeight;
  static double? _safeBottomHeight;
  static Devices? _instance;

  Devices._({double? width = 375.0, double? height = 667.0});

  factory Devices() {
    assert(
      _instance != null,
      '\nEnsure to initialize Devices before accessing it.\nPlease execute the init method : Devices.init()',
    );
    return _instance!;
  }

  /// 初始化设计尺寸
  static void init({double? width = 375.0, double? height = 667.0}) {
    _instance ??= Devices._(width: width, height: height);
    var flutterView = WidgetsBinding.instance.platformDispatcher.views.first;
    _pixelRatio = flutterView.devicePixelRatio;
    _onePx = 1 / _pixelRatio!;
    _screenWidth = flutterView.physicalSize.width / _pixelRatio!;
    _screenHeight = flutterView.physicalSize.height / _pixelRatio!;
    _ratioWidth = width == null ? 1 : (_screenWidth! / width);
    _ratioHeight = height == null ? 1 : (_screenHeight! / height);
    var mediaQueryData = MediaQueryData.fromView(flutterView);
    _statusHeight = mediaQueryData.padding.top;
    _safeLeftHeight = mediaQueryData.padding.left;
    _safeRightHeight = mediaQueryData.padding.right;
    _safeBottomHeight = mediaQueryData.padding.bottom;
  }
}

extension SizeRatio on num {
  //屏幕宽比率
  double get ratioWidth {
    return this * Devices().ratioWidth;
  }

  //屏幕高比率
  double get ratioHeight {
    return this * Devices().ratioHeight;
  }

  double get ratio {
    return this * min(Devices().ratioWidth, Devices().ratioHeight);
  }
}
