import 'dart:collection';
import 'package:flutter/material.dart';

import '../kit.dart';
import '../page/resident_page.dart';

typedef KitPageBuilder = Widget Function();

class BizKitManager {
  BizKitManager._();

  static final BizKitManager _instance = BizKitManager._();

  static BizKitManager get instance => _instance;

  /// 存储BizKit分组的映射数据
  final Map<String, List<BizKit>> _kitGroupMap = <String, List<BizKit>>{};

  /// 存储分组的提示信息
  final Map<String, String> _kitGroupTips = <String, String>{};

  void _addBizKit2Group(
    String groupName,
    String kitName,
    String? icon,
    String? desc,
    KitPageBuilder? kitBuilder,
    String? key,
    Function? action,
  ) {
    _registerBizKitGroup(groupName, desc);

    final kit = BizKit(
      kitName,
      groupName,
      icon: icon,
      desc: desc,
      kitBuilder: kitBuilder,
      key: key,
      action: action,
    );
    final kitList = _kitGroupMap[groupName];
    kitList!.add(kit);
  }

  void _registerBizKitGroup(String groupName, String? tip) {
    final kitList = <BizKit>[];
    _kitGroupMap.putIfAbsent(groupName, () => kitList);
    _addBizKitGroupTip(groupName, tip);
  }

  /// Getter
  Map<String, List<BizKit>> get kitGroupMap => _kitGroupMap;

  Map<String, String> get kitGroupTips => _kitGroupTips;

  /// 构建BizKit key值和BizKit对象间的映射关系
  Map<String, BizKit> get kitMap {
    final allKitList = kitGroupMap.values.expand((e) => e).toList();
    final kitMap = <String, BizKit>{};
    for (var e in allKitList) {
      kitMap.putIfAbsent(e.key ?? '', () => e);
    }

    return UnmodifiableMapView(kitMap);
  }

  /// 获取分组键值列表
  List<String> groupKeys() => BizKitManager.instance.kitGroupMap.keys.toList();

  /// 获取分组个数
  int get groupCounts => kitGroupMap.length;

  /// 添加group的tip信息，不可在添加group前操作
  void _addBizKitGroupTip(String name, String? tip) {
    final groupExist = kitGroupMap.keys.contains(name);
    assert(
      groupExist,
      'Can not add [$name] group tip before adding [$name] group.',
    );

    if (tip == null) {
      _kitGroupTips.remove(name);
      return;
    }
    _kitGroupTips[name] = tip;
  }

  /// 根据key获取BizKit
  T? getKit<T extends BizKit>(String key) {
    if (kitMap.containsKey(key)) {
      return kitMap[key] as T;
    }
    return null;
  }

  /// 创建BizKit对象
  T createBizKit<T extends BizKit>(
    String name,
    String group, {
    String? key,
    String? icon,
    String? desc,
    KitPageBuilder? kitBuilder,
    Function? action,
  }) {
    final kit = BizKit(
      name,
      group,
      icon: icon,
      desc: desc,
      kitBuilder: kitBuilder,
      key: key,
      action: action,
    );
    return kit as T;
  }

  /// 更新group信息，详见[_addKitGroupTip]
  /// [group] kit归属的组
  /// [desc] kit的描述信息
  void updateBizKitGroupTip(String group, String desc) {
    _addBizKitGroupTip(group, desc);
  }

  /// 向group中添加一组BizKit
  /// [group] kit归属的组
  /// [desc] kit的描述信息
  /// [bizKits] 一组bizKit集合
  void addBizKits(List<BizKit> bizKits) {
    if (bizKits.isEmpty) {
      return;
    }

    var group = bizKits.first.group;
    var desc = bizKits.first.desc;
    _registerBizKitGroup(group, desc);
    final kitList = _kitGroupMap[group];
    kitList!.addAll(bizKits);
  }

  /// 详见[buildBizKit]
  void addBizKit<S extends BizKit>(String? key, S kit) {
    BizKit ikit = kit;
    buildBizKit(
      ikit.name,
      ikit.group,
      key: key,
      icon: ikit.icon,
      desc: ikit.desc,
      kitBuilder: ikit.kitPageBuilder,
      action: ikit.action,
    );
  }

  /// [key] kit的唯一标识，全局不可重复，不传则默认使用[BizKit._defaultKey];
  /// [name] kit显示的名字;
  /// [icon] kit的显示的图标，不传则使用默认图标;
  /// [group] kit归属的组，如果该组不存在，则会自动创建;
  /// [desc] kit的描述信息，不会以任何形式显示出来;
  /// [kitBuilder] kit对应的页面的WidgetBuilder，点击该kit的图标后跳转到的Widget页面.
  /// [action] 点击该kit的图标后响应事件, 用于不需要跳转widget页面的情况.
  void buildBizKit(
    String name,
    String group, {
    String? key,
    String? icon,
    String? desc,
    KitPageBuilder? kitBuilder,
    Function? action,
  }) {
    if (!_kitGroupMap.containsKey(group)) {
      _addBizKit2Group(group, name, icon, desc, kitBuilder, key, action);
    } else {
      final keyList = kitMap.keys;
      final kit = BizKit(
        name,
        group,
        icon: icon,
        desc: desc,
        kitBuilder: kitBuilder,
        key: key,
        action: action,
      );
      final exist = keyList.contains(kit.key);
      assert(!exist, 'The ${kit.toString()} kit already exists.');
      _kitGroupMap[group]!.add(kit);
    }
  }
}

class BizKit extends IKit {
  final String name;
  final String group;

  final String? key;
  final String? icon;
  final String? desc;
  final KitPageBuilder? kitBuilder;
  final Function? action;

  BizKit(
    this.name,
    this.group, {
    this.icon,
    this.desc,
    this.kitBuilder,
    this.key,
    this.action,
  });

  String get _defaultKey => '${group}_${name}_${icon}_$desc';

  KitPageBuilder? get kitPageBuilder => kitBuilder;

  @override
  String toString() {
    final descToString = desc == null ? 'null' : '"$desc"';
    return '[group:"$group", name:"$name", icon:"$icon", desc:$descToString]';
  }

  @override
  String getIcon() {
    return 'assets/images/dk_frame_hist.png';
  }

  @override
  String getKitName() {
    return name;
  }

  @override
  void tabAction() {
    if (kitPageBuilder != null) {
      ResidentPage.residentPageKey.currentState
          ?.tapListener(key ?? _defaultKey);
    }
    action?.call();
  }

  /// 返回BizKit 绑定的widget页面
  /// 如有的话，否则返回null
  Widget? displayPage() {
    if (kitPageBuilder == null) {
      return null;
    }
    final kitPage = kitPageBuilder!();
    return kitPage;
  }
}
