import 'package:flutter/material.dart';

import '../apm.dart';
import '../csx_dokit.dart';
import 'dokit_app.dart';
import 'resident_page.dart';

// 入口btn
// ignore: must_be_immutable
class DoKitBtn extends StatefulWidget {
  //DoKitBtn 点击事件回调,true : dokit面板展开,false: dokit面板收起
  final Function(bool)? btnClickCallback;
  DoKitBtn(this.btnClickCallback) : super(key: doKitBtnKey);

  static GlobalKey<DoKitBtnState> doKitBtnKey = GlobalKey<DoKitBtnState>();
  late OverlayEntry overlayEntry;

  @override
  State<DoKitBtn> createState() => DoKitBtnState();

  void addToOverlay() {
    overlayEntry = OverlayEntry(builder: (BuildContext context) => this);
    final rootOverlay = doKitOverlayKey.currentState;
    assert(rootOverlay != null);
    rootOverlay?.insert(overlayEntry);
    ApmKitManager.instance.startUp();
  }
}

class DoKitBtnState extends State<DoKitBtn> {
  Offset? _offsetA; //按钮的初始位置
  OverlayEntry? _debugPage;
  late bool _showDebugPage;

  @override
  void initState() {
    super.initState();
    _showDebugPage = false;
  }

  @override
  Widget build(BuildContext context) {
    double cellWH = 50;
    var enterWidget = Container(
      width: cellWH,
      height: cellWH,
      alignment: Alignment.center,
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: _openDebugPage,
        child: Image.asset('assets/images/dokit_flutter_btn.png',
            package: dkPackageName, height: cellWH, width: cellWH),
      ),
    );
    return Positioned(
      left: _offsetA?.dx,
      top: _offsetA?.dy,
      right: _offsetA == null ? 10 : null,
      bottom: _offsetA == null ? 100 : null,
      child: Draggable(
          feedback: enterWidget,
          childWhenDragging: Container(),
          onDragEnd: (DraggableDetails detail) {
            final offset = detail.offset;
            setState(() {
              final size = MediaQuery.of(context).size;
              final width = size.width;
              final height = size.height;
              var x = offset.dx;
              var y = offset.dy;
              if (x < 0) {
                x = 0;
              }
              if (x > width - 60) {
                x = width - 60;
              }
              if (y < 0) {
                y = 0;
              }
              if (y > height - 26) {
                y = height - 26;
              }
              _offsetA = Offset(x, y);
            });
          },
          onDraggableCanceled: (Velocity velocity, Offset offset) {},
          child: enterWidget),
    );
  }

  void _openDebugPage() {
    _debugPage ??=
        OverlayEntry(builder: (BuildContext context) => ResidentPage());
    if (_showDebugPage) {
      _closeDebugPage();
    } else {
      doKitOverlayKey.currentState
          ?.insert(_debugPage!, below: widget.overlayEntry);
      _showDebugPage = true;
    }
    widget.btnClickCallback?.call(_showDebugPage);
  }

  void _closeDebugPage() {
    if (_showDebugPage && _debugPage != null) {
      _debugPage!.remove();
      _showDebugPage = false;
    }
  }
}
