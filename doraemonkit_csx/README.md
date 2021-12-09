
# doraemonkit_csx
Doraemonkit的flutter版本，用于开发自检工具。

## Getting Started
```
import 'package:doraemonkit_csx/doraemonkit_csx.dart';

void main() {
  DoKit.runApp(
    app: DoKitApp(MyApp()),
    useInRelease: true,
    logCallback: (log) {
      String i = log;
    },
    exceptionCallback: (obj, trace) {
      print('ttt$obj');
    },
  );
}
```