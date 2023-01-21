import 'package:app_updater/constants/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

extension KdAppUpdaterSTRExt on String {
  /// converting string to Text widget in Regular font family
  Text textbodyregular({
    Color? color,
    double? size,
    int? maxlines,
    Key? key,
  }) {
    return Text(
      this,
      softWrap: true,
      key: key,
      maxLines: maxlines,
      style: TextStyle(
        fontSize: size ?? 12,
        color: color ?? kdblack,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// converting string to Text widget in Semi bold font family
  Text textbodySemiBold({
    Color? color,
    double? size,
    int? maxlines,
    Key? key,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      softWrap: true,
      key: key,
      maxLines: maxlines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size ?? 12,
        color: color ?? kdblack,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<OpenResult> get openFile async {
    try {
      return await OpenFile.open(this);
    } catch (e) {
      return OpenResult(
        type: ResultType.error,
        message: "error",
      );
    }
  }
}
