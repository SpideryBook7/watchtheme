import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceType() async {
  // Web does not support androidInfo and will crash.
  if (kIsWeb) {
    return 'mobile';
  }

  final deviceInfo = DeviceInfoPlugin();

  try {
    // This throws on iOS/Windows/Linux/MacOS
    final androidInfo = await deviceInfo.androidInfo;

    final model = androidInfo.model.toLowerCase();
    final features = androidInfo.systemFeatures;

    if (model.contains('tv') ||
        features.contains('android.software.leanback')) {
      return 'tv';
    } else if (model.contains('wear') ||
        features.contains('android.hardware.type.watch')) {
      return 'wear';
    }
  } catch (e) {
    // If we are not on Android (e.g. iOS), default to mobile.
    return 'mobile';
  }

  return 'mobile';
}
