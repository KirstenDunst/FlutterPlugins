import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const diameter = 40.0;
const String _dokitViewCheckGroup = 'dokit_view_check-group';

class ElementUtil {
  static RenderObjectElement? resolveTree(
      Offset buttonOffset, BuildContext context) {
    Element? currentPage;
    final List<RenderObjectElement> inBounds = <RenderObjectElement>[];
    final Rect focus =
        Rect.fromLTWH(buttonOffset.dx, buttonOffset.dy, diameter, diameter);
    // 记录根路由，用以过滤overlay
    final ModalRoute<dynamic>? rootRoute = ModalRoute.of<dynamic>(context);

    void filter(Element element) {
      // 兼容IOS，IOS的MaterialApp会在Navigator后再插入一个PositionedDirectional控件，用以处理右滑关闭手势，遍历的时候跳过该控件
      if (element.widget is! PositionedDirectional) {
        if (element is RenderObjectElement &&
            element.renderObject is RenderBox) {
          final ModalRoute<dynamic>? route = ModalRoute.of<dynamic>(element);
          // overlay不包含route信息，通过ModalRoute.of会获取到当前所在materialapp在其父节点内的route,此处对overlay做过滤。只能过滤掉直接添加在根MaterialApp的overlay,
          // 并且该overlay的子widget不能包含materialApp或navigator
          if (route != null && route != rootRoute) {
            currentPage = element;
            final RenderBox renderBox = element.renderObject as RenderBox;
            if (renderBox.hasSize && renderBox.attached) {
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              if (isOverlap(
                  focus,
                  Rect.fromLTWH(offset.dx, offset.dy, element.size!.width,
                      element.size!.height))) {
                inBounds.add(element);
              }
            }
          }
        }
        element.visitChildren(filter);
      }
    }

    context.visitChildElements(filter);
    RenderObjectElement? topElement;
    final ModalRoute<dynamic>? route =
        currentPage != null ? ModalRoute.of<dynamic>(currentPage!) : null;
    for (final RenderObjectElement element in inBounds) {
      if ((route == null || ModalRoute.of(element) == route) &&
          checkSelected(topElement, element, buttonOffset)) {
        topElement = element;
      }
    }
    return topElement;
  }

  static bool checkSelected(RenderObjectElement? last,
      RenderObjectElement current, Offset buttonOffset) {
    if (last == null) {
      return true;
    } else {
      return getOverlayPercent(current, buttonOffset) >
              getOverlayPercent(last, buttonOffset) &&
          current.depth >= last.depth;
    }
  }

  static double getOverlayPercent(
      RenderObjectElement element, Offset buttonOffset) {
    if (element.size == null) {
      return 0;
    }
    final double size = element.size!.width * element.size!.height;
    final Offset offset =
        (element.renderObject as RenderBox).localToGlobal(Offset.zero);
    final Rect rect = Rect.fromLTWH(
        offset.dx, offset.dy, element.size!.width, element.size!.height);
    final double xc1 = max(rect.left, buttonOffset.dx);
    final double yc1 = max(rect.top, buttonOffset.dy);
    final double xc2 = min(rect.right, buttonOffset.dx + diameter);
    final double yc2 = min(rect.bottom, buttonOffset.dy + diameter);
    return ((xc2 - xc1) * (yc2 - yc1)) / size;
  }

  static bool isOverlap(Rect rc1, Rect rc2) {
    return rc1.left + rc1.width > rc2.left &&
        rc2.left + rc2.width > rc1.left &&
        rc1.top + rc1.height > rc2.top &&
        rc2.top + rc2.height > rc1.top;
  }

  static String toInfoString(RenderObjectElement element) {
    String? fileLocation;
    int? line;
    int? column;
    if (kDebugMode) {
      WidgetInspectorService.instance.selection.current = element.renderObject;
      final id = WidgetInspectorService.instance
          // ignore: invalid_use_of_protected_member
          .toId(element.renderObject.toDiagnosticsNode(), _dokitViewCheckGroup);
      if (id == null) {
        return '';
      }
      final String nodeDesc = WidgetInspectorService.instance
          .getSelectedSummaryWidget(id, _dokitViewCheckGroup);

      final Map<String, dynamic> map =
          json.decode(nodeDesc) as Map<String, dynamic>;
      final Map<String, dynamic> location =
          map['creationLocation'] as Map<String, dynamic>;
      fileLocation = location['file'] as String;
      line = location['line'] as int;
      column = location['column'] as int;
    }

    final Offset offset =
        (element.renderObject as RenderBox).localToGlobal(Offset.zero);
    String info = '控件名称: ${element.widget.toString()}\n'
        '控件位置: 左${offset.dx} 上${offset.dy} 宽${element.size!.width} 高${element.size!.height}';
    if (fileLocation != null) {
      info += '\n源码位置: $fileLocation' '【行 ${line!} 列 ${column!}】';
    }
    return info;
  }
}
