class VersionInfo {
  final PlatformVersion android;
  final PlatformVersion ios;
  bool?  isForceUpdate = false;

  VersionInfo({
    required this.android,
    required this.ios,
    this.isForceUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      android: PlatformVersion.fromJson(json['android']),
      ios: PlatformVersion.fromJson(json['ios']),
      isForceUpdate: json['isForceUpdate']??false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'android': android.toJson(),
      'ios': ios.toJson(),
    };
  }
}

class PlatformVersion {
  final String version;
  final String buildNumber;

  PlatformVersion({
    required this.version,
    required this.buildNumber,
  });

  factory PlatformVersion.fromJson(Map<String, dynamic> json) {
    return PlatformVersion(
      version: json['version'],
      buildNumber: json['buildNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
    };
  }
}
