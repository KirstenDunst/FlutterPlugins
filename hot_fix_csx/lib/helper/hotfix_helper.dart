/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:37:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 14:21:14
 * @Description: 
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/error_helper.dart';
import 'package:hot_fix_csx/model/config_model.dart';
import 'package:hot_fix_csx/operation/check_resource_op.dart';
import 'package:hot_fix_csx/operation/compare_md5_op.dart';
import 'package:hot_fix_csx/operation/download_op.dart';
import 'package:hot_fix_csx/operation/path_op.dart';
import 'download_helper.dart';
import 'file_system_helper.dart';
import 'log_helper.dart';
import 'zip_helper.dart';

class HotFixHelper {
  /// 进行资源包处理
  static Future startHotFix() async {
    await DownloadOp.instance.getJsonUrlContent();
    unawaited(ConfigHelp.instance.updateHotfixTime());
    var result = await CompareMd5Op.compareMd5(
        ConfigHelp.instance.manifestNetModel.bundleManifestChecksum,
        PathOp.instance.currentManifestPath());
    if (!result) {
      //增量下载
      await _startDiffDownloadOperation();
    }
  }

  /// 开始增量下载
  static Future _startDiffDownloadOperation() async {
    if (await DownloadOp.instance.downloadFile(
        await DownloadHelper.getDiffUrl(),
        PathOp.instance.diffDownloadFilePath())) {
      //合并操作
      var patchResult = await ZipHelper.patchResource();
      LogHelper.instance.logInfo('增量合并完成---result:$patchResult');
      //清理diff，否则会影响下次下载
      FileSystemHelper.clearLastDiff();
      //对比操作zip文件的md5
      var result = await CompareMd5Op.compareMd5(
          ConfigHelp.instance.manifestNetModel.bundleArchiveChecksum,
          PathOp.instance.makeupZipFilePath());
      if (result) {
        //增量合并zip和配置文件md5一致
        //解压缩zip文件
        var success = await _unarchiveZip(false);
        if (success) {
          ConfigHelp.instance.refreshStreamController.sink.add(null);
          //清理将要不用的文件，防止影响新文件生成
          await FileSystemHelper.clearLastZip();
          await FileSystemHelper.mvMakeZipToLastZip();
          LogHelper.instance.logInfo('增量更新完成');
        } else {
          readyTotalDownloadOperation(false);
        }
      } else {
        readyTotalDownloadOperation(false);
      }
    } else {
      //增量包下载失败的话，全量下载
      readyTotalDownloadOperation(false);
    }
  }

  /// 校验资源完备
  /// integrityType 资源完备性校验的排次类型
  static Future<bool> checkRecource(
      {bool onlyCheck = false, bool isAgain = false}) async {
    var resourceDirect = PathOp.instance.currentValidResourceBasePath();
    var result = await _onlyCheckRecource(resourceDirect);
    if (result.checkIsComplete) {
      return true;
    } else {
      LogHelper.instance.logInfo('资源完备性校验失败:${result.checkError}');
      return onlyCheck
          ? false
          : await _dealCheckIntegrityResourceType(isAgain: isAgain);
    }
  }

  static Future<CheckResultModel> _onlyCheckRecource(String resDirect) async {
    var path = resDirect + '/${ConfigHelp.instance.resourceModel.unzipDirName}';
    var value =
        await File('$path/${Constant.hotfixResourceListFile}').readAsString();
    if (value.isNotEmpty) {
      try {
        var manifestJson = json.decode(value);
        var result =
            await CheckResourceOp.checkResourceFull(manifestJson, path);
        return result;
      } catch (e) {
        return CheckResultModel(
            checkIsComplete: false, checkError: ArgumentError.value(e));
      }
    }
    return CheckResultModel(
        checkIsComplete: false,
        checkError:
            ErrorHelper.errorWithType(HotFixErrorType.resourceListInvalid));
  }

  /// 资源不完整的处理方案
  /// return 资源是否可用
  static Future<bool> _dealCheckIntegrityResourceType(
      {bool isAgain = false}) async {
    var latestFileExist = await FileSystemHelper.isExistsFile(
        PathOp.instance.latestZipFilePath());
    if (latestFileExist && !isAgain) {
      //重新解压一次上一次的结果，并刷新页面，然后进行再一次异步校验
      await _unarchiveZip(true);
      ConfigHelp.instance.refreshStreamController.sink.add(null);
      var result = await checkRecource(isAgain: true);
      return result;
    } else {
      readyTotalDownloadOperation(true);
      return false;
    }
  }

  /// 解压缩最新资源包资源
  /// isTotalZip 是否是全量zip，否则是增量的合成包
  static Future<bool> _unarchiveZip(bool isTotalZip) async {
    var result = await _unarchiveZipPathAndType();
    var isSuccess = false;
    if (isTotalZip) {
      isSuccess = await ZipHelper.unZipFile(
          PathOp.instance.latestZipFilePath(), result.dirName);
    } else {
      isSuccess = await ZipHelper.unZipFile(
          PathOp.instance.makeupZipFilePath(), result.dirName);
    }
    if (isSuccess) {
      //解压成功
      //同步校验完整性
      var answer = await _onlyCheckRecource(result.dirName);
      if (answer.checkIsComplete) {
        ConfigHelp.instance.updateAvailableResourceType(result.preRecourceType);
      } else {
        //校验完整性失败，清除无效解压文件
        await Directory(result.dirName).delete(recursive: true);
        isSuccess = false;
      }
    } else {
      //异常处理，解压失败
      await Directory(PathOp.instance.fixtempDirectoryPath())
          .rename(result.dirName);
    }
    if (await Directory(PathOp.instance.fixtempDirectoryPath()).exists()) {
      await Directory(PathOp.instance.fixtempDirectoryPath())
          .delete(recursive: true);
    }
    return isSuccess;
  }

  static Future<UnArchiveModel> _unarchiveZipPathAndType() async {
    String dirName;
    HotFixValidResource preRecourceType;
    // fix和fixtmp文件相互替换，每次的热更新合成包或者全量包都会交替循环的使用这两个文件夹
    if (ConfigHelp.instance.configModel.currentValidResourceType ==
        HotFixValidResource.fix) {
      dirName = Constant.hotfixFixTmpResourceDirName;
      preRecourceType = HotFixValidResource.fixTmp;
    } else {
      dirName = Constant.hotfixFixResourceDirName;
      preRecourceType = HotFixValidResource.fix;
    }
    if (await Directory(dirName).exists()) {
      await Directory(dirName).rename(Constant.hotfixFixTempResourceDirName);
    }
    var path = PathOp.instance.baseDirectory + '/$dirName';
    return UnArchiveModel(dirName: path, preRecourceType: preRecourceType);
  }

  /// 全量下载
  static Future readyTotalDownloadOperation(bool needlLatest) async {
    if (needlLatest) {
      var result = await DownloadOp.instance.getJsonUrlContent();
      if (!result) {
        LogHelper.instance.logInfo('全量下载更新云端配置文件失败');
        return;
      }
    }
    //获取全量下载地址
    var fullResourceZipUrl =
        ConfigHelp.instance.manifestNetModel.entireBundleUrl;
    if (fullResourceZipUrl.isEmpty) {
      //无下载地址，异常结束
      LogHelper.instance.logInfo('云端json配置无全量包下载地址');
    } else {
      await _startTotalDownloadOperation(fullResourceZipUrl);
    }
  }

  /// 开始全量下载操作，这是一个操作集合
  static Future _startTotalDownloadOperation(String loadUrl) async {
    if (await DownloadOp.instance
        .downloadFile(loadUrl, PathOp.instance.totalDownloadFilePath())) {
      if (await CompareMd5Op.compareMd5(
          ConfigHelp.instance.manifestNetModel.bundleArchiveChecksum,
          PathOp.instance.totalDownloadFilePath())) {
        await FileSystemHelper.mvTotalZipToLastZip();
        await _unarchiveZip(true);
        //全量zip解压完成--
        ConfigHelp.instance.refreshStreamController.sink.add(null);
        LogHelper.instance.logInfo('全量更新完成');
      } else {
        LogHelper.instance
            .logInfo('code error please check and reUpload,全量包md5文件云端配置不一致');
      }
    }
  }
}
