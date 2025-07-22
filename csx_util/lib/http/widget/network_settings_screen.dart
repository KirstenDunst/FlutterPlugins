import 'package:csx_util/util/shared_preferences_util.dart';
import 'package:flutter/material.dart';
import '../../extension/string_ext.dart';

import '../model/shared_preference_key.dart';
import '../util/dio_http_util.dart';

///网络代理&baseUrl配置页面
class NetworkSettingScreen extends StatefulWidget {
  const NetworkSettingScreen({super.key});

  @override
  State<NetworkSettingScreen> createState() => _NetworkSettingScreenState();
}

class _NetworkSettingScreenState extends State<NetworkSettingScreen> {
  String? _customBaseUrl;
  String _currentProxy = '';
  late String _currentBaseUrl;

  @override
  void initState() {
    super.initState();
    _currentBaseUrl = DioHttpUtil().baseUrl;
    _currentProxy = DioHttpUtil().proxy;
    SharedPreferenceService.instance
        .get<String>(HTTPSharedPreKey.baseUrl, '')
        .then((value) {
          setState(() {
            _customBaseUrl = value;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('网络配置')),
      body: _buildConfigWidget(),
    );
  }

  Widget _buildConfigWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              const Text('设置baseUrl'),
              const SizedBox(width: 20),
              Text(
                '当前地址: ${_customBaseUrl.isNullOrEmpty ? _currentBaseUrl : _customBaseUrl}',
                style: TextStyle(fontSize: 12, color: const Color(0x88333333)),
              ),
            ],
          ),
          ..._buildUrlList(),
          _buildBaseUrlField(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('当前代理: $_currentProxy'),
          ),
          _buildProxyField(),
          const SizedBox(height: 10),
          _buildApplyHint(),
          const SizedBox(height: 20),
          _buildApplyButton(),
          _buildResetButton(),
        ],
      ),
    );
  }

  ///预定义baseUrl列表
  List<Widget> _buildUrlList() {
    return DioHttpUtil().httpConfig.baseUrlMap.entries.map((entry) {
      return RadioListTile<String>(
        title: Text('${entry.key}:${entry.value}'),
        value: entry.value,
        groupValue: _currentBaseUrl,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _customBaseUrl = '';
              _currentBaseUrl = value;
            });
          }
        },
      );
    }).toList();
  }

  Widget _buildBaseUrlField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          setState(() => _customBaseUrl = value);
        },
        onFieldSubmitted: (string) => FocusScope.of(context).unfocus(),
        decoration: const InputDecoration(
          labelText: '输入自定义baseUrl',
          prefixIcon: Icon(Icons.computer),
          hintText: '参考格式http://fw.dev.brainco.cn',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildProxyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        onChanged: (value) => _currentProxy = value,
        onFieldSubmitted: (string) => FocusScope.of(context).unfocus(),
        decoration: const InputDecoration(
          labelText: '设置新的代理',
          prefixIcon: Icon(Icons.settings_ethernet),
          hintText: '参考格式192.168.2.3:8888',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyHint() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '当前页面所有配置，只有在下方按钮点击后才会生效',
        style: TextStyle(fontSize: 12, color: const Color(0x88333333)),
      ),
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: () {
        ///首先判断自定义baseUrl是否非空
        if (_customBaseUrl.isNotNullOrEmpty) {
          DioHttpUtil().baseUrl = (_customBaseUrl!);
        } else if (_currentBaseUrl.isNotNullOrEmpty) {
          DioHttpUtil().baseUrl = (_currentBaseUrl);
        }
        DioHttpUtil().proxy = _currentProxy;
        debugPrint('网络配置更新 ${DioHttpUtil().baseUrl}\n$_currentProxy');
        Navigator.of(context).pop(true);
      },
      child: const Text('点击生效'),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: () {
        DioHttpUtil().proxy = '';
        _currentProxy = DioHttpUtil().proxy;
        setState(() {});
        debugPrint('清除代理配置');
      },
      child: const Text('清除代理配置'),
    );
  }
}
