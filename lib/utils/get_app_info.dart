import 'package:package_info_plus/package_info_plus.dart';

Future<Map<String, String>> getAppInfo() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  return {'version': version, 'buildNumber': buildNumber};
}
