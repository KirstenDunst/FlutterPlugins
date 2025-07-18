/// 数字工具方法
extension NullableNumExtension on num? {
  bool isNullOrZero() {
    return this == null || this == 0;
  }

  bool notNullOrZero() {
    return this != null && this != 0;
  }

  bool largeZero() {
    if (this == null) return false;
    return this! > 0;
  }

  bool largeNum(num n) {
    if (this == null) return false;
    return this! > n;
  }

  ///去掉小数点末位的0
  num simplifyNum() {
    if (this == null) return 0;
    //有小数点
    var thisStr = '$this';
    //有小数点，并且最后为0
    if (thisStr.contains('.') && thisStr.endsWith('0')) {
      //1---先去掉最后的0
      var subNumStr = thisStr.substring(0, thisStr.length - 1);
      //2---去掉0之后如果最后是小数点-则把点去掉
      if (subNumStr.endsWith('.')) {
        subNumStr = subNumStr.substring(0, subNumStr.length - 1);
        return num.parse(subNumStr);
      }
      //如果去掉最后的0之后，最后面不是小数点，进行递归
      return num.parse(subNumStr).simplifyNum();
    } else {
      return this!;
    }
  }
}

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
