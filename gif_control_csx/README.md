<!--
 * @Author: Cao Shixin
 * @Date: 2023-04-13 17:21:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-04-14 11:20:30
 * @Description: 
-->

# gif_control_csx

用于flutter 对gif的控制，

## 使用示例
```Dart
    controller1 = GifController(vsync: this);
    controller2 = GifController(vsync: this);
    controller4 = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller1.repeat(
          min: 0, max: 53, period: const Duration(milliseconds: 200));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller2.repeat(
          min: 0, max: 13, period: const Duration(milliseconds: 200));
      controller4.repeat(
          min: 0, max: 13, period: const Duration(milliseconds: 200));
    });
    controller3 = GifController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200));
...
...
GifImageCsx(
    controller: controller1,
    image: const AssetImage("images/animate.gif"),
),
const Text("网络"),
GifImageCsx(
    controller: controller2,
    image: const NetworkImage(
        "http://img.mp.itc.cn/upload/20161107/5cad975eee9e4b45ae9d3c1238ccf91e.jpg"),
),
const Text("内存"),
GifImageCsx(
    controller: controller4,
    image: MemoryImage(base64Decode(base64_url)
    ),
)
```

