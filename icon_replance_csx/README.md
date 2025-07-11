# icon_replance_csx

A new Flutter plugin project.

## Getting Started

iOS 接入项目
建议使用 flutter_launcher_icons 生成icon比较便捷，
生成icon系列图标的名称（不能重复）

配置项目 在build setting里配置Include All App Icon Assets为YES，debug/release都需要设为yes，




## 使用
```dart
IconReplanceCsx().changeIcon('icon1');

/// 如果需要隐藏iOS系统的替换弹窗提示，可以在替换代码前执行
IconReplanceCsx().removeSysAlert();
```
