extension KdVersionCheckStrExt on String {
  int compareVersion(String serverversion) =>
      versionchecker(this, serverversion);
  bool updateAvailable(String serverversion) =>
      compareVersion(serverversion) == 1;
}

int versionchecker(String localversion, String serverversion) {
  //  localversion = "1.0.0";
  //  serverversion = "1.0.8";
  // -1 local version is latest than server
  // 0 local version is up to date
  // 1 local version need update
  final local = localversion.replaceAll(_filerRegex, "");
  final server = serverversion.replaceAll(_filerRegex, "");

  if (!_versionRegex.hasMatch(local) || !_versionRegex.hasMatch(server)) {
    return 0;
  }

  _AppVersion localappV = _AppVersion.fromStr(local);
  _AppVersion latestappV = _AppVersion.fromStr(server);
  return _versioncompare(localappV, latestappV);
}

class _AppVersion {
  _AppVersion({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
  });

  int major;
  int minor;
  int patch;

  factory _AppVersion.fromStr(String version) {
    List<int> data =
        version.split(".").map((e) => int.tryParse(e) ?? 0).toList();
    final len = data.length;

    return _AppVersion(
      major: len > 0 ? data[0] : 0,
      minor: len > 1 ? data[1] : 0,
      patch: len > 2 ? data[2] : 0,
    );
  }
}

int _versioncompare(
  _AppVersion local,
  _AppVersion server,
) {
  if (server.major > local.major) return 1;
  if (server.major < local.major) return -1;

  if (server.minor > local.minor) return 1;
  if (server.minor < local.minor) return -1;

  if (server.patch > local.patch) return 1;
  if (server.patch < local.patch) return -1;

  return 0;
}

final RegExp _versionRegex = RegExp(r"[0-9]{1,7}.{1}[0-9]{1,7}.?[0-9]{0,5}");
final RegExp _filerRegex = RegExp(r"[^0-9.]");
