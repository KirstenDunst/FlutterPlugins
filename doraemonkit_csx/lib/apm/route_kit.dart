import 'package:flutter/material.dart';
import '../apm.dart';
import '../csx_dokit.dart';
import '../kit.dart';

class RouteKit extends ApmKit {
  @override
  Widget createDisplayPage() {
    return RouteInfoPage();
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 120);
  }

  @override
  String getKitName() {
    return ApmKitName.kitRoute;
  }

  @override
  String getIcon() {
    return 'assets/images/dk_view_route.png';
  }

  @override
  void start() {}

  @override
  void stop() {}
}

class RouteInfoPage extends StatefulWidget {
  const RouteInfoPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return RouteInfoPageState();
  }
}

class RouteInfoPageState extends State<RouteInfoPage> {
  RouteInfo? _route;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var route = findRoute();
      if (route?.current != null) {
        setState(() {
          _route = route;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '当前页面路由树',
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                      'Navigator存在嵌套情况，打印当前页面在每层Navigator内的路由信息',
                      style: TextStyle(color: Color(0xff999999), fontSize: 12),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildRouteInfoWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildRouteInfoWidget() {
    List<Widget> widgets = <Widget>[];
    if (_route == null) {
      return widgets;
    }
    do {
      if (_route?.current != null) {
        widgets.add(
          Container(
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xfff5f6f7),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '路由名称: ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff333333),
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${_route!.current?.settings.name}',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff666666),
                    ),
                  ),
                  TextSpan(
                    text: '\n路由参数: ',
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 10,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${_route!.current?.settings.arguments}',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff666666),
                    ),
                  ),
                  TextSpan(
                    text: '\n所在Navigator: ',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _route!.parentNavigator.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff666666),
                    ),
                  ),
                  TextSpan(
                    text: '\n所有信息: ',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _route!.current.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xff666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      _route = _route?.parent;
      if (_route != null && _route?.parent != null) {
        widgets.add(
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/dk_route_arrow.png',
              height: 13,
              width: 12,
            ),
          ),
        );
      }
      // 过滤掉dokit自带的navigator
    } while (_route != null);
    return widgets;
  }

  RouteInfo? findRoute() {
    Element? topElement;
    var context = CsxDokit.i.overlayContext;
    if (context == null) return null;
    final ModalRoute<dynamic>? rootRoute = ModalRoute.of(context);
    void listTopView(Element element) {
      if (element.widget is! PositionedDirectional) {
        if (element is RenderObjectElement &&
            element.renderObject is RenderBox) {
          var route = ModalRoute.of(element);
          if (route != null && route != rootRoute) {
            topElement = element;
          }
        }
        element.visitChildren(listTopView);
      }
    }

    context.visitChildElements(listTopView);
    if (topElement != null) {
      var routeInfo = RouteInfo();
      routeInfo.current = ModalRoute.of(topElement!);
      buildNavigatorTree(topElement!, routeInfo);
      return routeInfo;
    }
    return null;
  }

  /// 反向遍历生成路由树
  void buildNavigatorTree(Element element, RouteInfo routeInfo) {
    var navigatorState = element.findAncestorStateOfType<NavigatorState>();

    if (navigatorState?.context != null) {
      var parent = RouteInfo(
        current: ModalRoute.of(navigatorState!.context),
        parentNavigator: navigatorState.widget,
      );
      routeInfo.parent = parent;
      return buildNavigatorTree(
        navigatorState.context as StatefulElement,
        parent,
      );
    }
  }
}

class RouteInfo extends IInfo {
  ModalRoute? current;
  Widget? parentNavigator;
  RouteInfo? parent;
  RouteInfo({this.current, this.parentNavigator, this.parent});

  @override
  int getValue() {
    return 0;
  }
}
