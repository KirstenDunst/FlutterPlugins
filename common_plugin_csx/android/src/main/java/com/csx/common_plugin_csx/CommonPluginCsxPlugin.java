package com.csx.common_plugin_csx;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** CommonPluginCsxPlugin */
public class CommonPluginCsxPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "common_plugin_csx");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getFileMd5")) {
      String md5Str = getFileMD5( new File(call.arguments.toString()),16);
      result.success(md5Str);
    } else {
      result.notImplemented();
    }
  }

  /**
   * 获取单个文件的MD5值
   * 
   * @param file  文件
   * @param radix 位 16 32 64
   *
   * @return
   */
  private String getFileMD5(File file, int radix) {
    if (!file.isFile()) {
      return null;
    }
    MessageDigest digest = null;
    FileInputStream in = null;
    byte buffer[] = new byte[1024];
    int len;
    try {
      digest = MessageDigest.getInstance("MD5");
      in = new FileInputStream(file);
      while ((len = in.read(buffer, 0, 1024)) != -1) {
        digest.update(buffer, 0, len);
      }
      in.close();
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
    BigInteger bigInt = new BigInteger(1, digest.digest());
    return bigInt.toString(radix);
  }

  /**
   * 获取文件夹中文件的MD5值
   * 
   * @param file
   * @param listChild
   *                  ;true递归子目录中的文件
   * @return
   */
  private Map<String, String> getDirMD5(File file, boolean listChild) {
    if (!file.isDirectory()) {
      return null;
    }
    Map<String, String> map = new HashMap<String, String>();
    String md5;
    File files[] = file.listFiles();
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      if (f.isDirectory() && listChild) {
        map.putAll(getDirMD5(f, listChild));
      } else {
        md5 = getFileMD5(f,16);
        if (md5 != null) {
          map.put(f.getPath(), md5);
        }
      }
    }
    return map;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
