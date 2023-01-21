import 'package:app_updater/app_updater.dart';
import 'package:app_updater/updater/app_updater_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    AppUpdater appUpdater = AppUpdater(dirName: "spnf", appversion: "1.0.0");

    await appUpdater.checkAppUpdate();

    appUpdater.downloadLatestApp();
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
