import 'dart:io';

import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';

import 'engine/csx_http.dart';
import 'model/dokit_model.dart';
import 'page/kits_page.dart';
import 'widget/enter_widget.dart';

typedef CustomCallback = Function(BuildContext context, dynamic value);

final routeSettings = RouteSettings(
  name: dkPackageName,
  arguments: 'CsxKitShare',
);

class CsxKitShare {
  factory CsxKitShare() => _getInstance();
  static CsxKitShare get instance => _getInstance();
  static CsxKitShare? _instance;
  static CsxKitShare _getInstance() {
    _instance ??= CsxKitShare._internal();
    return _instance!;
  }

  CsxKitShare._internal();

  //记录外附回调
  Map<DokitCallType, CustomCallback>? get doCustomCallMap => _customCallMap;
  Map<DokitCallType, CustomCallback>? _customCallMap;

  Function(String)? _toastCall, _printLogCall;
  late GlobalKey<NavigatorState> _navigatorKey;
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  BuildContext? get overlayContext =>
      _navigatorKey.currentState?.overlay?.context;
  Size get screenSize => _screenSize;
  late Size _screenSize;
  ValueNotifier<bool> get showMenuNotifier => _showMenuNotifier;
  late ValueNotifier<bool> _showMenuNotifier;
  EdgeInsets get areaPadding => _areaPadding;
  late EdgeInsets _areaPadding;

  OverlayState get overlayState => _overlayState;
  late OverlayState _overlayState;

  /// 使用初始化
  void init(
    Function(String) toastCall,
    Function(String) printLogCall,
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey, {
    Map<DokitCallType, CustomCallback>? customCallMap,
  }) {
    _showMenuNotifier = ValueNotifier(true);
    _navigatorKey = navigatorKey;
    _toastCall = toastCall;
    _printLogCall = printLogCall;
    _customCallMap = customCallMap;
    _areaPadding = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).padding;
    final origin = HttpOverrides.current;
    HttpOverrides.global = DoKitHttpOverrides(origin);
    var flutterView = WidgetsBinding.instance.platformDispatcher.views.first;
    _screenSize = Size(
      flutterView.physicalSize.width / flutterView.devicePixelRatio,
      flutterView.physicalSize.height / flutterView.devicePixelRatio,
    );
    _showEnterIcon(context);
  }

  /// 退出处理
  void close() {
    HttpOverrides.global = null;
    _closeEnterIcon();
  }

  void toast(String msg) {
    _toastCall?.call(msg);
  }

  void printLog(String msg) {
    _printLogCall?.call(msg);
  }

  BuildContext? _dialogContext;
  void showDetailPage() {
    if (_dialogContext?.mounted ?? false) {
      Navigator.of(_dialogContext!).pop();
      return;
    }
    showModalBottomSheet(
      context: overlayContext!,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: _screenSize.height / 4 * 3),
      builder: (cont) {
        _dialogContext = cont;
        return KitsPage();
      },
      routeSettings: routeSettings,
    ).then((_) => _dialogContext = null);
  }


  OverlayEntry? _kitOverlay;
  void _showEnterIcon(BuildContext context) {
    _overlayState = Overlay.of(context);
    _kitOverlay ??= OverlayEntry(builder: (cont) => FloatingIconOverlay());
    if (_kitOverlay != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _overlayState.insert(_kitOverlay!),
      );
    }
  }

  void _closeEnterIcon() {
    _kitOverlay?.remove();
  }

  void hiddenMenu() {
    if (_dialogContext != null) {
      _showMenuNotifier.value = false;
    }
  }

  void showMenu() {
    _showMenuNotifier.value = true;
  }
}
