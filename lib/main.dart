import 'package:flutter/material.dart';
import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'model_downloader.dart';
import 'system_info_service.dart';
import 'setup_screen.dart';
import 'performance_check_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository/transcription_repository.dart';
import 'models/transcription_entry.dart';
import 'screens/library_screen.dart';
import 'screens/transcription_detail_screen.dart';
import 'services/sharing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TranscriptionRepository.init();
  runApp(const SilentScribeApp());
}

class SilentScribeApp extends StatefulWidget {
  const SilentScribeApp({super.key});

  @override
  State<SilentScribeApp> createState() => _SilentScribeAppState();
}

class _SilentScribeAppState extends State<SilentScribeApp> {
  bool _isLoading = true;
  bool _modelsReady = false;
  bool _performanceChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay to ensure native plugins are definitely ready to handle channels.
      Future.delayed(const Duration(milliseconds: 500), _checkModels);
    });
  }

  Future<void> _checkModels() async {
    debugPrint('SilentScribe: Starting _checkModels()...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final performanceChecked = prefs.getBool('performance_check_complete') ?? false;

      debugPrint('SilentScribe: Calling areModelsDownloaded()...');
      // Adding a timeout for areModelsDownloaded() call.
      final ready = await ModelDownloader.areModelsDownloaded().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('SilentScribe: areModelsDownloaded() timed out.');
          return false;
        },
      );
      debugPrint('SilentScribe: areModelsDownloaded() returned: $ready');
      setState(() {
        _modelsReady = ready;
        _performanceChecked = performanceChecked;
        _isLoading = false;
      });
      debugPrint('SilentScribe: _checkModels() completed successfully.');
    } catch (e) {
      debugPrint('SilentScribe: Error in _checkModels(): $e');
      setState(() {
        _isLoading = false;
        _modelsReady = false; 
      });
    } finally {
      // Ensure we eventually stop showing the spinner even if something weird happens.
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentScribe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: _isLoading 
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text('Initializing SilentScribe...'),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = false;
                        });
                      }, 
                      child: const Text('Taking too long? Tap here.')
                    )
                  ],
                ),
              ),
            )
          : !_performanceChecked
              ? PerformanceCheckScreen(
                  onPassed: () {
                    setState(() {
                      _performanceChecked = true;
                    });
                  },
                )
              : _modelsReady 
                  ? const TranscriptionScreen()
                  : SetupScreen(
                      onSetupComplete: () {
                        setState(() {
                          _modelsReady = true;
                        });
                      },
                    ),
    );
  }
}

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcribedText = 'Press the microphone button to start recording. Your speech will be transcribed securely on device.';
  String? _lastRecordedPath;
  
  // Dynamic recording limit variables
  int _maxMinutes = 60;
  Timer? _recordingTimer;
  Duration _elapsedTime = Duration.zero;
  
  
  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _loadDeviceLimits();
  }

  Future<void> _loadDeviceLimits() async {
    final prefs = await SharedPreferences.getInstance();
    int? maxMinutes = prefs.getInt('max_recording_minutes');
    int? maxTokens = prefs.getInt('max_context_tokens');

    bool v4Stable = prefs.getBool('v4_metrics_stable') ?? false;

    // Force re-calculation for the v4 stability build (Updated Memory Tiers)
    if (maxMinutes == null || maxTokens == null || !v4Stable) {
      debugPrint('SilentScribe: Re-calculating stable dynamic limits (v4)...');
      final metrics = await SystemInfoService().calculateSystemMetrics();
      maxMinutes = metrics['maxMinutes']!;
      maxTokens = metrics['maxContextTokens']!;
      
      // Save them securely
      await prefs.setInt('max_context_tokens', maxTokens);
      await prefs.setInt('max_recording_minutes', maxMinutes);
      await prefs.setBool('v4_metrics_stable', true);
    }

    if (mounted) {
      setState(() {
        _maxMinutes = maxMinutes!;
      });
    }
  }

  Future<void> _initLlama() async {
    // LLM is now lazy-loaded before generation to save memory 
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _processAudio(String path) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final whisperPath = await ModelDownloader.getWhisperModelPath();
      final whisper = Whisper(model: WhisperModel.tiny);
      final response = await whisper.transcribe(
        modelPath: whisperPath,
        transcribeRequest: TranscribeRequest(audio: path),
      );
      final rawText = response.text;
      debugPrint('SilentScribe: Transcription complete: ${rawText.length} chars');
      
      if (rawText.isNotEmpty) {
        setState(() {
          _transcribedText = rawText;
          _isProcessing = false;
        });
        final entry = await _saveToHistory(rawText);
        if (mounted && entry != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TranscriptionDetailScreen(entry: entry),
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
          _transcribedText = 'Could not transcribe any dialogue. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('SilentScribe: Transcription error: $e');
      setState(() {
        _isProcessing = false;
        _transcribedText = 'Error during transcription: $e';
      });
    }
  }


  Future<TranscriptionEntry?> _saveToHistory(String text) async {
    try {
      final entry = TranscriptionEntry()
        ..rawTranscript = text
        ..formattedText = ''
        ..timestamp = DateTime.now()
        ..selectedStyle = 'Polished Writing'
        ..audioFilePath = _lastRecordedPath;
      
      final id = await TranscriptionRepository().saveEntry(entry);
      entry.id = id;
      debugPrint('SilentScribe: Saved to history (ID: $id).');
      return entry;
    } catch (e) {
      debugPrint('SilentScribe: Failed to save to history: $e');
      return null;
    }
  }

  Future<void> _toggleRecording() async {
    debugPrint('SilentScribe: _toggleRecording called. isRecording: $_isRecording, isProcessing: $_isProcessing');
    if (_isProcessing) {
      debugPrint('SilentScribe: Still processing, ignoring tap.');
      return;
    }
    try {
      if (_isRecording) {
        debugPrint('SilentScribe: Stopping recording...');
        _recordingTimer?.cancel();
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });
        debugPrint('SilentScribe: Recording stopped. Path: $path');
        if (path != null) {
          _lastRecordedPath = path;
          _processAudio(path);
        }
      } else {
        debugPrint('SilentScribe: Checking permissions...');
        if (await _audioRecorder.hasPermission()) {
          debugPrint('SilentScribe: Permission granted. Starting recording...');
          final directory = await getTemporaryDirectory();
          final path = '${directory.path}/recording_temp.wav';
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 16000, 
              numChannels: 1,
            ),
            path: path,
          );
          
          setState(() {
            _isRecording = true;
            _elapsedTime = Duration.zero;
          });
          
          _startTimer();
          
          debugPrint('SilentScribe: Recording started at $path');
        } else {
          debugPrint('SilentScribe: Permission DENIED.');
        }
      }
    } catch (e) {
      debugPrint('SilentScribe: Error toggling recording: $e');
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = Duration(seconds: timer.tick);
        });
        
        // Automated enforcement of dynamic limit
        if (_elapsedTime.inMinutes >= _maxMinutes) {
          _toggleRecording();
          _showLimitReachedNotification();
        }
      }
    });
  }

  void _showLimitReachedNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto-stop: Device specific recording limit of $_maxMinutes mins reached.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('SilentScribe', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LibraryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildOutputArea(theme),
              ),
              const SizedBox(height: 24),
              // Main recording area with limit indicator and timer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isRecording) 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '${_formatDuration(_elapsedTime)} / $_maxMinutes:00',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  FloatingActionButton.large(
                    onPressed: _toggleRecording,
                    backgroundColor: _isProcessing 
                      ? theme.colorScheme.surfaceContainerHighest
                      : _isRecording 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.primaryContainer,
                    child: _isProcessing 
                        ? const CircularProgressIndicator()
                        : Icon(
                            _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 48,
                            color: _isRecording ? theme.colorScheme.onError : theme.colorScheme.onPrimaryContainer,
                          ),
                  ),
                  if (!_isRecording && !_isProcessing) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded, 
                          size: 14, 
                          color: theme.colorScheme.primary.withOpacity(0.8)
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Optimized for your device: $_maxMinutes min limit',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildOutputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.text_snippet_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Transcription',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _transcribedText,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
