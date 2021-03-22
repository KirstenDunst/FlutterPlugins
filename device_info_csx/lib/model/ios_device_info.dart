/*
 * @Author: Cao Shixin
 * @Date: 2020-12-31 04:27:56
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 11:47:53
 * @Description: 
 */

/// Information derived from `UIDevice`.
///
/// See: https://developer.apple.com/documentation/uikit/uidevice
class IosDeviceInfo {
  /// IOS device info class.
  IosDeviceInfo({
    this.name,
    this.systemName,
    this.systemVersion,
    this.model,
    this.localizedModel,
    this.identifierForVendor,
    this.isPhysicalDevice,
    this.utsname,
    this.storage,
  });

  /// Device name.
  final String? name;

  /// The name of the current operating system.
  final String? systemName;

  /// The current operating system version.
  final String? systemVersion;

  /// Device model.
  final String? model;

  /// Localized name of the device model.
  final String? localizedModel;

  /// Unique UUID value identifying the current device.
  final String? identifierForVendor;

  /// `false` if the application is running in a simulator, `true` otherwise.
  final bool? isPhysicalDevice;

  /// Operating system information derived from `sys/utsname.h`.
  final IosUtsname? utsname;

  /// device storage detail.
  final Storage? storage;

  /// Deserializes from the map message received from [_kChannel].
  static IosDeviceInfo fromMap(Map<String, dynamic> map) {
    return IosDeviceInfo(
      name: map['name'],
      systemName: map['systemName'],
      systemVersion: map['systemVersion'],
      model: map['model'],
      localizedModel: map['localizedModel'],
      identifierForVendor: map['identifierForVendor'],
      isPhysicalDevice: map['isPhysicalDevice'] == 'true',
      utsname: IosUtsname._fromMap(map['utsname'].cast<String, dynamic>()),
      storage: Storage._fromMap(map['storage'].cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['name'] = name;
    data['systemName'] = systemName;
    data['systemVersion'] = systemVersion;
    data['model'] = model;
    data['localizedModel'] = localizedModel;
    data['identifierForVendor'] = identifierForVendor;
    data['isPhysicalDevice'] = isPhysicalDevice;
    data['utsname'] = utsname!.toJson();
    data['storage'] = storage!.toJson();
    return data;
  }
}

/// Information derived from `utsname`.
/// See http://pubs.opengroup.org/onlinepubs/7908799/xsh/sysutsname.h.html for details.
class IosUtsname {
  IosUtsname._({
    this.sysname,
    this.nodename,
    this.release,
    this.version,
    this.machine,
  });

  /// Operating system name.
  final String? sysname;

  /// Network node name.
  final String? nodename;

  /// Release level.
  final String? release;

  /// Version level.
  final String? version;

  /// Hardware type (e.g. 'iPhone7,1' for iPhone 6 Plus).
  final String? machine;

  /// Deserializes from the map message received from [_kChannel].
  static IosUtsname _fromMap(Map<String, dynamic> map) {
    return IosUtsname._(
      sysname: map['sysname'],
      nodename: map['nodename'],
      release: map['release'],
      version: map['version'],
      machine: map['machine'],
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['sysname'] = sysname;
    data['nodename'] = nodename;
    data['release'] = release;
    data['version'] = version;
    data['machine'] = machine;
    return data;
  }
}

class Storage {
  // 已使用的ram，单位byte
  num? ramUseB;
  // 全部的ram容量，单位byte
  num? ramAllB;
  // 已使用的rom，单位byte
  num? romUseB;
  // 全部的rom容量，单位byte
  num? romAllB;

  Storage({
    this.ramUseB,
    this.ramAllB,
    this.romUseB,
    this.romAllB,
  });

  static Storage _fromMap(Map<String, dynamic> map) {
    return Storage(
      ramUseB: map['ramUseB'],
      ramAllB: map['ramAllB'],
      romUseB: map['romUseB'],
      romAllB: map['romAllB'],
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['ramUseB'] = ramUseB;
    data['ramAllB'] = ramAllB;
    data['romUseB'] = romUseB;
    data['romAllB'] = romAllB;
    return data;
  }
}
