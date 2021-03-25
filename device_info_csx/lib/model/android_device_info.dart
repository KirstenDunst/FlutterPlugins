import 'num_util.dart';

/// Information derived from `android.os.Build`.
///
/// See: https://developer.android.com/reference/android/os/Build.html
class AndroidDeviceInfo {
  /// Android device Info class.
  AndroidDeviceInfo({
    required this.version,
    required this.board,
    required this.bootloader,
    required this.brand,
    required this.device,
    required this.display,
    required this.fingerprint,
    required this.hardware,
    required this.host,
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.product,
    required List<String> supported32BitAbis,
    required List<String> supported64BitAbis,
    required List<String> supportedAbis,
    required this.tags,
    required this.type,
    required this.isPhysicalDevice,
    required this.androidId,
    required List<String> systemFeatures,
    required this.storage,
  })   : supported32BitAbis = List<String>.unmodifiable(supported32BitAbis),
        supported64BitAbis = List<String>.unmodifiable(supported64BitAbis),
        supportedAbis = List<String>.unmodifiable(supportedAbis),
        systemFeatures = List<String>.unmodifiable(systemFeatures);

  /// Android operating system version values derived from `android.os.Build.VERSION`.
  final AndroidBuildVersion version;

  /// The name of the underlying board, like "goldfish".
  final String board;

  /// The system bootloader version number.
  final String bootloader;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  final String brand;

  /// The name of the industrial design.
  final String device;

  /// A build ID string meant for displaying to the user.
  final String display;

  /// A string that uniquely identifies this build.
  final String fingerprint;

  /// The name of the hardware (from the kernel command line or /proc).
  final String hardware;

  /// Hostname.
  final String host;

  /// Either a changelist number, or a label like "M4-rc20".
  final String id;

  /// The manufacturer of the product/hardware.
  final String manufacturer;

  /// The end-user-visible name for the end product.
  final String model;

  /// The name of the overall product.
  final String product;

  /// An ordered list of 32 bit ABIs supported by this device.
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  final List<String> supportedAbis;

  /// Comma-separated tags describing the build, like "unsigned,debug".
  final String tags;

  /// The type of build, like "user" or "eng".
  final String type;

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// The Android hardware device ID that is unique between the device + user and app signing.
  final String androidId;

  /// Describes what features are available on the current device.
  ///
  /// This can be used to check if the device has, for example, a front-facing
  /// camera, or a touchscreen. However, in many cases this is not the best
  /// API to use. For example, if you are interested in bluetooth, this API
  /// can tell you if the device has a bluetooth radio, but it cannot tell you
  /// if bluetooth is currently enabled, or if you have been granted the
  /// necessary permissions to use it. Please *only* use this if there is no
  /// other way to determine if a feature is supported.
  ///
  /// This data comes from Android's PackageManager.getSystemAvailableFeatures,
  /// and many of the common feature strings to look for are available in
  /// PackageManager's public documentation:
  /// https://developer.android.com/reference/android/content/pm/PackageManager
  final List<String> systemFeatures;

  /// device storage detail.
  final AndroidStorage storage;

  /// Deserializes from the message received from [_kChannel].
  static AndroidDeviceInfo fromMap(Map<String, dynamic> map) {
    return AndroidDeviceInfo(
      version: AndroidBuildVersion._fromMap(map['version'] != null
          ? map['version'].cast<String, dynamic>()
          : <String, dynamic>{}),
      board: map['board'] ?? '',
      bootloader: map['bootloader'] ?? '',
      brand: map['brand'] ?? '',
      device: map['device'] ?? '',
      display: map['display'] ?? '',
      fingerprint: map['fingerprint'] ?? '',
      hardware: map['hardware'] ?? '',
      host: map['host'] ?? '',
      id: map['id'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      model: map['model'] ?? '',
      product: map['product'] ?? '',
      supported32BitAbis: _fromList(map['supported32BitAbis']),
      supported64BitAbis: _fromList(map['supported64BitAbis']),
      supportedAbis: _fromList(map['supportedAbis']),
      tags: map['tags'] ?? '',
      type: map['type'] ?? '',
      isPhysicalDevice: map['isPhysicalDevice'] ?? false,
      androidId: map['androidId'] ?? '',
      systemFeatures: _fromList(map['systemFeatures']),
      storage: AndroidStorage._fromMap(map['storage'] != null
          ? map['storage'].cast<String, dynamic>()
          : <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['version'] = version.toJson();
    data['board'] = board;
    data['bootloader'] = bootloader;
    data['brand'] = brand;
    data['device'] = device;
    data['display'] = display;
    data['fingerprint'] = fingerprint;
    data['hardware'] = hardware;
    data['host'] = host;
    data['id'] = id;
    data['manufacturer'] = manufacturer;
    data['model'] = model;
    data['product'] = product;
    data['supported32BitAbis'] = supported32BitAbis;
    data['supported64BitAbis'] = supported64BitAbis;
    data['supportedAbis'] = supportedAbis;
    data['tags'] = tags;
    data['type'] = type;
    data['isPhysicalDevice'] = isPhysicalDevice;
    data['androidId'] = androidId;
    data['systemFeatures'] = systemFeatures;
    data['storage'] = storage.toJson();
    return data;
  }

  /// Deserializes message as List<String>
  static List<String> _fromList(dynamic message) {
    if (message == null) {
      return <String>[];
    }
    assert(message is List<dynamic>);
    final List<dynamic> list = List<dynamic>.from(message)
      ..removeWhere((value) => value == null);
    return list.cast<String>();
  }
}

/// Version values of the current Android operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class AndroidBuildVersion {
  AndroidBuildVersion._({
    this.baseOS,
    this.previewSdkInt,
    this.securityPatch,
    required this.codename,
    required this.incremental,
    required this.release,
    required this.sdkInt,
  });

  /// The base OS build the product is based on.
  /// This is only available on Android 6.0 or above.
  String? baseOS;

  /// The developer preview revision of a prerelease SDK.
  /// This is only available on Android 6.0 or above.
  int? previewSdkInt;

  /// The user-visible security patch level.
  /// This is only available on Android 6.0 or above.
  final String? securityPatch;

  /// The current development codename, or the string "REL" if this is a release build.
  final String codename;

  /// The internal value used by the underlying source control to represent this build.
  final String incremental;

  /// The user-visible version string.
  final String release;

  /// The user-visible SDK version of the framework.
  ///
  /// Possible values are defined in: https://developer.android.com/reference/android/os/Build.VERSION_CODES.html
  final int sdkInt;

  /// Deserializes from the map message received from [_kChannel].
  static AndroidBuildVersion _fromMap(Map<String, dynamic> map) {
    return AndroidBuildVersion._(
      baseOS: map['baseOS'],
      previewSdkInt: map['previewSdkInt'],
      securityPatch: map['securityPatch'],
      codename: map['codename'] ?? '',
      incremental: map['incremental'] ?? '',
      release: map['release'] ?? '',
      sdkInt: map['sdkInt'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['baseOS'] = baseOS;
    data['previewSdkInt'] = previewSdkInt;
    data['securityPatch'] = securityPatch;
    data['codename'] = codename;
    data['incremental'] = incremental;
    data['release'] = release;
    data['sdkInt'] = sdkInt;
    return data;
  }
}

class AndroidStorage {
  /// 应用进程占内存总大小
  final num totalPssB;

  /// summary开头字段都是Android 23 及以后能获取
  ///java 内存
  final num summaryJavaHeap;

  ///native 内存
  final num summaryNativeHeap;

  ///静态代码，资源内存
  final num summaryCode;

  ///栈内存
  final num summaryStack;

  ///显存
  final num summaryGraphics;

  ///其他私有内存
  final num summaryPrivateOther;

  ///系统内存
  final num summarySystem;

  ///总 swap 内存
  final num summaryTotalSwap;

  /// 已使用的ram，单位byte
  final num ramUseB;

  /// 全部的ram容量，单位byte
  final num ramAllB;

  /// 可用ram容量小于此值时，系统开始清理进程
  final num ramThreshold;

  /// 设备空闲内存,ramAvailableB = ramAllB - ramUseB
  final num ramAvailableB;

  /// 是否低内存
  final bool lowMemory;

  /// 已使用的rom，单位byte
  final num romUseB;

  /// 全部的rom容量，单位byte
  final num romAllB;

  /// 虚拟机已使用内存
  final num jvmUseB;

  /// 当前虚拟机可用的最大内存
  final num jvmMaxB;

  /// 当前虚拟机已分配的内存
  final num jvmTotalB;

  /// 当前虚拟机已分配内存中未使用的部分
  final num jvmFreeB;

  AndroidStorage({
    required this.totalPssB,
    required this.summaryJavaHeap,
    required this.summaryNativeHeap,
    required this.summaryCode,
    required this.summaryStack,
    required this.summaryGraphics,
    required this.summaryPrivateOther,
    required this.summarySystem,
    required this.summaryTotalSwap,
    required this.ramUseB,
    required this.ramAllB,
    required this.ramThreshold,
    required this.ramAvailableB,
    required this.lowMemory,
    required this.romUseB,
    required this.romAllB,
    required this.jvmUseB,
    required this.jvmMaxB,
    required this.jvmTotalB,
    required this.jvmFreeB,
  });

  static AndroidStorage _fromMap(Map<String, dynamic> map) {
    return AndroidStorage(
      totalPssB: map['totalPssB'] ?? 0,
      summaryJavaHeap: map['summaryJavaHeap'] ?? 0,
      summaryNativeHeap: map['summaryNativeHeap'] ?? 0,
      summaryCode: map['summaryCode'] ?? 0,
      summaryStack: map['summaryStack'] ?? 0,
      summaryGraphics: map['summaryGraphics'] ?? 0,
      summaryPrivateOther: map['summaryPrivateOther'] ?? 0,
      summarySystem: map['summarySystem'] ?? 0,
      summaryTotalSwap: map['summaryTotalSwap'] ?? 0,
      ramUseB: map['ramUseB'] ?? 0,
      ramAllB: map['ramAllB'] ?? 0,
      ramThreshold: map['ramThreshold'] ?? 0,
      ramAvailableB: map['ramAvailableB'] ?? 0,
      lowMemory: map['lowMemory'] ?? false,
      romUseB: map['romUseB'] ?? 0,
      romAllB: map['romAllB'] ?? 0,
      jvmUseB: map['jvmUseB'] ?? 0,
      jvmMaxB: map['jvmMaxB'] ?? 0,
      jvmTotalB: map['jvmTotalB'] ?? 0,
      jvmFreeB: map['jvmFreeB'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['totalPssB'] = totalPssB;
    data['summaryJavaHeap'] = summaryJavaHeap;
    data['summaryNativeHeap'] = summaryNativeHeap;
    data['summaryCode'] = summaryCode;
    data['summaryStack'] = summaryStack;
    data['summaryGraphics'] = summaryGraphics;
    data['summaryPrivateOther'] = summaryPrivateOther;
    data['summarySystem'] = summarySystem;
    data['summaryTotalSwap'] = summaryTotalSwap;
    data['ramUseB'] = ramUseB;
    data['ramAllB'] = ramAllB;
    data['ramThreshold'] = ramThreshold;
    data['ramAvailableB'] = ramAvailableB;
    data['lowMemory'] = lowMemory;
    data['romUseB'] = romUseB;
    data['romAllB'] = romAllB;
    data['jvmUseB'] = jvmUseB;
    data['jvmMaxB'] = jvmMaxB;
    data['jvmTotalB'] = jvmTotalB;
    data['jvmFreeB'] = jvmFreeB;
    return data;
  }

  @override
  String toString() {
    return 'AndroidStorage{单位(Byte) 进程占内存总大小: ${totalPssB.sizeFormat()}, '
        '其中:native内存:${summaryNativeHeap.sizeFormat()},系统内存:${summarySystem.sizeFormat()},总 swap 内存:${summaryTotalSwap.sizeFormat()},显存:${summaryGraphics.sizeFormat()},'
        'java 内存:${summaryJavaHeap.sizeFormat()},其他私有内存:${summaryPrivateOther.sizeFormat()},静态代码、资源内存:${summaryCode.sizeFormat()},栈内存:${summaryStack.sizeFormat()}, '
        '已使用的RAM: ${ramUseB.sizeFormat()}, 全部的RAM容量: ${ramAllB.sizeFormat()}, 可用RAM容量清理阈值: ${ramThreshold.sizeFormat()}, 设备空闲RAM: ${ramAvailableB.sizeFormat()}, lowMemory: $lowMemory, '
        '已使用的ROM: ${romUseB.sizeFormat()}, 全部的ROM容量: ${romAllB.sizeFormat()}, '
        '虚拟机已使用内存: ${jvmUseB.sizeFormat()}, 当前虚拟机可用的最大内存: ${jvmMaxB.sizeFormat()}, 当前虚拟机已分配的内存: ${jvmTotalB.sizeFormat()}, 当前虚拟机已分配内存中未使用的部分: ${jvmFreeB.sizeFormat()}}';
  }
}
