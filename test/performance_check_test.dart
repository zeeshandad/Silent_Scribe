import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silent_scribe/performance_check_screen.dart';
import 'package:silent_scribe/system_info_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSystemInfoService extends SystemInfoService {
  final int mockTotalRam;
  final int mockFreeRam;
  final String mockProcessor;

  MockSystemInfoService({
    required this.mockTotalRam,
    required this.mockFreeRam,
    this.mockProcessor = 'Snapdragon 8 Gen 2',
  });

  @override
  int getTotalRamMB() => mockTotalRam;

  @override
  int getFreeRamMB() => mockFreeRam;

  @override
  Future<String> getProcessorInfo() async => mockProcessor;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PerformanceCheckScreen shows failure for low-end device', (WidgetTester tester) async {
    // Mock 2GB RAM (below 3.5GB threshold)
    final mockService = MockSystemInfoService(mockTotalRam: 2048, mockFreeRam: 512);

    await tester.pumpWidget(MaterialApp(
      home: PerformanceCheckScreen(
        onPassed: () {},
        systemInfoService: mockService,
      ),
    ));

    // Wait for the audit to complete (includes several 600-800ms delays)
    await tester.pump(const Duration(seconds: 1)); // Delay 800ms
    await tester.pump(const Duration(seconds: 1)); // Delay 600ms
    await tester.pump(const Duration(seconds: 1)); // Delay 600ms
    await tester.pumpAndSettle();

    expect(find.text('Incompatible Device'), findsOneWidget);
    expect(find.textContaining('requires at least 4GB of RAM'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('PerformanceCheckScreen passes for high-end device', (WidgetTester tester) async {
    // Mock 8GB RAM
    final mockService = MockSystemInfoService(mockTotalRam: 8192, mockFreeRam: 4096);
    bool passed = false;

    await tester.pumpWidget(MaterialApp(
      home: PerformanceCheckScreen(
        onPassed: () {
          passed = true;
        },
        systemInfoService: mockService,
      ),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(passed, isTrue);
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('performance_check_complete'), isTrue);
  });

  testWidgets('PerformanceCheckScreen shows warning for mid-range device', (WidgetTester tester) async {
    // Mock 4GB RAM (between 3.5GB and 5.5GB warning threshold)
    final mockService = MockSystemInfoService(mockTotalRam: 4096, mockFreeRam: 1024);
    bool passed = false;

    await tester.pumpWidget(MaterialApp(
      home: PerformanceCheckScreen(
        onPassed: () {
          passed = true;
        },
        systemInfoService: mockService,
      ),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Should show dialog
    expect(find.text('Device Performance Note'), findsOneWidget);
    expect(find.textContaining('Your device has limited RAM'), findsOneWidget);

    // Tap proceed
    await tester.tap(find.text('Understand & Proceed'));
    await tester.pumpAndSettle();

    expect(passed, isTrue);
  });
}
