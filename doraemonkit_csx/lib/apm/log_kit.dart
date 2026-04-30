import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../apm.dart';
import '../csx_dokit.dart';
import '../kit.dart';
import '../utils/shared_prefer_util.dart';
import '../utils/time_util.dart';

class LogKit extends ApmKit {
  FlutterExceptionHandler? originOnError;

  final CommonStorage _error = CommonStorage();

  CommonStorage get error => _error;

  @override
  Widget createDisplayPage() {
    return LogPage();
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 120);
  }

  @override
  String getKitName() {
    return ApmKitName.kitLog;
  }

  @override
  String getIcon() {
    return 'assets/images/dk_log_info.png';
  }

  @override
  bool save(IInfo? info) {
    if ((info as LogBean).type == LogBean.typeError) {
      _error.save(info);
    }
    return super.save(info);
  }

  @override
  void start() {
    resetOnErrorInstance();
  }

  // dart vm会通过widget_inspector.dart structuredErrors服务替换掉FlutterError.onError，不清楚具体执行时机是什么时候,会重复执行。这里启动定时器每1秒将其替换回来。
  // 需要保留widget_inspector注入的onError调用，否则会影响android studio的输出
  void resetOnErrorInstance() {
    Timer.periodic(Duration(seconds: 1 /**/), (timer) {
      if (FlutterError.onError != _doKitOnError) {
        originOnError = FlutterError.onError;
        FlutterError.onError = _doKitOnError;
      }
    });
  }

  void _doKitOnError(FlutterErrorDetails details) {
    // 委托给runZone内的onError
    Zone.current.handleUncaughtError(details.exception, details.stack!);
    originOnError?.call(details);
  }

  @override
  void stop() {}
}

class LogManager {
  LogManager._privateConstructor();

  static final LogManager _instance = LogManager._privateConstructor();

  Function? _listener;

  void registerListener(Function listener) {
    _listener = listener;
  }

  void unregisterListener() {
    _listener = null;
  }

  static LogManager get instance {
    return _instance;
  }

  List<IInfo>? getLogs() {
    return ApmKitManager.instance
        .getKit(ApmKitName.kitLog)
        ?.getStorage()
        .getAll();
  }

  List<IInfo>? getErrors() {
    return ApmKitManager.instance
        .getKit<LogKit>(ApmKitName.kitLog)
        ?.error
        .getAll();
  }

  void addLog(int type, String msg) {
    if (ApmKitManager.instance.getKit(ApmKitName.kitLog) != null) {
      var log = LogBean(type, msg);
      var kit = ApmKitManager.instance.getKit(ApmKitName.kitLog);
      kit?.save(log);
      if (type != LogBean.typeError || LogPageState._showError) {
        _listener?.call(log);
      }
    }
  }

  void addException(String exception) {
    addLog(LogBean.typeError, exception);
  }
}

class LogBean implements IInfo {
  static const int typeLog = 1;
  static const int typeDebug = 2;
  static const int typeInfo = 3;
  static const int typeWarn = 4;
  static const int typeError = 5;

  final int type;
  final String msg;
  late int timestamp;
  late bool expand;

  LogBean(this.type, this.msg) {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    expand = false;
  }

  @override
  int getValue() {
    return 0;
  }
}

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LogPageState();
  }
}

class LogPageState extends State<LogPage> {
  final ScrollController _offsetController = ScrollController();
  static bool _showError = false;

  Future<void> _listener(LogBean logBean) async {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    setState(() {
      // 如果正在查看，就不自动滑动到底部
      if (_offsetController.offset < 10) {
        _offsetController.jumpTo(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    LogManager.instance.registerListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    LogManager.instance.unregisterListener();
  }

  @override
  Widget build(BuildContext context) {
    List<IInfo> items = LogPageState._showError
        ? LogManager.instance.getErrors()?.reversed.toList() ?? []
        : LogManager.instance.getLogs()?.reversed.toList() ?? [];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showError = !_showError;
                });
              },
              child: Container(
                height: 44,
                width: 44,
                padding: EdgeInsets.only(left: 16),
                child: Image.asset(
                  _showError
                      ? 'assets/images/dk_channel_check_h.png'
                      : 'assets/images/dk_channel_check_n.png',
                  height: 13,
                  width: 13,
                  package: dkPackageName,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showError = !_showError;
                });
              },
              child: Text(
                '只显示异常',
                style: TextStyle(
                  color: _showError ? Color(0xff337cc4) : Color(0xff333333),
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              padding: EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    ApmKitManager.instance
                        .getKit<LogKit>(ApmKitName.kitLog)
                        ?.getStorage()
                        .clear();
                    ApmKitManager.instance
                        .getKit<LogKit>(ApmKitName.kitLog)
                        ?.error
                        .clear();
                  });
                },
                child: Text(
                  '清除本页数据',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: EdgeInsets.only(left: 10, top: 8, bottom: 8),
              padding: EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _offsetController.jumpTo(0);
                },
                child: Text(
                  '滑动到底部',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: ListView.builder(
              controller: _offsetController,
              itemCount: items.length,
              reverse: true,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
              itemBuilder: (context, index) {
                return LogItemWidget(
                  item: items[index] as LogBean,
                  index: index,
                  isLast: index == items.length - 1,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LogItemWidget extends StatefulWidget {
  final LogBean item;
  final int index;
  final bool isLast;

  const LogItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  @override
  State<StatefulWidget> createState() {
    return _LogItemWidgetState();
  }
}

class _LogItemWidgetState extends State<LogItemWidget> {
  static final String keyShowLogExpandTips = 'key_show_log_expand_tips';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.item.msg));
        CsxDokit.i.toast?.call('已拷贝至剪贴板');
      },
      onTap: () async {
        var isContain =
            await SPService.instance.containsKey(keyShowLogExpandTips);
        setState(() {
          widget.item.expand = !widget.item.expand;
          if (!isContain) {
            SPService.instance.set(keyShowLogExpandTips, true);
            CsxDokit.i.toast?.call('日志超过7行时，点击可展开日志详情');
          }
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
          color: widget.item.expand ? Colors.black : Colors.white,
          border: Border(
            bottom: BorderSide(width: 0.5, color: Color(0xffeeeeee)),
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: RichText(
            maxLines: widget.item.expand ? 9999 : 7,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '[${TimeUtils.toTimeString(widget.item.timestamp)}] ',
                  style: TextStyle(
                    color: widget.item.type == LogBean.typeError
                        ? Colors.red
                        : (widget.item.expand
                            ? Colors.white
                            : Color(0xff333333)),
                    height: 1.4,
                    fontSize: 10,
                  ),
                ),
                TextSpan(
                  text: widget.item.msg,
                  style: TextStyle(
                    color: widget.item.type == LogBean.typeError
                        ? Colors.red
                        : (widget.item.expand
                            ? Colors.white
                            : Color(0xff333333)),
                    height: 1.4,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
