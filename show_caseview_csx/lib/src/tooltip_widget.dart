import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:show_caseview_csx/common/assets.dart';
import 'package:show_caseview_csx/common/const.dart';

import 'get_position.dart';
import 'measure_size.dart';

const _kDefaultPaddingFromParent = 14.0;

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final TextAlign? titleAlignment;
  final String? description;
  final TextAlign? descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipBackgroundColor;
  final Color? textColor;
  final bool showAdditionalBoot;
  //额外引导是否是小剪头，默认true：箭头指引，false：曲线+箭头指引
  final bool isArrow;
  final double? contentHeight;
  final double? contentWidth;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? tooltipPadding;
  final Duration movingAnimationDuration;
  final bool disableMovingAnimation;
  final bool disableScaleAnimation;
  final BorderRadius? tooltipBorderRadius;
  final Duration scaleAnimationDuration;
  final Curve scaleAnimationCurve;
  final Alignment? scaleAnimationAlignment;
  final bool isTooltipDismissed;
  // 是否强制指定tooltip标签在target的上面，默认null:自动设定（都能放下就放下面），true:强制在target的上面， false:强制在target的下面
  final bool? forceTooltipPositionAbove;
  //tooltip标签整体默认自适应无主动偏移Offset.zero，这里扩展加上强制的可设置偏移量的参数，可以自适应个人公司UI
  final Offset tooltipOffset;

  const ToolTipWidget({
    Key? key,
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.title,
    required this.titleAlignment,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.tooltipBackgroundColor,
    required this.textColor,
    required this.showAdditionalBoot,
    this.isArrow = true,
    required this.contentHeight,
    required this.contentWidth,
    required this.onTooltipTap,
    required this.movingAnimationDuration,
    required this.descriptionAlignment,
    this.tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableMovingAnimation,
    required this.disableScaleAnimation,
    required this.tooltipBorderRadius,
    required this.scaleAnimationDuration,
    required this.scaleAnimationCurve,
    this.scaleAnimationAlignment,
    this.isTooltipDismissed = false,
    this.forceTooltipPositionAbove,
    this.tooltipOffset = Offset.zero,
  }) : super(key: key);

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with TickerProviderStateMixin {
  Offset? position;

  bool isArrowUp = false;

  late final AnimationController _movingAnimationController;
  late final Animation<double> _movingAnimation;
  late final AnimationController _scaleAnimationController;
  late final Animation<double> _scaleAnimation;

  double tooltipWidth = 0;
  double tooltipScreenEdgePadding = 20;
  double tooltipTextPadding = 15;

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    height = widget.contentHeight ?? height;
    final bottomPosition =
        position.dy + ((widget.position?.getHeight() ?? 0) / 2);
    final topPosition = position.dy - ((widget.position?.getHeight() ?? 0) / 2);
    return ((widget.screenSize?.height ?? MediaQuery.of(context).size.height) -
                bottomPosition) <=
            height &&
        topPosition >= height;
  }

  String findPositionForContent(Offset position) {
    var isCloseTop = false;
    if (widget.forceTooltipPositionAbove == null) {
      isCloseTop = isCloseToTopOrBottom(position);
    } else {
      isCloseTop = widget.forceTooltipPositionAbove!;
    }
    if (isCloseTop) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  void _getTooltipWidth() {
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .subtitle2!
            .merge(TextStyle(color: widget.textColor));
    final titleLength = widget.title == null
        ? 0
        : _textSize(widget.title!, titleStyle).width +
            widget.tooltipPadding!.right +
            widget.tooltipPadding!.left;
    final descriptionLength = widget.description == null
        ? 0
        : (_textSize(widget.description!, descriptionStyle).width +
            widget.tooltipPadding!.right +
            widget.tooltipPadding!.left);
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize!.width - tooltipScreenEdgePadding) {
      tooltipWidth = widget.screenSize!.width - tooltipScreenEdgePadding;
    } else {
      tooltipWidth = maxTextWidth + tooltipTextPadding;
    }
  }

  double? _getLeft() {
    if (widget.position != null) {
      final width =
          widget.container != null ? _customContainerWidth.value : tooltipWidth;
      double leftPositionValue = widget.position!.getCenter() - (width * 0.5);
      if ((leftPositionValue + width) > MediaQuery.of(context).size.width) {
        return null;
      } else if ((leftPositionValue) < _kDefaultPaddingFromParent) {
        return _kDefaultPaddingFromParent;
      } else {
        return leftPositionValue;
      }
    }
    return null;
  }

  double? _getRight() {
    if (widget.position != null) {
      final width =
          widget.container != null ? _customContainerWidth.value : tooltipWidth;

      if (_getLeft() == null ||
          ((_getLeft() ?? 0) + width) > MediaQuery.of(context).size.width) {
        final rightPosition = widget.position!.getCenter() + (width * 0.5);

        return (rightPosition + width) > MediaQuery.of(context).size.width
            ? _kDefaultPaddingFromParent
            : null;
      } else {
        return null;
      }
    }
    return null;
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }

  double _getAlignmentX() {
    var left = _getLeft() == null
        ? 0
        : (widget.position!.getCenter() - (_getLeft() ?? 0));
    var right = _getLeft() == null
        ? (MediaQuery.of(context).size.width - widget.position!.getCenter()) -
            (_getRight() ?? 0)
        : 0;
    final containerWidth =
        widget.container != null ? _customContainerWidth.value : tooltipWidth;

    if (left != 0) {
      return (-1 + (2 * (left / containerWidth)));
    } else {
      return (1 - (2 * (right / containerWidth)));
    }
  }

  double _getAlignmentY() {
    var dy = isArrowUp
        ? -1.0
        : (MediaQuery.of(context).size.height / 2) < widget.position!.getTop()
            ? -1.0
            : 1.0;
    return dy;
  }

  final GlobalKey _customContainerKey = GlobalKey();
  final ValueNotifier<double> _customContainerWidth = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.container != null &&
          _customContainerKey.currentContext != null &&
          _customContainerKey.currentContext?.size != null) {
        setState(() {
          _customContainerWidth.value =
              _customContainerKey.currentContext!.size!.width;
        });
      }
    });
    _movingAnimationController = AnimationController(
      duration: widget.movingAnimationDuration,
      vsync: this,
    );
    _movingAnimation = CurvedAnimation(
      parent: _movingAnimationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimationController = AnimationController(
      duration: widget.scaleAnimationDuration,
      vsync: this,
      lowerBound: widget.disableScaleAnimation ? 1 : 0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: widget.scaleAnimationCurve,
    );
    if (widget.disableScaleAnimation) {
      movingAnimationListener();
    } else {
      _scaleAnimationController
        ..addStatusListener((scaleAnimationStatus) {
          if (scaleAnimationStatus == AnimationStatus.completed) {
            movingAnimationListener();
          }
        })
        ..forward();
    }
    if (!widget.disableMovingAnimation) {
      _movingAnimationController.forward();
    }
  }

  void movingAnimationListener() {
    _movingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _movingAnimationController.reverse();
      }
      if (_movingAnimationController.isDismissed) {
        if (!widget.disableMovingAnimation) {
          _movingAnimationController.forward();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    _getTooltipWidth();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var additionBootSize =
        widget.isArrow ? const Size(18.0, 9.0) : const Size(40.0, 50.0);

    var paddingTop = isArrowUp ? 22.0 : 0.0;
    var paddingBottom = isArrowUp ? 0.0 : 27.0;

    if (!widget.showAdditionalBoot) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      _scaleAnimationController.reverse();
    }

    if (widget.container == null) {
      var left = _getLeft();
      var right = _getRight();
      return Positioned(
        top: contentY,
        left: left == null ? null : (left + widget.tooltipOffset.dx),
        right: right == null ? null : (right - widget.tooltipOffset.dx),
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.scaleAnimationAlignment ??
              Alignment(
                _getAlignmentX(),
                _getAlignmentY(),
              ),
          child: FractionalTranslation(
            translation: Offset(0.0, contentFractionalOffset as double),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, contentFractionalOffset / 10),
                end: const Offset(0.0, 0.100),
              ).animate(_movingAnimation),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: widget.showAdditionalBoot
                      ? EdgeInsets.only(
                          top: max(
                              0,
                              paddingTop -
                                  (isArrowUp ? additionBootSize.height : 0)),
                          bottom: max(
                              0,
                              paddingBottom -
                                  (isArrowUp ? 0 : additionBootSize.height)),
                        )
                      : null,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: isArrowUp
                        ? Alignment.topLeft
                        : left == null
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                    children: [
                      if (widget.showAdditionalBoot)
                        widget.isArrow
                            ? Positioned(
                                left: left == null
                                    ? null
                                    : (widget.position!.getCenter() -
                                            (additionBootSize.width / 2) -
                                            left) -
                                        widget.tooltipOffset.dx,
                                right: left == null
                                    ? (MediaQuery.of(context).size.width -
                                            widget.position!.getCenter()) -
                                        (right ?? 0) -
                                        (additionBootSize.width / 2) +
                                        widget.tooltipOffset.dx
                                    : null,
                                child: CustomPaint(
                                  painter: _Arrow(
                                    strokeColor: widget.tooltipBackgroundColor!,
                                    strokeWidth: 10,
                                    paintingStyle: PaintingStyle.fill,
                                    isUpArrow: isArrowUp,
                                  ),
                                  child: SizedBox(
                                    height: additionBootSize.height,
                                    width: additionBootSize.width,
                                  ),
                                ),
                              )
                            : Positioned(
                                left: left == null
                                    ? null
                                    : (isArrowUp
                                            ? widget.position!.getCenter()
                                            : (widget.position!.getCenter() -
                                                additionBootSize.width)) -
                                        left -
                                        widget.tooltipOffset.dx,
                                right: left == null
                                    ? (isArrowUp
                                            ? (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                widget.position!.getCenter() -
                                                additionBootSize.width)
                                            : (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                widget.position!.getCenter())) -
                                        (right ?? 0) +
                                        widget.tooltipOffset.dx
                                    : null,
                                child: Transform.rotate(
                                  angle: isArrowUp ? pi : 0,
                                  child: SvgPicture.asset(
                                    Images.icCurve,
                                    color: Colors.white,
                                    package: packageName,
                                    fit: BoxFit.fill,
                                    height: additionBootSize.height,
                                    width: additionBootSize.width,
                                  ),
                                ),
                              ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: isArrowUp ? additionBootSize.height - 1 : 0,
                          bottom: isArrowUp ? 0 : additionBootSize.height - 1,
                        ),
                        child: ClipRRect(
                          borderRadius: widget.tooltipBorderRadius ??
                              BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: widget.onTooltipTap,
                            child: Container(
                              width: tooltipWidth,
                              padding: widget.tooltipPadding,
                              color: widget.tooltipBackgroundColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: widget.title != null
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    children: <Widget>[
                                      widget.title != null
                                          ? Text(
                                              widget.title!,
                                              textAlign: widget.titleAlignment,
                                              style: widget.titleTextStyle ??
                                                  Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .merge(
                                                        TextStyle(
                                                          color:
                                                              widget.textColor,
                                                        ),
                                                      ),
                                            )
                                          : const SizedBox(),
                                      Text(
                                        widget.description!,
                                        textAlign: widget.descriptionAlignment,
                                        style: widget.descTextStyle ??
                                            Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .merge(
                                                  TextStyle(
                                                    color: widget.textColor,
                                                  ),
                                                ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset as double),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: !widget.showAdditionalBoot && !isArrowUp
                      ? const Offset(0.0, 0.0)
                      : const Offset(0.0, 0.100),
                ).animate(_movingAnimation),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(top: paddingTop),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(
                                () {
                                  var tempPos = position;
                                  tempPos = Offset(position!.dx,
                                      position!.dy + size!.height);
                                  position = tempPos;
                                },
                              );
                            },
                            child: widget.container),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = (TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return textPainter;
  }
}

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final bool isUpArrow;

  _Arrow(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke,
      this.isUpArrow = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    if (isUpArrow) {
      return Path()
        ..moveTo(0, y)
        ..lineTo(x / 2, 0)
        ..lineTo(x, y)
        ..lineTo(0, y);
    } else {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(x, 0)
        ..lineTo(x / 2, y)
        ..lineTo(0, 0);
    }
  }

  @override
  bool shouldRepaint(_Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
