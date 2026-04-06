import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'model_downloader.dart';
import 'setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  String _selectedFormat = 'Polished Writing';
  final List<String> _formats = [
    'Polished Writing',
    'Meeting Minutes',
    'Executive Summary',
    'Email Draft',
    'Bullet Points',
  ];

  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcribedText = 'Press the microphone button to start recording. Your speech will be transcribed securely on device.';
  String _formattedText = 'Format your transcription with the local LLM. Results will appear here.';
  
  final FlutterLlama _llama = FlutterLlama.instance;
  
  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initLlama();
  }

  Future<void> _initLlama() async {
    // LLM is now lazy-loaded before generation to save memory during recording/transcription
    debugPrint('SilentScribe: LLM will be initialized when needed.');
  }

  Future<void> _lazyLoadLlama() async {
    if (_llama.isModelLoaded) return;
    
    debugPrint('SilentScribe: Lazy-loading Llama model...');
    try {
      final modelPath = await ModelDownloader.getLlamaModelPath();
      final modelFile = File(modelPath);
      if (!await modelFile.exists()) {
        debugPrint('SilentScribe: LLM Model file missing.');
        return;
      }
      
      final success = await _llama.loadModel(LlamaConfig(
        modelPath: modelPath,
        contextSize: 1024, // Reduced context for stability
        useGpu: false,     // CPU is more stable for background processing
      ));
      debugPrint('SilentScribe: Llama load success: $success');
    } catch (e) {
      debugPrint('SilentScribe: Failed lazy-loading LLM: $e');
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _llama.unloadModel();
    super.dispose();
  }

  Future<void> _processAudio(String path) async {
    setState(() {
      _isProcessing = true;
      _formattedText = 'Transcribing offline...';
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
      
      setState(() {
        _transcribedText = rawText;
        _formattedText = 'Generating $_selectedFormat...';
      });
      
      if (_transcribedText.isNotEmpty) {
        // Now that transcription is done and Whisper is finished, load Llama
        await _lazyLoadLlama();
        _generateFormattedText(_transcribedText);
      } else {
        setState(() {
          _isProcessing = false;
          _formattedText = 'Could not transcribe any dialogue. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('SilentScribe: Transcription error: $e');
      setState(() {
        _isProcessing = false;
        _formattedText = 'Error during transcription: $e';
      });
    }
  }

  String _getPromptForFormat(String format, String input) {
    String instruction;
    switch (format) {
      case 'Polished Writing':
        instruction = 'Rewrite the following rambling, disjointed voice transcription into clear, coherent, and polished text. Remove all filler words, false starts, and repetitions. Fix grammar and organize the thoughts into logical paragraphs. Preserve the original meaning, tone, and first-person perspective, making the final output read beautifully.';
        break;
      case 'Meeting Minutes':
        instruction = 'Format the following transcript into concise, professional meeting minutes. Extract key discussion points, decisions made, and action items. Present them with clear bold headings.';
        break;
      case 'Executive Summary':
        instruction = 'Provide a high-level executive summary of the following transcript. Summarize the core message in a single paragraph, followed by 3-4 key takeaways.';
        break;
      case 'Email Draft':
        instruction = 'Turn the following disjointed transcription into a professional and polite email draft. Give it a suitable Subject line and structure the body logically.';
        break;
      case 'Bullet Points':
        instruction = 'Distill the following transcription into a clear list of organized bullet points, capturing all the main ideas seamlessly.';
        break;
      default:
        instruction = 'Rewrite the transcription into clear, polished text.';
    }

    return '<|im_start|>system\nYou are an expert copywriter and editor. Your task is to accurately organize and format transcriptions.<|im_end|>\n<|im_start|>user\n$instruction\n\nTranscription:\n"""\n$input\n"""<|im_end|>\n<|im_start|>assistant\n';
  }

  Future<void> _generateFormattedText(String input) async {
    if (!_llama.isModelLoaded) {
      setState(() {
        _isProcessing = false;
        _formattedText = 'Local LLM not loaded.';
      });
      return;
    }
    
    setState(() {
       _formattedText = '';
    });
    
    final prompt = _getPromptForFormat(_selectedFormat, input);
    
    try {
      final params = GenerationParams(
        prompt: prompt,
        maxTokens: 512,
        temperature: 0.7,
      );
      
      await for (final token in _llama.generateStream(params)) {
        setState(() {
          _formattedText += token;
        });
      }
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
       setState(() {
         _isProcessing = false;
         _formattedText = 'Generation error: $e';
       });
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
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });
        debugPrint('SilentScribe: Recording stopped. Path: $path');
        if (path != null) {
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
          });
          debugPrint('SilentScribe: Recording started at $path');
        } else {
          debugPrint('SilentScribe: Permission DENIED.');
        }
      }
    } catch (e) {
      debugPrint('SilentScribe: Error toggling recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('SilentScribe', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormatSelector(theme),
              const SizedBox(height: 24),
              Expanded(
                child: _buildOutputArea(theme),
              ),
              const SizedBox(height: 24),
              // Main recording button
              Center(
                child: FloatingActionButton.large(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFormat,
          isExpanded: true,
          items: _formats.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFormat = newValue;
              });
            }
          },
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
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Original'),
                Tab(text: 'Formatted'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Text(
                      _transcribedText,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Text(
                      _formattedText,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingControls(ThemeData theme) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleRecording,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isProcessing 
                ? theme.colorScheme.surfaceContainerHighest
                : _isRecording 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _isProcessing 
                ? const Center(child: CircularProgressIndicator())
                : Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 40,
                    color: _isRecording ? theme.colorScheme.onError : theme.colorScheme.onPrimaryContainer,
                  ),
          ),
        ),
      ),
    );
  }
}
