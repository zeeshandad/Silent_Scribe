import 'package:system_info2/system_info2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SystemInfoService {
  int getTotalRamMB() {
    return SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024);
  }

  int getFreeRamMB() {
    return SysInfo.getFreePhysicalMemory() ~/ (1024 * 1024);
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
