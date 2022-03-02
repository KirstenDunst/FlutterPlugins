/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 09:00:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-01 15:58:33
 * @Description: 
 */

class ManifestNetModel {
  String bundleArchiveChecksum;
  String bundleManifestChecksum;
  String? bundlePlatform;
  String? bundleType;
  String? desc;
  String entireBundleUrl;
  bool? forceUpdate;
  String patchRootUrl;
  String? version;
  ManifestNetModel(
      this.bundleArchiveChecksum,
      this.bundleManifestChecksum,
      this.bundlePlatform,
      this.bundleType,
      this.desc,
      this.entireBundleUrl,
      this.forceUpdate,
      this.patchRootUrl,
      this.version);

  factory ManifestNetModel.fromJson(Map<String, dynamic> json) =>
      ManifestNetModel(
        json['bundleArchiveChecksum'] as String,
        json['bundleManifestChecksum'] as String,
        json['bundlePlatform'] as String?,
        json['bundleType'] as String?,
        json['desc'] as String?,
        json['entireBundleUrl'] as String,
        json['forceUpdate'] as bool?,
        json['patchRootUrl'] as String,
        json['version'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bundleArchiveChecksum': bundleArchiveChecksum,
        'bundleManifestChecksum': bundleManifestChecksum,
        'bundlePlatform': bundlePlatform,
        'bundleType': bundleType,
        'desc': desc,
        'entireBundleUrl': entireBundleUrl,
        'forceUpdate': forceUpdate,
        'patchRootUrl': patchRootUrl,
        'version': version,
      };
}
