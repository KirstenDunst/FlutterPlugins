import 'dart:io';

import 'package:doraemonkit_csx/utils/shared_prefer_util.dart';

import '../apm.dart';
import '../common/common.dart';
import '../kit.dart';
import 'resident_page.dart';

class KitPageManager {
  KitPageManager._privateConstructor();

  static const String kitAll = '全部';
  static const String keyKitPageCache = 'key_kit_page_cache';
  List<String> residentList = <String>[ApmKitName.kitHttp, ApmKitName.kitLog];

  static final KitPageManager _instance = KitPageManager._privateConstructor();

  static KitPageManager get instance => _instance;

  String listToString(List<String>? list) {
    if (list == null || list.isEmpty) {
      return '';
    }
    String? result;
    for (final item in list) {
      if (result == null) {
        result = item;
      } else {
        result = '$result,$item';
      }
    }

    return result.toString();
  }

  bool addResidentKit(String? tag) {
    assert(tag != null);
    if (!residentList.contains(tag)) {
      if (residentList.length >= 4) {
        return false;
      }
      residentList.add(tag!);
      SPService.instance.set(keyKitPageCache, listToString(residentList));
      return true;
    }
    return false;
  }

  bool removeResidentKit(String tag) {
    if (residentList.contains(tag)) {
      residentList.remove(tag);
      SPService.instance.set(keyKitPageCache, listToString(residentList));
      return true;
    }
    return false;
  }

  Map<String, IKit> getBaseKit() {
    final kits = <String, IKit>{};
    CommonKitManager.instance.kitMap.forEach((String key, CommonKit value) {
      if (!residentList.contains(key)) {
        if (key == CommonKitName.kitBaseSetting) {
          if (!Platform.isAndroid) {
            kits[key] = value;
          }
        } else if ([
          CommonKitName.kitBaseDevoptions,
          CommonKitName.kitBaseLanguage
        ].contains(key)) {
          if (Platform.isAndroid) {
            kits[key] = value;
          }
        } else {
          kits[key] = value;
        }
      }
    });
    return kits;
  }

  Map<String, IKit> getApmKit() {
    final kits = <String, IKit>{};
    ApmKitManager.instance.kitMap.forEach((String key, ApmKit value) {
      if (!residentList.contains(key)) {
        kits[key] = value;
      }
    });
    return kits;
  }

  Map<String, IKit> getVisualKit() {
    final kits = <String, IKit>{};
    // VisualKitManager.instance.kitMap.forEach((String key, IKit value) {
    //   if (!residentList.contains(key)) {
    //     kits[key] = value;
    //   }
    // });
    return kits;
  }

  Map<String, IKit> getResidentKit() {
    final kits = <String, IKit>{};
    for (final element in residentList) {
      if (ApmKitManager.instance.getKit(element) != null) {
        kits[element] = ApmKitManager.instance.getKit(element)!;
      }
      // else if (VisualKitManager.instance.getKit(element) != null) {
      //   kits[element] = VisualKitManager.instance.getKit(element)!;
      // }
      else if (CommonKitManager.instance.getKit(element) != null) {
        kits[element] = CommonKitManager.instance.getKit(element)!;
      }
    }
    return kits;
  }

  void loadCache() {
    SPService.instance
        .containsKey(KitPageManager.keyKitPageCache)
        .then((contain) async {
      if (contain) {
        var pageCache =
            await SPService.instance.get(KitPageManager.keyKitPageCache, '');
        if (pageCache == '') {
          KitPageManager.instance.residentList = <String>[];
        } else {
          KitPageManager.instance.residentList = pageCache.split(',');
        }
      }
      if (KitPageManager.instance.residentList.isNotEmpty) {
        ResidentPage.tag = KitPageManager.instance.residentList.first;
      } else {
        ResidentPage.tag = KitPageManager.kitAll;
      }
    });
  }
}
