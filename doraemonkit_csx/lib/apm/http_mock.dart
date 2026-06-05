import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doraemonkit_csx/doraemonkit_csx.dart';
import 'package:doraemonkit_csx/kit.dart';
import 'package:doraemonkit_csx/utils/shared_prefer_util.dart';
import 'package:flutter/material.dart';

import '../apm.dart';
import 'http_mock_edit.dart';

class MockModel implements IInfo {
  //用于标记
  String title;
  //是否启用
  bool enable;

  //替换的响应数据内容
  String data;
  //数据是否是字符串，false：执行jsonDecode反编辑
  ParamType paramType;

  //过滤条件，满足条件才会进行mock替换
  MockFilterModel filter;

  MockModel(this.title, this.data, this.paramType, this.enable, this.filter);

  @override
  getValue() {
    return toString();
  }

  factory MockModel.fromJson(Map<String, dynamic> json) {
    return MockModel(
        json['title'],
        json['data'],
        json['paramType'] != null
            ? ParamType.values.firstWhere((e) => e.label == json['paramType'])
            : ParamType.json,
        json['enable'],
        MockFilterModel.fromJson(json['filter']));
  }

  Map toJson() {
    return {
      'title': title,
      'data': data,
      'paramType': paramType.label,
      'enable': enable,
      'filter': filter.toJson(),
    };
  }
}

class HttpMcokKit extends ApmKit {
  @override
  Widget createDisplayPage() {
    return MockPage();
  }

  Function? listener;

  @override
  String getIcon() {
    return 'assets/images/dk_net_mock.png';
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 200);
  }

  @override
  String getKitName() {
    return ApmKitName.kitMock;
  }

  @override
  void start() async {
    //从本地读取数据进行初始化
    var data = await SPService.instance.get(mockLocalKey, '');
    if (data.isNotEmpty) {
      var list = (jsonDecode(data) as List).map((e) => MockModel.fromJson(e));
      var storage = ApmKitManager.instance
          .getKit<HttpMcokKit>(ApmKitName.kitMock)
          ?.getStorage();
      for (var ele in list) {
        storage?.save(ele);
      }
    }
  }

  @override
  void stop() {}
}

final String mockLocalKey = 'mockLocalKey';

class MockPage extends StatefulWidget {
  const MockPage({super.key});

  @override
  State<StatefulWidget> createState() => MockPageState();
}

class MockPageState extends State<MockPage> {
  @override
  Widget build(BuildContext context) {
    final items = ApmKitManager.instance
            .getKit<HttpMcokKit>(ApmKitName.kitMock)
            ?.getStorage()
            .getAll() ??
        [];
    return ColoredBox(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemBuilder: (cont, index) => HttpItemWidget(
              index: index,
              mockModel: items[index] as MockModel,
              isLast: index == items.length - 1,
              deleteTap: () {
                ApmKitManager.instance
                    .getKit<HttpMcokKit>(ApmKitName.kitMock)
                    ?.delete(index);
                MockLocalTool.editData();
                setState(() {});
              },
            ),
            itemCount: items.length,
          )),
          ElevatedButton(
            onPressed: () => enterNewOverLayer(
              (entry) => Scaffold(
                appBar: AppBar(
                  title: Text('新增Mock'),
                  leading: GestureDetector(
                    onTap: () => entry?.remove(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
                ),
                body: EditMockPage(
                  saveCallBack: (mockModel) {
                    ApmKitManager.instance
                        .getKit<HttpMcokKit>(ApmKitName.kitMock)
                        ?.save(mockModel);
                    MockLocalTool.editData();
                    setState(() {});
                    entry?.remove();
                  },
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text('新增'),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class MockLocalTool {
  //记录mock操作数据
  static Future editData() async {
    var items = ApmKitManager.instance
            .getKit<HttpMcokKit>(ApmKitName.kitMock)
            ?.getStorage()
            .getAll() ??
        [];
    await SPService.instance.set(
        mockLocalKey,
        jsonEncode(
            (items as List).map((e) => (e as MockModel).toJson()).toList()));
  }

  //将字符串转化成对应类型
  static dynamic parseStringByParamType(String data, ParamType paramType) {
    switch (paramType) {
      case ParamType.num:
        return num.tryParse(data);
      case ParamType.bool:
        return data.toLowerCase() != 'false';
      case ParamType.json:
        return jsonDecode(data);
      case ParamType.list:
        return jsonDecode(data);
      case ParamType.string:
        return data;
    }
  }

  //将字符串转化成对应类型 (data放数据大的，body放检测包含的)
  static bool compareDataByParamType(
      String data, ParamType paramType, dynamic body) {
    switch (paramType) {
      case ParamType.num:
        var dataValue = num.tryParse(data);
        return (body is num) && (dataValue == body);
      case ParamType.bool:
        var dataValue = data.toLowerCase() != 'false';
        return (body is bool) && (dataValue == body);
      case ParamType.json:
        var dataValue = jsonDecode(data);
        return (body is Map) && mapContainEqual(dataValue, body);
      case ParamType.list:
        var dataValue = jsonDecode(data);
        return (body is List) && compareList(dataValue, body);
      case ParamType.string:
        return (body is String) && (data == body);
    }
  }

  //比对Map是否匹配(只要在json1中能找到json2的key且对应value一致，则判定匹配)，json1包含json2即可
  static bool mapContainEqual(Map json1, Map json2) {
    var isContain = true;
    json2.forEach((key, value) {
      if (json1.containsKey(key)) {
        var tempValue = json1[key];
        if (tempValue.runtimeType == value.runtimeType) {
          if (value is List) {
            var temp = compareList(tempValue, value);
            if (!temp) {
              isContain = false;
            }
          } else if (value is Map) {
            var temp = mapContainEqual(tempValue, value);
            if (!temp) {
              isContain = false;
            }
          } else if (tempValue != value) {
            isContain = false;
          }
        } else {
          isContain = false;
        }
      } else {
        isContain = false;
      }
    });
    return isContain;
  }

  //比对Map是否匹配，两个内容一致
  static bool compareList(List arr1, List arr2) {
    if (arr1.length != arr2.length) {
      return false;
    }
    var isSameValue = true;
    for (var i = 0; i < arr1.length; i++) {
      var ele = arr1[i];
      var otherEle = arr2[i];
      if (ele.runtimeType == otherEle.runtimeType) {
        if (ele is List) {
          isSameValue = compareList(ele, otherEle);
          if (!isSameValue) {
            break;
          }
        } else if (ele is Map) {
          isSameValue = mapContainEqual(ele, otherEle);
          if (!isSameValue) {
            break;
          }
        } else if (ele != otherEle) {
          isSameValue = false;
          break;
        }
      } else {
        isSameValue = false;
        break;
      }
    }
    return isSameValue;
  }

  //检测拦截mock数据处理，返回null表示未匹配到，正常进行网络请求
  static Response? parseMockData(RequestOptions options) {
    var items = ApmKitManager.instance
            .getKit<HttpMcokKit>(ApmKitName.kitMock)
            ?.getStorage()
            .getAll() ??
        [];
    if (items.isEmpty) {
      return null;
    }
    var enableItems = (items as List).where((e) => (e as MockModel).enable);
    if (enableItems.isEmpty) {
      return null;
    }
    for (var i = 0; i < enableItems.length; i++) {
      var item = enableItems.elementAt(i) as MockModel;
      if (item.filter.match(options)) {
        var result =
            MockLocalTool.parseStringByParamType(item.data, item.paramType);
        return Response(
          data: result,
          statusCode: 200,
          requestOptions: options,
        );
      }
    }
    return null;
  }
}

class HttpItemWidget extends StatefulWidget {
  const HttpItemWidget({
    super.key,
    required this.mockModel,
    required this.index,
    required this.isLast,
    required this.deleteTap,
  });
  final VoidCallback deleteTap;
  final MockModel mockModel;
  final int index;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _HttpItemWidgetState();
}

class _HttpItemWidgetState extends State<HttpItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.mockModel.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: widget.mockModel.enable,
              onChanged: (value) {
                setState(() {
                  widget.mockModel.enable = value;
                });
                MockLocalTool.editData();
              },
            ),
            const SizedBox(width: 4),
            _actionButton(
              Icons.edit_outlined,
              '编辑',
              _edit,
            ),
            const SizedBox(width: 8),
            _actionButton(
              Icons.delete_outline,
              '删除',
              widget.deleteTap,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _edit() => enterNewOverLayer(
        (entry) => Scaffold(
          appBar: AppBar(
            title: const Text('编辑Mock'),
            leading: IconButton(
              onPressed: () => entry?.remove(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: EditMockPage(
            mockModel: widget.mockModel,
            saveCallBack: (mockModel) {
              ApmKitManager.instance
                  .getKit<HttpMcokKit>(ApmKitName.kitMock)
                  ?.edit(widget.index, mockModel);
              MockLocalTool.editData();
              setState(() {});
              entry?.remove();
            },
          ),
        ),
      );
}
