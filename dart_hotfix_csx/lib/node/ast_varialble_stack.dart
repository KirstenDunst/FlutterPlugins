/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:23:43
 * @Description: 
 */
/// 标识变量类型
enum AstVariableType {
  ///基础数据类型
  base,

  ///函数
  function,
}

class AstVariableStack {
  final List<Map<String, AstVarialbleModel>> _stack = [];

  ///进入代码块的时候调用，新建一个变量集并压栈
  void blockIn() {
    _stack.add({});
  }

  ///跳出代码块的时候调用，将栈顶的变量集出栈
  void blockOut() {
    _stack.removeLast();
  }

  ///获取基础数据变量值，考虑变量赋值的情况，通过返回类结构模拟引用变量
  AstVarialbleModel? getVariableValue(String name) {
    ///从栈顶开始遍历，直到找到目标变量
    for (var i = _stack.length; i > 0; i--) {
      var top = _stack[i - 1];
      if (top.containsKey(name)) {
        var variableModel = top[name];
        if (variableModel != null &&
            variableModel._variableType == AstVariableType.base) {
          return variableModel;
        }
      }
    }
    return null;
  }

  T? getFunctionInstance<T>(String name) {
    ///从栈顶开始遍历，直到找到目标方法
    for (var i = _stack.length; i > 0; i--) {
      var top = _stack[i - 1];
      if (top.containsKey(name)) {
        var variableModel = top[name];
        if (variableModel != null &&
            variableModel._variableType == AstVariableType.function &&
            variableModel.value is T) {
          return variableModel.value;
        }
      }
    }
    return null;
  }

  ///设置变量值
  void setVariableValue(String name, dynamic value) {
    assert(_stack.isNotEmpty);

    ///从栈顶开始遍历，直到找到目标变量，赋值后跳出循环
    for (var i = _stack.length; i > 0; i--) {
      var top = _stack[i - 1];
      if (top.containsKey(name)) {
        top[name] = AstVarialbleModel(AstVariableType.base, value);
        return;
      }
    }
    //如果没有目标变量，则将该变量存入变量栈
    _stack.last[name] = AstVarialbleModel(AstVariableType.base, value);
  }

  ///设置函数值
  void setFunctionInstance<T>(String name, T instance) {
    assert(_stack.isNotEmpty);
    _stack.last[name] = AstVarialbleModel(AstVariableType.function, instance);
  }
}

class AstVarialbleModel {
  final AstVariableType _variableType;
  dynamic value;
  AstVarialbleModel(this._variableType, this.value);
}
