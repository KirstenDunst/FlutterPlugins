import 'package:flutter/material.dart';

class CsxKitNavObserver extends NavigatorObserver {
  final List<NavigatorObserver> _observers = [LaunchObserver()];

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    for (var element in _observers) {
      element.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    for (var element in _observers) {
      element.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    for (var element in _observers) {
      element.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    for (var element in _observers) {
      element.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    for (var element in _observers) {
      element.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    for (var element in _observers) {
      element.didStopUserGesture();
    }
  }
}

ValueNotifier<LaunchInfo> notifier = ValueNotifier(LaunchInfo(0, '', ''));

bool enabled = false;

class LaunchObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (enabled) {
      var before = DateTime.now().millisecondsSinceEpoch;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        var now = DateTime.now().millisecondsSinceEpoch;
        notifier.value = LaunchInfo(
            now - before, previousRoute?.settings.name, route.settings.name);
      });
    }
  }
}

class LaunchInfo {
  final int costTime;
  final String? previousPage;
  final String? newPage;

  LaunchInfo(this.costTime, this.previousPage, this.newPage);
}
