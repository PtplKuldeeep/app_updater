import 'dart:io';
import 'dart:math' as math;

import 'package:app_updater/constants/app_consts.dart';
import 'package:app_updater/extensions/string_ext.dart';
import 'package:app_updater/functions/update_fun.dart';
import 'package:app_updater/functions/version_check.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';

class AppUpdater {
  final String appversion;
  final String dirName;
  final bool isLiveApk;

  AppUpdater({
    required this.dirName,
    required this.appversion,
    required this.isLiveApk,
  });

  AppFile appFile = AppFile();
  bool _checkedStatus = false;

  Future<bool> checkAppUpdate() async {
    appFile.serverappDir = dirName;
    if (appFile.localappDir.isEmpty) {
      appFile.localappDir = (await getApplicationSupportDirectory()).path;
    }
    if (!appFile.canupdate) {
      appFile = await _checkUpdate(
          dirName: dirName, localversion: appversion, isLiveApk: isLiveApk);
    }

    if (!appFile.canupdate) {
      final prefile = File(appFile.appDirPath);

      if (await prefile.exists()) {
        await prefile.delete();
      }
    }

    if (appFile.latestversion.isNotEmpty) {
      _checkedStatus = true;
    }
    return appFile.canupdate;
  }

  downloadLatestApp({
    Future<bool> Function()? onUpdateAvailable,
  }) async {
    if (!_checkedStatus) {
      await checkAppUpdate();
    }
    if (!appFile.canupdate) return;
    if (onUpdateAvailable != null) {
      if (!await onUpdateAvailable()) return;
    }
    appFile.serverappDir = dirName;
    final ds = await _downloadFileByUrl(appFile: appFile);

    if (ds.downStatus) {
      await ds.appDirPath.openFile;
    }
  }
}

Future<AppFile> _downloadFileByUrl({
  required AppFile appFile,
}) async {
  final ctrl = Get.put(AppUpdaterCtrl());
  ctrl.appFile = appFile;
  Dio dio = Dio();
  showAppDownloadDialogue(ctrl: ctrl);

  try {
    if (appFile.localappDir.isEmpty) {
      appFile.localappDir = (await getApplicationDocumentsDirectory()).path;
    }

    final file = File(appFile.appDirPath);

    var response = await dio.get(
      appFile.appPathURL,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: 0,
        validateStatus: (status) => true,
      ),
      onReceiveProgress: (count, total) {
        if (total > 1000) {
          ctrl.showdownload.value = true;
          ctrl.filesize = total;
          ctrl.dowloadpercent.value = count / total;
        }
      },
    );
    final rufffile = file.openSync(mode: FileMode.write);
    rufffile.writeFromSync(response.data);
    await rufffile.close();
    appFile.downStatus = true;
  } on DioError catch (e) {
    appFile.downStatus = false;
    appFile.errorMsj = e.toString();

    debugPrint("downloadFileByUrl : $e");
  }

  ctrl.showdownload.value = true;
  hideAppDownloadDialogue();
  return appFile;
}

Future<AppFile> _checkUpdate(
    {required String dirName,
    required String localversion,
    required bool isLiveApk}) async {
  AppFile appFile = AppFile();
  try {
    Dio dio = Dio();
    final response = await dio
        .get(
          [hostPath, dirName, "LatestApp.json"].join("/"),
          options: Options(
            responseType: ResponseType.json,
            followRedirects: false,
            receiveTimeout: 3000,
            validateStatus: (status) => true,
          ),
        )
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => Response(
              requestOptions: RequestOptions(
            path: "",
          )),
        );
    if (response.statusCode == 200) {
      appFile.latestversion =
          response.data[isLiveApk ? "live_latestversion" : "latestversion"] ??
              "0.0.0";
      appFile.appname =
          response.data[isLiveApk ? "live_appname" : "appname"] ?? "";
      appFile.appTitle = isLiveApk
          ? (response.data["live_apptitle"] ?? response.data["apptitle"])
          : response.data["apptitle"] ?? "";
      appFile.canupdate = localversion.updateAvailable(appFile.latestversion);
    }
  } on DioError {
    appFile.canupdate = false;
  }

  return appFile;
}

String formatBytes({required num bytes, int decimals = 1}) {
  if (bytes == 0) {
    return '0 B';
  }

  const k = 1024;
  final dm = decimals < 0 ? 0 : decimals;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  int i = math.log(bytes) ~/ math.log(k);
  final pow = math.pow(k, i);
  return '${(bytes / pow).toStringAsFixed(dm)} ${sizes[i]}';
}

extension KdAppUpdaterNumExt on num {
  String get shortSize => formatBytes(bytes: this);
}

class AppFile {
  AppFile({
    this.downStatus = false,
    this.canupdate = false,
    this.filePath = '',
    this.errorMsj = '',
    this.latestversion = '',
    this.appname = '',
    this.appTitle = '',
    this.localappDir = '',
    this.serverappDir = '',
  });

  bool downStatus;
  bool canupdate;
  String filePath;
  String latestversion;
  String appname;
  String appTitle;
  String localappDir;

  String errorMsj;
  String serverappDir;
  String get appDirPath => "$localappDir/$appname";
  String get appPathURL => [hostPath, serverappDir, appname].join("/");
}
