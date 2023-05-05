/*
 * @Author: Cao Shixin
 * @Date: 2023-04-13 17:39:50
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-04-14 10:43:34
 * @Description: 
 */
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif_control_csx/model/gif_cache.dart';

class GifNormalTool {
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) {
        client = debugNetworkImageHttpClientProvider!();
      }
      return true;
    }());
    return client;
  }

  static Future<List<ImageInfo>> fetchGif(
      ImageProvider provider, GifCache cache) async {
    List<ImageInfo> infos = [];
    late Uint8List data;
    String key = provider is NetworkImage
        ? provider.url
        : provider is AssetImage
            ? provider.assetName
            : provider is MemoryImage
                ? provider.bytes.toString()
                : "";
    if (cache.caches.containsKey(key)) {
      infos = cache.caches[key]!;
      return infos;
    }
    if (provider is NetworkImage) {
      final Uri resolved = Uri.base.resolve(provider.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      provider.headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      data = await consolidateHttpClientResponseBytes(response);
    } else if (provider is AssetImage) {
      AssetBundleImageKey key =
          await provider.obtainKey(const ImageConfiguration());
      data = (await key.bundle.load(key.name)).buffer.asUint8List();
    } else if (provider is FileImage) {
      data = await provider.file.readAsBytes();
    } else if (provider is MemoryImage) {
      data = provider.bytes;
    }

    var immutableBuffer = await ImmutableBuffer.fromUint8List(data);
    var codec = await PaintingBinding.instance
        .instantiateImageCodecFromBuffer(immutableBuffer);
    infos = [];
    for (int i = 0; i < codec.frameCount; i++) {
      FrameInfo frameInfo = await codec.getNextFrame();
      //scale ??
      infos.add(ImageInfo(image: frameInfo.image));
    }
    cache.caches.putIfAbsent(key, () => infos);
    return infos;
  }
}
