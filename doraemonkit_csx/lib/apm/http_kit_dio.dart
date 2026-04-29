import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../apm.dart';
import '../csx_dokit.dart';
import '../kit.dart';
import '../utils/time_util.dart';

class HttpInfo1 implements IInfo {
  HttpInfo1(this.uri, this.method, this.requestId)
      : startTimestamp = DateTime.now().millisecondsSinceEpoch;

  final Uri? uri;
  final String method;
  final String requestId;
  final int startTimestamp;

  String? error;
  HttpRequest request = HttpRequest();
  HttpResponse? response;

  bool expand = false;

  @override
  String getValue() {
    var subMsg = '';
    if (error != null) {
      subMsg = 'Error:$error';
    } else {
      subMsg =
          'Duration:${response == null ? '' : '${response!.endTimestamp - startTimestamp}'}\nRequest:${request.toString()}\n\nResponse:${response.toString()}';
    }
    return 'Uri:$uri\nMethod:$method\n$subMsg';
  }
}

class HttpRequest {
  final Map<String, dynamic>? header;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? queryParameters;

  HttpRequest({this.header, this.body, this.queryParameters});

  @override
  String toString() {
    return 'HEADER: ${jsonEncode(header)}\nBODY: ${jsonEncode(body)}\nQUERY:${jsonEncode(queryParameters)}';
  }
}

class HttpResponse {
  final int? statusCode;
  final Map<String, dynamic>? header;
  final int endTimestamp;
  final dynamic data;

  HttpResponse({this.statusCode, this.data, this.header})
      : endTimestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  String toString() {
    return 'statusCode: $statusCode\nDATA: $data';
  }
}

class HttpKit extends ApmKit {
  @override
  Widget createDisplayPage() {
    return HttpPage();
  }

  Function? listener;

  @override
  String getIcon() {
    return 'assets/images/dk_net_monitor.png';
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 60);
  }

  @override
  String getKitName() {
    return ApmKitName.kitHttp;
  }

  @override
  void start() {
    // final origin = HttpOverrides.current;
    // HttpOverrides.global = DoKitHttpOverrides(origin);
  }

  @override
  void stop() {}

  void registerListener(Function listener) {
    this.listener = listener;
  }

  void unregisterListener() {
    listener = null;
  }
}

class HttpPage extends StatefulWidget {
  const HttpPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HttpPageState();
  }
}

class HttpPageState extends State<HttpPage> {
  late ScrollController _offsetController;
  static bool showSystemChannel = true;

  Future<void> _listener() async {
    if (!mounted) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
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
    _offsetController = ScrollController();
    ApmKitManager.instance
        .getKit<HttpKit>(ApmKitName.kitHttp)
        ?.registerListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    ApmKitManager.instance
        .getKit<HttpKit>(ApmKitName.kitHttp)
        ?.unregisterListener();
  }

  @override
  Widget build(BuildContext context) {
    final items = ApmKitManager.instance
            .getKit<HttpKit>(ApmKitName.kitHttp)
            ?.getStorage()
            .getAll()
            .reversed
            .toList() ??
        [];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    ApmKitManager.instance
                        .getKit<HttpKit>(ApmKitName.kitHttp)
                        ?.getStorage()
                        .clear();
                  });
                },
                child: const Text(
                  '清除本页数据',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              padding: const EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _offsetController.jumpTo(0),
                child: const Text(
                  '滑动到底部',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            color: const Color(0xfff5f6f7),
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.right,
              thumbVisibility: true,
              controller: _offsetController,
              child: ListView.builder(
                controller: _offsetController,
                itemCount: items.length,
                reverse: true,
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                  bottom: 0,
                  top: 8,
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) =>
                    HttpItemWidget(
                  item: items[index] as HttpInfo1,
                  index: index,
                  isLast: index == items.length - 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HttpItemWidget extends StatefulWidget {
  const HttpItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  final HttpInfo1 item;
  final int index;
  final bool isLast;

  @override
  State<StatefulWidget> createState() {
    return _HttpItemWidgetState();
  }
}

class _HttpItemWidgetState extends State<HttpItemWidget> {
  String getCode() {
    return widget.item.response?.statusCode.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        var text =
            'Uri: ${widget.item.uri}\nRequestParam: ${jsonEncode(widget.item.request.queryParameters)}\nRequestBody: ${jsonEncode(widget.item.request.body)}\nResponse: ${widget.item.response?.data}';
        await Clipboard.setData(
          ClipboardData(
            text: text,
          ),
        );
        CsxDokit.i.toast?.call('请求已拷贝至剪贴板');
      },
      onTap: () {
        setState(() {
          widget.item.expand = !widget.item.expand;
        });
      },
      child: Card(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 80,
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12,
              ),
              child: RichText(
                maxLines: widget.item.expand ? 9999 : 7,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text:
                          '[${TimeUtils.toTimeString(widget.item.startTimestamp)}]',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xff333333),
                        height: 1.2,
                      ),
                    ),
                    WidgetSpan(
                      child: Container(
                        height: 11,
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                          color: [
                            200,
                            0,
                          ].contains(widget.item.response?.statusCode)
                              ? const Color(0xff337cc4)
                              : const Color(0xffd0607e),
                        ),
                        child: Text(
                          getCode(),
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xffffffff),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: '  ${widget.item.method}'
                          '  Cost:${(widget.item.response?.endTimestamp ?? 0) > 0 ? ('${widget.item.response!.endTimestamp - widget.item.startTimestamp}ms') : '-'} ',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xff666666),
                        height: 1.5,
                      ),
                    ),
                    const TextSpan(
                      text: '\nUri: ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xff333333),
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.item.uri.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                    const TextSpan(
                      text: '\nRequestHeader: ',
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 10,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: jsonEncode(widget.item.request.header),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                    const TextSpan(
                      text: '\nParameters: ',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: jsonEncode(widget.item.request.queryParameters),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                    const TextSpan(
                      text: '\nRequestBody: ',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: jsonEncode(widget.item.request.body),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                    const TextSpan(
                      text: '\nResponseHeader: ',
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 10,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: jsonEncode(widget.item.response?.header),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                    const TextSpan(
                      text: '\nResponse: ',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: (widget.item.response?.data is Map)
                          ? jsonEncode(widget.item.response?.data)
                          : widget.item.response?.data.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Color(0xff666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              widget.item.expand
                  ? 'assets/images/dk_channel_expand_h.png'
                  : 'assets/images/dk_channel_expand_n.png',
              package: dkPackageName,
              height: 14,
              width: 9,
            ),
          ],
        ),
      ),
    );
  }
}
