import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPService {
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  static SPService instance = SPService();

  Future<bool> containsKey(String key) async =>
      (await _prefsFuture).containsKey(key);

  ///根据默认值的类型获取对应类型的值
  Future<T> get<T>(String key, T defaultValue) async {
    Object? result;
    var sharedPreferences = await _prefsFuture;
    if (defaultValue is bool) {
      result = sharedPreferences.getBool(key);
    } else if (defaultValue is String) {
      result = sharedPreferences.getString(key);
    } else if (defaultValue is double) {
      result = sharedPreferences.getDouble(key);
    } else if (defaultValue is int) {
      result = sharedPreferences.getInt(key);
    } else {
      debugPrint('SharedPreferenceService: get($key, $T) not supported');
      throw 'SharedPreferenceService: get($key, $T) not supported';
    }
    return (result as T?) ?? defaultValue;
  }

  ///根据[value]的类型调用设置方法
  Future<bool> set<T>(String key, T value) async {
    var sharedPreferences = await _prefsFuture;
    if (value is bool) {
      return sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return sharedPreferences.setString(key, value);
    } else if (value is double) {
      return sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      return sharedPreferences.setInt(key, value);
    } else {
      debugPrint('SharedPreferenceService: set($key, $T) not supported');
      throw 'SharedPreferenceService: set($key, $T) not supported';
    }
  }

  ///清空所有缓存数据；清除缓存的stream；关闭streamController
  Future<bool> clear() async {
    return (await _prefsFuture).clear();
  }

  ///移除key对应的值；清除缓存的stream
  Future<bool> remove(String key) async {
    return (await _prefsFuture).remove(key);
  }
}

class UserDefaultTransTool {
  static String transToString(dynamic originValue) {
    if (originValue is String) {
      return originValue;
    } else if (originValue is num) {
      return originValue.toString();
    } else if (originValue is bool) {
      return originValue.toString();
    } else if (originValue is List || originValue is Map) {
      return jsonEncode(originValue);
    } else {
      return originValue.toString();
    }
  }

  static dynamic transFromString(String content, dynamic originValue) {
    if (originValue is String) {
      return content;
    } else if (originValue is num) {
      return num.tryParse(content);
    } else if (originValue is bool) {
      return content.toLowerCase() == 'true';
    } else if (originValue is List || originValue is Map) {
      try {
        return jsonDecode(content);
      } catch (_) {}
    }
  }
}
