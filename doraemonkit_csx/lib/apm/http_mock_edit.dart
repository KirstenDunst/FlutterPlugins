import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doraemonkit_csx/doraemonkit_csx.dart';
import 'package:flutter/material.dart';

import 'http_mock.dart';

class EditMockPage extends StatefulWidget {
  final MockModel? mockModel;
  final Function(MockModel)? saveCallBack;
  const EditMockPage({super.key, this.mockModel, this.saveCallBack});

  @override
  State<EditMockPage> createState() => _EditMockPageState();
}

class _EditMockPageState extends State<EditMockPage> {
  late bool _enable, _queryExpand, _bodyExpand, _responseExpand;
  late TextEditingController _titleController,
      _dataController,
      _queryController,
      _bodyController,
      _urlController;
  HttpAskType? _askType;
  late ParamType _bodyType, _responseType;

  @override
  void initState() {
    super.initState();
    _queryExpand = false;
    _bodyExpand = false;
    _responseExpand = true;

    _askType = widget.mockModel?.filter.filterAskType;
    _enable = widget.mockModel?.enable ?? true;

    _bodyType = widget.mockModel?.filter.bodyParamType ?? ParamType.json;
    _responseType = widget.mockModel?.paramType ?? ParamType.json;

    _titleController =
        TextEditingController(text: widget.mockModel?.title ?? '');
    _dataController = TextEditingController(text: widget.mockModel?.data ?? '');
    _urlController =
        TextEditingController(text: widget.mockModel?.filter.filterUrl ?? '');
    var queryParam = widget.mockModel?.filter.filterQueryParam;
    _queryController = TextEditingController(
        text: queryParam == null ? '' : jsonEncode(queryParam));
    var body = widget.mockModel?.filter.filterBodyParam;
    _bodyController = TextEditingController(text: body ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTips(),
                      const SizedBox(height: 16),
                      _buildBaseInfo(),
                      const SizedBox(height: 16),
                      _buildRequestFilter(),
                      const SizedBox(height: 16),
                      _buildTextEditor(
                        "Query 参数(选填,Json类型)",
                        _queryExpand,
                        () => setState(() => _queryExpand = !_queryExpand),
                        _queryController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextEditor(
                        "Body 参数(选填)",
                        _bodyExpand,
                        () => setState(() => _bodyExpand = !_bodyExpand),
                        _bodyController,
                        valueType: _bodyType,
                        onTypeChanged: (v) => setState(() => _bodyType = v),
                      ),
                      const SizedBox(height: 16),
                      _buildTextEditor(
                        "Mock Response",
                        _responseExpand,
                        () =>
                            setState(() => _responseExpand = !_responseExpand),
                        _dataController,
                        valueType: _responseType,
                        onTypeChanged: (v) => setState(() => _responseType = v),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomSave(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '设置请求过滤条件，满足条件后将自动替换为 Mock 数据。未配置项将自动忽略。',
              style: TextStyle(
                color: Colors.orange.shade800,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBaseInfo() {
    return _section(
      '基础配置',
      Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Mock标题',
              hintText: '请输入标题',
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.power_settings_new),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '启用此 Mock',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _enable,
                onChanged: (v) {
                  setState(() {
                    _enable = v;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestFilter() {
    return _section(
      '请求过滤规则',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请求方式',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...HttpAskType.values.map(
                (e) => ChoiceChip(
                  showCheckmark: false,
                  label: Text(e.name.toUpperCase()),
                  selected: _askType == e,
                  onSelected: (_) {
                    setState(() {
                      _askType = e;
                    });
                  },
                ),
              ),
              ChoiceChip(
                label: const Text('不限'),
                selected: _askType == null,
                onSelected: (_) {
                  setState(() {
                    _askType = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL匹配',
              hintText: '/api/user/info',
              prefixIcon: Icon(Icons.link),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditor(
    String title,
    bool expanded,
    VoidCallback onExpandChanged,
    TextEditingController controller, {
    ParamType? valueType,
    ValueChanged<ParamType>? onTypeChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onExpandChanged,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 16),
              if (valueType != null && onTypeChanged != null) ...[
                const Text(
                  '数据类型',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildTypeSelector(
                  valueType,
                  onTypeChanged,
                ),
                const SizedBox(height: 12),
              ],
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller,
                  expands: true,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: '请输入内容',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(
    ParamType value,
    ValueChanged<ParamType> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ParamType.values
          .map((e) => ChoiceChip(
                label: Text(e.label),
                selected: value == e,
                showCheckmark: false,
                onSelected: (_) {
                  onChanged(e);
                },
              ))
          .toList(),
    );
  }

  Widget _section(
    String title,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomSave() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text(
              '保存 Mock 配置',
            ),
            onPressed: _save,
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      CsxDokit.i.toastC('请设置Mock标题');
      return;
    }

    if (_urlController.text.isEmpty) {
      CsxDokit.i.toastC('请设置过滤URL');
      return;
    }
    if (_dataController.text.isEmpty) {
      CsxDokit.i.toastC('请设置响应数据');
      return;
    }
    Map? filterQueryParam;
    if (_queryController.text.isNotEmpty) {
      var tempMap = jsonDecode(_queryController.text);
      if (tempMap is! Map) {
        CsxDokit.i.toastC('Query 参数必须要Json类型');
        return;
      }
    }

    final model = MockModel(
      _titleController.text,
      _dataController.text,
      _responseType,
      _enable,
      MockFilterModel(
        _urlController.text,
        filterAskType: _askType,
        filterBodyParam: _bodyController.text,
        filterQueryParam: filterQueryParam,
        bodyParamType: _bodyType,
      ),
    );

    widget.saveCallBack?.call(model);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dataController.dispose();
    _queryController.dispose();
    _bodyController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}

enum ParamType {
  num('Num'),
  string('String'),
  json('Json'),
  list('List'),
  bool('Bool');

  const ParamType(this.label);
  final String label;
}

//请求方式
enum HttpAskType {
  get('GET'),
  post('POST'),
  put('PUT'),
  head('HEAD'),
  delete('DELETE'),
  patch('PATCH');

  const HttpAskType(this.method);
  final String method;
}

class MockFilterModel {
  //过滤条件
  String filterUrl;
  //请求方式
  HttpAskType? filterAskType;
  //body参数，匹配设置的key对应的value，没有找到key则匹配失败，不设置则不进行此项匹配逻辑
  String? filterBodyParam;
  // 是否启用body参数字符串匹配，true：字符串形式匹配，false：json格式匹配
  ParamType bodyParamType;
  //query参数(一定是Map)，匹配设置的key对应的value，没有找到key则匹配失败，不设置则不进行此项匹配逻辑
  Map? filterQueryParam;

  bool match(RequestOptions options) {
    var isMatch = options.uri.path.contains(filterUrl);
    if (!isMatch) {
      return false;
    }
    if (filterAskType != null) {
      isMatch = filterAskType!.method == options.method;
      if (!isMatch) {
        return false;
      }
    }
    if (filterBodyParam != null && filterBodyParam!.isNotEmpty) {
      isMatch = MockLocalTool.compareDataByParamType(
          options.data, bodyParamType, filterBodyParam!);
      if (!isMatch) {
        return false;
      }
    }
    if (filterQueryParam != null) {
      isMatch = MockLocalTool.compareDataByParamType(
          options.data, bodyParamType, filterQueryParam!);
      if (!isMatch) {
        return false;
      }
    }
    return isMatch;
  }

  MockFilterModel(this.filterUrl,
      {this.filterAskType,
      this.filterBodyParam,
      this.filterQueryParam,
      this.bodyParamType = ParamType.json});

  factory MockFilterModel.fromJson(Map<String, dynamic> json) {
    return MockFilterModel(
      json['filterUrl'],
      filterAskType: json['filterAskType'] != null
          ? HttpAskType.values
              .firstWhere((e) => e.name == json['filterAskType'])
          : null,
      filterBodyParam: json['filterBodyParam'],
      filterQueryParam: json['filterQueryParam'],
      bodyParamType: json['bodyParamType'] != null
          ? ParamType.values.firstWhere((e) => e.label == json['bodyParamType'])
          : ParamType.json,
    );
  }

  Map toJson() {
    return {
      'filterUrl': filterUrl,
      'filterAskType': filterAskType?.name,
      'filterBodyParam': filterBodyParam,
      'filterQueryParam': filterQueryParam,
      'bodyParamType': bodyParamType.label,
    };
  }
}
