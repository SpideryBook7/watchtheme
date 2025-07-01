import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceType() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  final model = androidInfo.model.toLowerCase();
  final features = androidInfo.systemFeatures;

  if (model.contains('tv') || features.contains('android.software.leanback')) {
    return 'tv';
  } else if (model.contains('wear') || features.contains('android.hardware.type.watch')) {
    return 'wear';
  } else {
    return 'mobile';
  }
}
