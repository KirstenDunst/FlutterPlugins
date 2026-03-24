import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';

import '../csx_kit.dart';

class FloatingIconOverlay extends StatefulWidget {
  const FloatingIconOverlay({super.key});

  @override
  State<FloatingIconOverlay> createState() => _FloatingIconOverlayState();
}

class _FloatingIconOverlayState extends State<FloatingIconOverlay> {
  late ValueNotifier<Offset> _offsetNotifier;
  late Offset _nowOffset;

  @override
  void initState() {
    super.initState();
    _nowOffset = Offset(0, 100);
    _offsetNotifier = ValueNotifier(_nowOffset);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: CsxKitShare.instance.showMenuNotifier,
      builder: (cont, showMenu, child) => ValueListenableBuilder<Offset>(
        valueListenable: _offsetNotifier,
        builder: (_, offset, child) => Offstage(
          offstage: !showMenu,
          child: Align(
            alignment: Alignment(
              (offset.dx -
                      (CsxKitShare.instance.screenSize.width -
                          offset.dx -
                          40)) /
                  (CsxKitShare.instance.screenSize.width - 40),
              (offset.dy -
                      (CsxKitShare.instance.screenSize.height -
                          offset.dy -
                          40)) /
                  (CsxKitShare.instance.screenSize.height - 40),
            ),
            child: GestureDetector(
              onPanUpdate: (details) =>
                  _offsetNotifier.value = _offsetNotifier.value + details.delta,
              onPanEnd: (details) {
                var nowOffset = _offsetNotifier.value;
                var dy = nowOffset.dy.clamp(
                  CsxKitShare.instance.areaPadding.top,
                  CsxKitShare.instance.screenSize.height -
                      CsxKitShare.instance.areaPadding.bottom -
                      40,
                );
                if (nowOffset.dx > CsxKitShare.instance.screenSize.width / 2) {
                  nowOffset = Offset(
                    CsxKitShare.instance.screenSize.width - 40,
                    dy,
                  );
                } else {
                  nowOffset = Offset(0, dy);
                }
                _offsetNotifier.value = nowOffset;
              },
              onTap: () => CsxKitShare.instance.showDetailPage(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Image.asset(
                  'assets/images/dokit_flutter_btn.png',
                  width: 40,
                  height: 40,
                  package: dkPackageName,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
