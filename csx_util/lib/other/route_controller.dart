import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Route栈记录器
/// 封装了方法去便捷的判断某个route是否在栈中
class RouteHistory with ChangeNotifier {
  final List<Route> history = [];

  void add(Route<dynamic> route) {
    history.add(route);
    removeUnActive(); //删除非active的

    notifyListeners();
  }

  void remove(Route<dynamic> route) {
    history.remove(route);
    removeUnActive(); //删除非active的

    notifyListeners();
  }

  ///过滤符合条件的Route
  Route? filter(bool Function(Route?) isMatch) {
    try {
      return history.firstWhere((element) => isMatch(element));
    } on StateError {
      return null;
    }
  }

  ///是否存在匹配[routeSettingName]且[Route.isActive]的route
  bool isActive(
    String routeSettingName, {
    bool needParam = false,
    Object? arguments,
  }) {
    return history.where((route) {
      var result = route.settings.name == routeSettingName && route.isActive;
      if (needParam) {
        result = result && route.settings.arguments == arguments;
      }
      return result;
    }).isNotEmpty;
  }

  ///移除Route，直到[predicate]条件满足 可以指定pop时传递的result
  void popUntil(
    RoutePredicate predicate, {
    dynamic Function(Route)? popResult,
  }) {
    while (history.isNotEmpty && !predicate(history.last)) {
      history.last.navigator?.pop(popResult?.call(history.last));
    }
  }

  ///移除符合[predicate]条件的Route 可以指定pop时传递的result
  void removeRoute<T>(RoutePredicate predicate, [T? result]) {
    removeUnActive(); //删除非active的

    // 需要新创建一个列表，否则会报错
    for (var route in List.of(history.where((e) => predicate(e)))) {
      route.didPop(result);
      route.navigator?.removeRoute(route);
    }
  }

  ///注意拿到的route可能是disposed
  bool hasRoute(RoutePredicate predicate) {
    return history.any((e) => predicate(e));
  }

  ///是否存在符合[predicate]条件且[Route.isActive]为真的Route
  bool hasActiveRoute(RoutePredicate predicate) {
    return history.any((e) => predicate(e) && e.isActive);
  }

  ///不是所有的Route状态变化都通知给了NavigatorObserver！
  ///当 Navigator.dispose时,它会直接把内部Route.dispose，
  ///此时如果history还持有该Route还会造成泄露，
  ///所以还需要在observer回调中增加一个历史栈检查，移除已经disposed的route
  void removeUnActive() {
    for (var element in List.of(
      history.where((element) => !element.isActive),
    )) {
      history.remove(element);
    }
  }
}

///Route观察者，持有[RouteHistory],每次收到Route变化时调用[RouteHistory]的对应方法
class RouteRecorder extends NavigatorObserver {
  final RouteHistory history;

  RouteRecorder(this.history);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    history.add(route);
  }

  @override
  void didStopUserGesture() {
    // 停止拖拽 不需要调用[RouteHistory]方法
  }

  @override
  void didStartUserGesture(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    // 开始拖拽，如果达到距离则会出发didPop 不需要调用[RouteHistory]方法
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      history.remove(oldRoute);
    }
    if (newRoute != null) {
      history.add(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    history.remove(route);
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (route != null) {
      history.remove(route);
    }
  }
}
