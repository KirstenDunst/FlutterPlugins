import 'dart:math';

import 'package:flutter/cupertino.dart';

/// 多边形工具
class PolygonUtil {
  /// 根据中心点，半径，弧度获取点
  static Point radianPoint(Point center, double r, double radian) {
    return Point(center.x + r * cos(radian), center.y + r * sin(radian));
  }

  /// 返回正多边形的顶点
  static List<Point> convertToPoints(Point center, double r, int num,
      {double startRadian = 0.0}) {
    var list = <Point>[];
    var perRadian = 2.0 * pi / num;
    for (var i = 0; i < num; i++) {
      var radian = i * perRadian + startRadian;
      var p = radianPoint(center, r, radian);
      list.add(p);
    }
    return list;
  }

  /// 获取进似圆角多边形path
  /// 顶点沿相邻边移动[distance]后得到两个点，从这两个点绘制半径为[radius]的圆弧
  static Path drawRoundPolygon(
      List<Point<double>> listPoints, Canvas canvas, Paint paint,
      {double distance = 4.0, double radius = 0.0}) {
    if (radius < 0.01) {
      radius = 6 * distance;
    }
    var path = Path();
    listPoints.add(listPoints[0]);
    listPoints.add(listPoints[1]);
    var p0 = LineUtil.intersectionPoint(listPoints[1], listPoints[0], distance);
    path.moveTo(p0.x.toDouble(), p0.y);
    for (var i = 0; i < listPoints.length - 2; i++) {
      var p1 = listPoints[i];
      var p2 = listPoints[i + 1];
      var p3 = listPoints[i + 2];
      var interP1 = LineUtil.intersectionPoint(p1, p2, distance);
      var interP2 = LineUtil.intersectionPoint(p3, p2, distance);
      path.lineTo(interP1.x, interP1.y);
      path.arcToPoint(
        Offset(interP2.x, interP2.y),
        radius: Radius.circular(radius),
      );
    }
    return path;
  }

  /// 获取圆角多边形path
  /// 以[radius]对每个角做圆角
  static Path drawRoundPolygon2(
      List<Point> listPoints, Canvas canvas, Paint paint,
      {required double radius}) {
    var path = Path();
    listPoints.add(listPoints[0]);
    listPoints.add(listPoints[1]);

    Point<double>? p0;
    for (var i = 0; i < listPoints.length - 2; i++) {
      var p1 = listPoints[i];
      var p2 = listPoints[i + 1];
      var p3 = listPoints[i + 2];
      var distance = distanceToTangencyPoint(p1, p2, p3, radius);
      var interP1 = LineUtil.intersectionPoint(p1, p2, distance);
      var interP2 = LineUtil.intersectionPoint(p3, p2, distance);
      if (p0 == null) {
        p0 = interP1;
        path.moveTo(p0.x, p0.y);
      } else {
        path.lineTo(interP1.x, interP1.y);
      }
      path.arcToPoint(
        Offset(interP2.x, interP2.y),
        radius: Radius.circular(radius),
      );
    }
    if (p0 != null) {
      path.lineTo(p0.x, p0.y);
    }
    return path;
  }

  /// [start]和[middle]连线，[middle]和[end]连线，形成一个角，
  /// 以[radius]做圆角后，返回切点距[middle]的距离
  static double distanceToTangencyPoint(
      Point start, Point middle, Point end, double radius) {
    var distance = LineUtil.distance(start, middle);
    var angle = LineUtil.angle(start, middle, end);
    var distanceToTangencyPoint = radius / sin(angle / 2);
    if (distanceToTangencyPoint > distance) {
      distanceToTangencyPoint = distance;
    }
    return distanceToTangencyPoint;
  }
}

/// 直线工具
class LineUtil {
  static double distance(Point start, Point end) {
    return sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));
  }

  static double angle(Point start, Point middle, Point end) {
    var distance1 = distance(start, middle);
    var distance2 = distance(middle, end);
    var distance3 = distance(start, end);
    var angle = acos((pow(distance1, 2) + pow(distance2, 2) - pow(distance3, 2)) /
        (2 * distance1 * distance2));
    return angle;
  }

  ///intersection point
  ///[start]沿[start],[end] 连线移动[distance]后的点的位置
  static Point<double> intersectionPoint(
      Point start, Point end, double distance) {
    var angle = atan2(end.y - start.y, end.x - start.x);
    var x = start.x + distance * cos(angle);
    var y = start.y + distance * sin(angle);
    return Point(x, y);
  }
}
