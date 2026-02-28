import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:flutter/material.dart';

import '../apm.dart';
import '../dokit.dart';
import 'resident_page.dart';

// DoKitBtn 点击事件回调
// 参数说明：
// true : dokit面板展开
// false: dokit面板收起
typedef DoKitBtnClickedCallback = void Function(bool);

// 入口btn
// ignore: must_be_immutable
class DoKitBtn extends StatefulWidget {
  DoKitBtn() : super(key: doKitBtnKey);

  static GlobalKey<DoKitBtnState> doKitBtnKey = GlobalKey<DoKitBtnState>();
  OverlayEntry? overlayEntry;
  DoKitBtnClickedCallback? btnClickCallback;

  @override
  DoKitBtnState createState() => DoKitBtnState(overlayEntry!);

  void addToOverlay() {
    assert(overlayEntry == null);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return this;
      },
    );
    final rootOverlay = CsxKitShare.instance.overlayState;
    rootOverlay.insert(overlayEntry!);
    ApmKitManager.instance.startUp();
  }
}

class DoKitBtnState extends State<DoKitBtn> {
  DoKitBtnState(this.owner);

  Offset? offsetA; //按钮的初始位置
  final OverlayEntry owner;
  OverlayEntry? debugPage;
  bool showDebugPage = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offsetA?.dx,
      top: offsetA?.dy,
      right: offsetA == null ? 20 : null,
      bottom: offsetA == null ? 120 : null,
      child: Draggable(
        feedback: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
            ),
            onPressed: openDebugPage,
            child: Image.asset(
              'images/dokit_flutter_btn.png',
              package: dkPackageName,
              height: 70,
              width: 70,
            ),
          ),
        ),
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
            if (x > width - 80) {
              x = width - 80;
            }
            if (y < 0) {
              y = 0;
            }
            if (y > height - 26) {
              y = height - 26;
            }
            offsetA = Offset(x, y);
          });
        },
        onDraggableCanceled: (Velocity velocity, Offset offset) {},
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
            ),
            onPressed: openDebugPage,
            child: Image.asset(
              'images/dokit_flutter_btn.png',
              package: dkPackageName,
              height: 70,
              width: 70,
            ),
          ),
        ),
      ),
    );
  }

  void openDebugPage() {
    debugPage ??= OverlayEntry(
      builder: (BuildContext context) {
        return ResidentPage();
      },
    );
    if (showDebugPage) {
      closeDebugPage();
    } else {
      CsxKitShare.instance.overlayState.insert(debugPage!, below: owner);
      showDebugPage = true;
    }

    widget.btnClickCallback!(showDebugPage);
  }

  void closeDebugPage() {
    if (showDebugPage && debugPage != null) {
      debugPage!.remove();
      showDebugPage = false;
    }
  }
}
