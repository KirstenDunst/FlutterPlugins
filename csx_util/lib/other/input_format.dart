import 'package:flutter/services.dart';

//Flutter控制TextFild输入框只能输入小数点后两位
class PrecisionLimitFormatter extends TextInputFormatter {
  final int scale;
  PrecisionLimitFormatter(this.scale);

  RegExp exp = RegExp("[0-9.]");
  static const String _pointer = ".";
  static const String _doubleZero = "00";

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(_pointer) && newValue.text.length == 1) {
      //第一个不能输入小数点
      return oldValue;
    }
    //输入完全删除
    if (newValue.text.isEmpty) {
      return TextEditingValue.empty;
    }
    //只允许输入小数
    if (!exp.hasMatch(newValue.text)) {
      return oldValue;
    }
    //包含小数点的情况
    if (newValue.text.contains(_pointer)) {
      //包含多个小数
      if (newValue.text.indexOf(_pointer) !=
          newValue.text.lastIndexOf(_pointer)) {
        return oldValue;
      }
      String input = newValue.text;
      int index = input.indexOf(_pointer);
      //小数点后位数
      int lengthAfterPointer = input.substring(index, input.length).length - 1;
      //小数位大于精度
      if (lengthAfterPointer > scale) {
        return oldValue;
      }
    } else if (newValue.text.startsWith(_pointer) ||
        newValue.text.startsWith(_doubleZero)) {
      //不包含小数点,不能以“00”开头
      return oldValue;
    }
    return newValue;
  }
}

//数字输入限制，小数位数，最大值
class NumberInputLimit extends TextInputFormatter {
  //输入字符的范围
  String inputScope;
  //允许的小数位数
  final int? digit;
  //允许的最大值
  final num? maxValue;
  //是否支持 false不支持负数(默认不支持)
  final bool isNegative;

  NumberInputLimit({
    this.inputScope = '-.0123456789',
    this.digit,
    this.maxValue,
    this.isNegative = false,
  });

  //获取value小数点后有几位
  static int getDecimalAfterLength(String value) {
    if (value.contains(".")) {
      return value.split(".")[1].length;
    } else {
      return 0;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //上次文本
    String oldContent = oldValue.text;
    //最新文本
    String newContent = newValue.text;
    //上次文本长度
    int oldLength = oldContent.length;
    //最新文本长度
    int newLength = newContent.length;
    //上次文本光标位置
    int oldBaseOffset = oldValue.selection.baseOffset;
    //最新文本光标位置
    int newBaseOffset = newValue.selection.baseOffset;
    //光标位置
    int offset = newBaseOffset;
    if (newLength > oldLength) {
      //输入的字符
      String inputContent = newContent.substring(oldBaseOffset, newBaseOffset);
      if (!isNegative) {
        inputScope = inputScope.replaceFirst("-", "");
      }
      //复制的情况下一次性会输入多个字符
      bool containsAllChars = true;
      for (int i = 0; i < inputContent.length; i++) {
        if (!inputScope.contains(inputContent[i])) {
          containsAllChars = false;
          break;
        }
      }

      if (containsAllChars) {
        var nowValue = num.tryParse(newContent);
        if (oldLength > 0) {
          if ((maxValue != null && nowValue != null && nowValue > maxValue!) ||
              (digit != null && getDecimalAfterLength(newContent) > digit!)) {
            newContent = oldContent;
            offset = oldBaseOffset;
          } else if (oldContent.substring(0, 1) == "-") {
            //上次文本首字符是-
            if ((oldContent.contains(".") && inputContent == ".") ||
                inputContent == "-" ||
                (oldContent.contains(".") &&
                    newLength > 2 &&
                    newContent.substring(2, 3) != "." &&
                    newContent.substring(1, 2) == "0") ||
                (newLength > 2 && newContent.substring(0, 3) == "-00") ||
                (newLength > 2 &&
                    !newContent.contains(".") &&
                    newContent.substring(1, 2) == "0") ||
                (oldContent.substring(0, 1) == "-" &&
                    newContent.substring(0, 1) != "-")) {
              newContent = oldContent;
              offset = oldBaseOffset;
            }
          } else if (oldContent.substring(0, 1) == "0") {
            //上次文本首字符是0
            if (newLength > 1 && newContent.substring(0, 2) == "00" ||
                (newContent.contains("-") &&
                    newContent.substring(0, 1) != "-") ||
                (oldContent.contains(".") && inputContent == ".") ||
                (newContent.substring(0, 1) == "0" &&
                    newLength > 1 &&
                    newContent.substring(1, 2) != ".")) {
              newContent = oldContent;
              offset = oldBaseOffset;
            }
          } else if (newContent.contains(".")) {
            //上次文本首字符是.
            if ((oldLength > 1 &&
                    oldContent.substring(0, 2) == "0." &&
                    inputContent == ".") ||
                (newContent.substring(0, 1) != "-" &&
                    newContent.contains("-")) ||
                (oldContent.contains(".") && inputContent == ".") ||
                (oldContent.contains(".") &&
                    oldContent.substring(0, 1) != "." &&
                    newContent.substring(0, 1) == "0")) {
              newContent = oldContent;
              offset = oldBaseOffset;
            }
          }
        } else if ((maxValue != null &&
                nowValue != null &&
                nowValue > maxValue!) ||
            (digit != null && getDecimalAfterLength(newContent) > digit!)) {
          newContent = maxValue.toString();
        }
      } else {
        //输入限制范围外字符
        newContent = oldContent;
        offset = oldBaseOffset;
      }
    }

    return TextEditingValue(
      text: newContent,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

//有最大正整数的限制输入
class MaxIntTextInputFormatter extends TextInputFormatter {
  MaxIntTextInputFormatter({required this.maxValue, this.defaultValue = 0});
  //最大值
  num maxValue;
  //非法输入的重置展示
  int defaultValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    var newInt = int.tryParse(newValue.text);
    if (newInt == null) {
      return TextEditingValue(
        text: defaultValue.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: defaultValue.toString().length),
        ),
      );
    }
    if (newInt > maxValue) {
      return TextEditingValue(
        text: maxValue.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: maxValue.toString().length),
        ),
      );
    }
    return newValue.copyWith(text: newInt.toString());
  }
}

//输入ip地址限制
class IpTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = _formatText(newValue.text);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatText(String text) {
    final parts = text.split('.');
    if (parts.length > 4) {
      parts.removeLast();
    }
    return parts.map((part) => _formatPart(part)).join('.');
  }

  String _formatPart(String part) {
    if (part.isEmpty) {
      return '';
    }
    final value = int.parse(part);
    if (value > 255) {
      return '255';
    } else if (value < 0) {
      return '0';
    }
    return value.toString();
  }
}

//16进制输入限制
class HexInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 将输入值转换为大写字母
    String newText = newValue.text.toUpperCase();
    // 使用正则表达式匹配只包含0-9和A-F的字符
    RegExp regex = RegExp(r'^[0-9A-F]*$');
    if (regex.hasMatch(newText) || newText == "") {
      return newValue;
    } else {
      // 如果输入不符合要求，则返回旧的输入值
      return oldValue;
    }
  }
}

//针对德国键盘类型是number的时候小数点无法输入，
//此format用于此场景的输入转换
class DeNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String truncated = newValue.text;
    TextSelection newSelection = newValue.selection;
    if (newValue.text.contains(",")) {
      truncated = newValue.text.replaceFirst(RegExp(','), '.');
    }
    return TextEditingValue(text: truncated, selection: newSelection);
  }
}
