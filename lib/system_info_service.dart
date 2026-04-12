import 'package:system_info2/system_info2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SystemInfoService {
  int getTotalRamMB() {
    if (Platform.isIOS) return 4096; // iOS workaround
    try {
      return SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024);
    } catch (_) {
      return 4096;
    }
  }

  int getFreeRamMB() {
    if (Platform.isIOS) return 2048; // iOS workaround
    try {
      return SysInfo.getFreePhysicalMemory() ~/ (1024 * 1024);
    } catch (_) {
      return 2048;
    }
  }

  Future<String> getProcessorInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.hardware;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return 'Unknown';
  }
}
