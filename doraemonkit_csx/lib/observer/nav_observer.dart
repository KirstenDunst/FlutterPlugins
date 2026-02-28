import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:flutter/material.dart';

class CsxKitNavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    var previousName = '';
    if (null == previousRoute) {
      previousName = 'null';
    } else {
      previousName = previousRoute.settings.name ?? '';
    }
    CsxKitShare.instance.printLog(
      'NavObserverDidPush-Current:${route.settings.name ?? ''}   Previous:$previousName',
    );
    if (route.settings != routeSettings) {
      CsxKitShare.instance.hiddenMenu();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    var previousName = '';
    if (null == previousRoute) {
      previousName = 'null';
    } else {
      previousName = previousRoute.settings.name ?? '';
    }
    CsxKitShare.instance.printLog(
      'NavObserverDidPop--Current:${route.settings.name ?? ''}   Previous:$previousName',
    );
    if (previousRoute?.settings == routeSettings) {
      CsxKitShare.instance.showMenu();
    }
  }
}
