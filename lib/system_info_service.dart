import 'package:system_info2/system_info2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
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

  Future<bool> get isFlagship async {
    // Prioritize RAM check: >= 8GB is a strong flagship indicator for modern AI apps
    if (getTotalRamMB() >= 8000) return true;

    String processor = await getProcessorInfo();
    processor = processor.toLowerCase();
    
    // Broad SoC keywords representing High-Performance / Neural Engine capable chips
    final flagshipKeywords = [
      'apple a14', 'apple a15', 'apple a16', 'apple a17', 'apple a18', 
      'm1', 'm2', 'm3', 'm4',
      'snapdragon 8 ', 'sm8450', 'sm8550', 'sm8650', 'sm8750',
      'google tensor', 'gs101', 'gs201', 'gs301', 'gs401',
      'bluejay', 'cheetah', 'panther', 'lynx', 'shiba', 'husky', 'akita', 'caiman', 'komodo',
      'exynos 2200', 'exynos 2400',
      'dimensity 9000', 'dimensity 9200', 'dimensity 9300'
    ];
    
    return flagshipKeywords.any((keyword) => processor.contains(keyword));
  }

  Future<Map<String, int>> calculateSystemMetrics() async {
    final ramMB = getTotalRamMB();
    final flagship = await isFlagship;
    final processor = await getProcessorInfo();

    int maxContextTokens;
    int maxMinutes;

    final isIOS = Platform.isIOS;

    if (ramMB >= 10000 || (ramMB >= 8000 && flagship)) {
      // Ultra-Tier (10GB+ RAM or 8GB+ with Flagship SoC)
      maxContextTokens = 16384;
      maxMinutes = 60;
    } else if (ramMB >= 6000 || (isIOS && flagship)) {
      // High-Tier (6GB+ RAM or iOS Flagship)
      maxContextTokens = 8192;
      maxMinutes = 30;
    } else {
      // Standard-Tier (4GB-6GB RAM)
      maxContextTokens = 4096;
      maxMinutes = 15;
    }

    debugPrint('SystemInfo: Processor: $processor');
    debugPrint('SystemInfo: RAM: $ramMB MB, Flagship: $flagship');
    debugPrint('SystemInfo: Tiering Result: ${maxContextTokens} tokens, ${maxMinutes} mins');

    return {
      'maxContextTokens': maxContextTokens,
      'maxMinutes': maxMinutes,
    };
  }
}
