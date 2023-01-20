import 'package:app_updater/constants/app_consts.dart';
import 'package:app_updater/extensions/string_ext.dart';
import 'package:app_updater/updater/app_updater_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showAppDownloadDialogue({required AppUpdaterCtrl ctrl}) {
  if (_isdownloading) return;
  ctrl.showdownload.value = false;
  ctrl.dowloadpercent.value = 0;
  Get.dialog(
    _UpdateApp(
      ctrl: ctrl,
    ),
    barrierDismissible: false,
  );
}

hideAppDownloadDialogue() {
  if (!_isdownloading) return;
  Get.back();
}

class _UpdateApp extends StatelessWidget {
  final AppUpdaterCtrl ctrl;
  const _UpdateApp({
    Key? key,
    required this.ctrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (ctrl.showdownload.value) {
          return false;
        }
        return true;
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin:
              EdgeInsets.symmetric(vertical: Get.height * 0.3, horizontal: 10),
          height: 160,
          width: Get.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: kdwhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              "App Update".textbodySemiBold(
                size: 18,
                color: Get.theme.primaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              "New version of ${ctrl.appFile.appTitle} is available. Please install ${ctrl.appFile.appname} new version ${ctrl.appFile.latestversion} for latest feature."
                  .textbodyregular(
                size: 14,
                maxlines: 5,
              ),
              const SizedBox(
                height: 40,
              ),
              Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        (ctrl.filesize * ctrl.dowloadpercent.value)
                            .shortSize
                            .textbodyregular(
                              color: Get.theme.primaryColor,
                            ),
                        const Spacer(),
                        (ctrl.filesize).shortSize.textbodyregular(
                              color: Get.theme.primaryColor,
                            ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    LinearProgressIndicator(
                      backgroundColor: Get.theme.primaryColor.withOpacity(0.3),
                      value: (ctrl.dowloadpercent.value == 0 ||
                              ctrl.dowloadpercent.value == 1)
                          ? null
                          : ctrl.dowloadpercent.value,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    "Downloading...".textbodyregular(
                      color: Get.theme.primaryColor,
                      size: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isdownloading = false;

class AppUpdaterCtrl extends GetxController {
  var dowloadpercent = (0.0).obs;
  var showdownload = false.obs;
  int filesize = 0;
  AppFile appFile = AppFile();

  set isdownloading(bool val) => _isdownloading = val;
}
