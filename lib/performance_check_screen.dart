import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'system_info_service.dart';

class PerformanceCheckScreen extends StatefulWidget {
  final VoidCallback onPassed;
  final SystemInfoService? systemInfoService;

  const PerformanceCheckScreen({
    super.key, 
    required this.onPassed,
    this.systemInfoService,
  });

  @override
  State<PerformanceCheckScreen> createState() => _PerformanceCheckScreenState();
}

class _PerformanceCheckScreenState extends State<PerformanceCheckScreen> {
  late final SystemInfoService _systemInfo;
  String _statusMessage = 'Optimizing for your device...';
  String _detailMessage = 'Running privacy compatibility check.';
  double _progress = 0.0;
  bool _isChecking = true;
  bool _failed = false;
  String? _failureReason;
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    _systemInfo = widget.systemInfoService ?? SystemInfoService();
    _runAudit();
  }

  Future<void> _runAudit() async {
    setState(() {
      _isChecking = true;
      _progress = 0.1;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Visual polish

    // 1. Check RAM
    final totalRamMB = _systemInfo.getTotalRamMB();
    final freeRamMB = _systemInfo.getFreeRamMB();
    
    debugPrint('PerformanceCheck: Total RAM: $totalRamMB MB, Free RAM: $freeRamMB MB');
    
    setState(() {
      _progress = 0.4;
      _detailMessage = 'Auditing system memory...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. Processor / SoC
    String processorInfo = await _systemInfo.getProcessorInfo();

    setState(() {
      _progress = 0.7;
      _detailMessage = 'Checking processor architecture...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Logic & Branching
    // Failure: < 3.5GB RAM (often reported as slightly less than 4GB due to system reserved)
    if (totalRamMB < 3500) {
      setState(() {
        _failed = true;
        _isChecking = false;
        _statusMessage = 'Incompatible Device';
        _failureReason = 'We\'re sorry. SilentScribe performs 100% offline computations for privacy, and requires at least 4GB of RAM. Your device ($totalRamMB MB RAM) does not meet these requirements.';
      });
      return;
    }

    // Warning: < 6GB RAM (Whisper + Llama might be tight)
    if (totalRamMB < 5500) {
      _isWarning = true;
    }

    setState(() {
      _progress = 1.0;
      _detailMessage = 'Compatibility check complete.';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isWarning) {
      setState(() {
        _isChecking = false;
        _progress = 1.0;
      });
      _showWarningDialog();
    } else {
      setState(() {
        _isChecking = false;
        _progress = 1.0;
      });
      _complete();
    }
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Calculate and save dynamic metrics for this specific device
    final metrics = await _systemInfo.calculateSystemMetrics();
    await prefs.setInt('max_context_tokens', metrics['maxContextTokens']!);
    await prefs.setInt('max_recording_minutes', metrics['maxMinutes']!);
    
    await prefs.setBool('performance_check_complete', true);
    widget.onPassed();
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Device Performance Note'),
        content: const Text('Your device has limited RAM. Large transcriptions may be slow or cause crashes. SilentScribe will still work, but performance may be reduced.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _complete();
            },
            child: const Text('Understand & Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_failed) ...[
                Icon(Icons.error_outline_rounded, size: 80, color: theme.colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _failureReason ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ] else if (!_isChecking) ...[
                Icon(
                  _isWarning ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
                  size: 80, 
                  color: _isWarning ? Colors.orange : theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _isWarning ? 'Ready with Notes' : 'Optimized!',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _isWarning 
                    ? 'Your device is ready, but performance may be limited.'
                    : 'Your device is ready for offline transcription.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ] else ...[
                const SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  _detailMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _progress,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
