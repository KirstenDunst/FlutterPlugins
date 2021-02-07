/// 数字工具方法
extension NumExtension on num {
  ///字节为单位的数值转换成适合的单位
  String sizeFormat() {
    var result = this;
    if (result < 1024) {
      return '${result.toStringAsFixed(0)}B';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(0)}KB';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(1)}MB';
    } else {
      result = result / 1024;
    }
    return '${result.toStringAsFixed(2)}GB';
  }
}
