/*
 * @Author: Cao Shixin
 * @Date: 2023-04-13 17:37:38
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-04-13 17:37:38
 * @Description: 
 */


import 'package:flutter/material.dart';

/// cache gif fetched image
class GifCache {
  final Map<String, List<ImageInfo>> caches = {};

  void clear() {
    caches.clear();
  }

  bool evict(Object key) {
    var pendingImage = caches.remove(key);
    if (pendingImage != null) {
      return true;
    }
    return false;
  }
}