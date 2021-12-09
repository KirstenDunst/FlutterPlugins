import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:doraemonkit_csx/kit/apm/apm.dart';
import 'package:doraemonkit_csx/kit/apm/method_channel_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DoKitWidgetsFlutterBinding extends WidgetsFlutterBinding
    with DoKitServicesBinding {
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) DoKitWidgetsFlutterBinding();
    return WidgetsBinding.instance;
  }
}

mixin DoKitServicesBinding on BindingBase, ServicesBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    return DoKitBinaryMessenger(super.createBinaryMessenger());
  }
}

// 扩展1.20版本新增的两个方法，解决低版本编译问题
// 扩展的方法直接调用this.同名方法，在高版本上会调用原方法，低版本上虽然会造成递归调用，但实际不会用到这个方法
extension _BinaryMessengerExt on BinaryMessenger {
  bool checkMessageHandler(String channel, MessageHandler handler) {
    return this.checkMessageHandler(channel, handler);
  }

  bool checkMockMessageHandler(String channel, MessageHandler handler) {
    return this.checkMockMessageHandler(channel, handler);
  }
}

class DoKitBinaryMessenger extends BinaryMessenger {
  final MethodCodec codec = const StandardMethodCodec();
  final BinaryMessenger origin;

  DoKitBinaryMessenger(this.origin);

  @override
  Future<void> handlePlatformMessage(String channel, ByteData data, callback) {
    ChannelInfo info = saveMessage(channel, data, false);
    PlatformMessageResponseCallback wrapper = (ByteData data) {
      resolveResult(info, data);
      callback(data);
    };
    return origin.handlePlatformMessage(channel, data, wrapper);
  }

  @override
  Future<ByteData> send(String channel, ByteData message) async {
    ChannelInfo info = saveMessage(channel, message, true);
    ByteData result = await origin.send(channel, message);
    resolveResult(info, result);
    return result;
  }

  void resolveResult(ChannelInfo info, ByteData result) {
    try {
      if (info != null && result != null) {
        if (info.methodCodec != null) {
          info.results = info.methodCodec.decodeEnvelope(result);
          info.endTimestamp = new DateTime.now().millisecondsSinceEpoch;
        } else if (info.messageCodec != null) {
          info.results = info.messageCodec.decodeMessage(result);
          info.endTimestamp = new DateTime.now().millisecondsSinceEpoch;
        }else{
          info.endTimestamp = new DateTime.now().millisecondsSinceEpoch;
        }
      }
    } catch (e) {}
    info.methodCodec = null;
    info.messageCodec = null;
  }

  ChannelInfo saveMessage(String name, ByteData data, bool send) {
    MethodChannelKit kit =
        ApmKitManager.instance.getKit<MethodChannelKit>(ApmKitName.KIT_CHANNEL);
    if (kit == null) {
      return null;
    }
    ChannelInfo info;
    try {
      info = filterSystemChannel(name, data, send);
      if (info == null) {
        MethodCall call = codec.decodeMethodCall(data);
        info = ChannelInfo(name, call.method, call.arguments,
            send ? ChannelInfo.TYPE_USER_SEND : ChannelInfo.TYPE_USER_RECEIVE);
        info.methodCodec = codec;
      }
    } catch (e) {
      info = ChannelInfo.error(name,
          send ? ChannelInfo.TYPE_USER_SEND : ChannelInfo.TYPE_USER_RECEIVE);
    }
    kit.save(info);
    return info;
  }

  @override
  void setMessageHandler(
      String channel, Future<ByteData> Function(ByteData message) handler) {
    origin.setMessageHandler(channel, handler);
  }

  @override
  void setMockMessageHandler(
      String channel, Future<ByteData> Function(ByteData message) handler) {
    origin.setMockMessageHandler(channel, handler);
  }

  bool checkMessageHandler(String channel, MessageHandler handler) {
    return origin.checkMessageHandler(channel, handler);
  }

  bool checkMockMessageHandler(String channel, MessageHandler handler) {
    return origin.checkMockMessageHandler(channel, handler);
  }

  IInfo filterSystemChannel(String name, ByteData data, bool send) {
    if (name == SystemChannels.lifecycle.name) {
      return decodeMessage(name, data, SystemChannels.lifecycle.codec, send);
    }
    if (name == SystemChannels.accessibility.name) {
      return decodeMessage(
          name, data, SystemChannels.accessibility.codec, send);
    }
    if (name == SystemChannels.keyEvent.name) {
      return decodeMessage(name, data, SystemChannels.keyEvent.codec, send);
    }
    if (name == SystemChannels.navigation.name) {
      return decodeMethod(name, data, SystemChannels.navigation.codec, send);
    }
    if (name == SystemChannels.platform.name) {
      return decodeMethod(name, data, SystemChannels.platform.codec, send);
    }
    if (name == SystemChannels.platform_views.name) {
      return decodeMethod(
          name, data, SystemChannels.platform_views.codec, send);
    }
    if (name == SystemChannels.skia.name) {
      return decodeMethod(name, data, SystemChannels.skia.codec, send);
    }
    if (name == SystemChannels.system.name) {
      return decodeMessage(name, data, SystemChannels.system.codec, send);
    }
    if (name == SystemChannels.textInput.name) {
      return decodeMethod(name, data, SystemChannels.textInput.codec, send);
    }
    if (name == 'flutter/assets') {
      return decodeByteMessage(name, data, send);
    }
    return null;
  }

  IInfo decodeByteMessage(String name, ByteData data, bool send) {
    return ChannelInfo(name, null, utf8.decode(data.buffer.asUint8List()),
        send ? ChannelInfo.TYPE_SYSTEM_SEND : ChannelInfo.TYPE_SYSTEM_RECEIVE);
  }

  IInfo decodeMessage(
      String name, ByteData data, MessageCodec codec, bool send) {
    dynamic call = codec.decodeMessage(data);
    return ChannelInfo(name, call.toString(), null,
        send ? ChannelInfo.TYPE_SYSTEM_SEND : ChannelInfo.TYPE_SYSTEM_RECEIVE)
      ..messageCodec = codec;
  }

  IInfo decodeMethod(String name, ByteData data, MethodCodec codec, bool send) {
    MethodCall call = codec.decodeMethodCall(data);
    return ChannelInfo(name, call.method, call.arguments,
        send ? ChannelInfo.TYPE_SYSTEM_SEND : ChannelInfo.TYPE_SYSTEM_RECEIVE)
      ..methodCodec = codec;
  }
}
