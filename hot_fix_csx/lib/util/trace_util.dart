/*
 * @Author: Cao Shixin
 * @Date: 2022-04-19 15:08:57
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 15:11:35
 * @Description: 堆栈信息
 */

import 'package:stack_trace/stack_trace.dart';

class TraceTool {
  static String? get nowClass {
    var frames = Trace.current().frames; //调用栈
    if (frames.length > 1) {
      var member = frames[1].member;
      var parts = member!.split(".");
      if (parts.length > 1) {
        return parts[1];
      }
    }
    return null;
  }

  static String? get nowMethod {
    var frames = Trace.current().frames;
    if (frames.length > 1) {
      return frames[1].member;
    }
    return null;
  }

  static String? get nowFile {
    var frames = Trace.current().frames;
    if (frames.length > 1) {
      return frames[1].uri.path;
    }
    return null;
  }

  static String? get nowFileName {
    var nowFilePath = nowFile;
    if (nowFilePath != null) {
      return nowFilePath.split('/').last;
    } else {
      return null;
    }
  }

  int? get nowLine {
    var frames = Trace.current().frames;
    if (frames.length > 1) {
      return frames[1].line;
    }
    return null;
  }
}
