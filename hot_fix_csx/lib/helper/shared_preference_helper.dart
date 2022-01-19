/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:48:04
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-28 17:24:07
 * @Description: 
 */
import 'dart:async';
import 'package:hot_fix_csx/util/stream_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 订阅流时收到的数据
class SharedPreferenceEntry {
  final String key;
  final dynamic value;

  SharedPreferenceEntry(this.key, this.value);
}

class SharedPreferenceService {
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  static SharedPreferenceService instance = SharedPreferenceService();

  StreamController<SharedPreferenceEntry>? _streamController;

  @protected
  StreamController<SharedPreferenceEntry> get streamController {
    return _streamController ??= StreamController.broadcast(sync: true);
  }

  final Map<String, Stream<dynamic>> _cachedStreams = {};

  /// 获取某个key所对应值的流，会自动获取当前值；
  /// 需要调用[set]方法设置值
  Stream<T> getStream<T>(String key, T defaultValue) {
    Stream<T> result;
    if (_cachedStreams[key] == null) {
      final stream1 = streamController.stream
          .where((event) => event.key == key)
          .map((event) => event.value)
          .cast<T>();
      result = stream1.repeatLatest();
      get(key, defaultValue).then((value) {
        streamController.add(SharedPreferenceEntry(key, value));
      });
      _cachedStreams[key] = result;
    } else {
      result = _cachedStreams[key] as Stream<T>;
    }
    return result;
  }

  ///根据默认值的类型获取对应类型的值
  Future<T> get<T>(String key, T defaultValue) async {
    var result;
    if (defaultValue is bool) {
      result = (await _prefsFuture).getBool(key);
    } else if (defaultValue is String) {
      result = (await _prefsFuture).getString(key);
    } else if (defaultValue is double) {
      result = (await _prefsFuture).getDouble(key);
    } else if (defaultValue is int) {
      result = (await _prefsFuture).getInt(key);
    } else if (defaultValue is List<String>) {
      result = (await _prefsFuture).getStringList(key);
    } else {
      debugPrint('SharedPreferenceService: get($key, $T) not supported');
      throw 'SharedPreferenceService: get($key, $T) not supported';
    }
    return result ?? defaultValue;
  }

  ///根据[value]的类型调用设置方法
  Future<void> set<T>(String key, T value) async {
    streamController.add(SharedPreferenceEntry(key, value));
    var sharedPreferences = await _prefsFuture;
    if (value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      await sharedPreferences.setString(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      await sharedPreferences.setInt(key, value);
    } else if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
    } else {
      debugPrint('SharedPreferenceService: set($key, $T) not supported');
      throw 'SharedPreferenceService: set($key, $T) not supported';
    }
  }

  ///清空所有缓存数据；清除缓存的stream；关闭streamController
  Future<bool> clear() async {
    _cachedStreams.clear();
    await _streamController?.close();
    _streamController = null;
    return (await _prefsFuture).clear();
  }

  ///移除key对应的值；清除缓存的stream
  Future<bool> remove(String key) async {
    _cachedStreams.remove(key);
    return (await _prefsFuture).remove(key);
  }
}
