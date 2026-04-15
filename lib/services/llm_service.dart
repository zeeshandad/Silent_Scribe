import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model_downloader.dart';
import '../system_info_service.dart';

enum PerformanceLevel { legacy, balanced, ultra }

class LLMService {
  final FlutterLlama _llama = FlutterLlama.instance;
  final SystemInfoService _systemInfoService = SystemInfoService();
  bool _isInitialized = false;

  // Strict Mutual Exclusion lock for model loading
  bool _isLocking = false;
  Future<void> _waitForLock() async {
    while (_isLocking) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _isLocking = true;
  }
  
  void _releaseLock() {
    _isLocking = false;
  }

  Future<PerformanceLevel> _getPerformanceLevel() async {
    int ram = _systemInfoService.getTotalRamMB();
    bool flagship = await _systemInfoService.isFlagship;
    bool isIOS = Platform.isIOS;
    
    if (ram >= 10000 || (ram >= 8000 && flagship)) return PerformanceLevel.ultra;
    if (ram >= 6000 || (isIOS && flagship)) return PerformanceLevel.balanced;
    return PerformanceLevel.legacy;
  }

  Future<LlamaConfig> _getOptimalComputeConfig(PerformanceLevel level, String modelPath) async {
    int ram = _systemInfoService.getTotalRamMB();
    bool flagship = await _systemInfoService.isFlagship;

    // Minimum 6GB for Android GPU, iOS handles Metal universally.
    bool useGpu = Platform.isIOS || (ram >= 6000 && flagship);
    
    // Optimize thread affinity: Legacy relies entirely on CPU, prioritize higher threads.
    int nThreads = level == PerformanceLevel.legacy ? 4 : 2; 
    int nGpuLayers = useGpu ? -1 : 0;

    // Load device-specific context tokens calculated during audit
    final prefs = await SharedPreferences.getInstance();
    final contextSize = prefs.getInt('max_context_tokens') ?? 16384;
    
    // Decouple batchSize from contextSize to prevent OOM on mobile. 512 is a safe standard.
    int batchSize = 512;
    
    debugPrint('LLMService: Initializing with contextSize: $contextSize, batchSize: $batchSize, useGpu: $useGpu');
    
    return LlamaConfig(
      modelPath: modelPath,
      contextSize: contextSize,
      batchSize: batchSize,
      useGpu: useGpu,
      nThreads: nThreads,
      nGpuLayers: nGpuLayers,
    );
  }

  Future<void> ensureModelLoaded() async {
    await _waitForLock();
    try {
      if (_llama.isModelLoaded) return;

      debugPrint('LLMService: Loading Llama model...');
      final modelPath = await ModelDownloader.getLlamaModelPath();
      final modelFile = File(modelPath);
      if (!await modelFile.exists()) {
        throw Exception('LLM Model file missing.');
      }

      final performanceLevel = await _getPerformanceLevel();
      final config = await _getOptimalComputeConfig(performanceLevel, modelPath);

      final success = await _llama.loadModel(config);
      
      if (!success) {
        throw Exception('Failed to load LLM model.');
      }
      _isInitialized = true;
    } finally {
      _releaseLock();
    }
  }

  Future<void> unloadModel() async {
    await _waitForLock();
    try {
      if (_isInitialized) {
        // try {
        //   await _llama.unloadModel();
        // } catch (_) {
        //   // Ignore known native plugin destruct crash if it surfaces here.
        // }
        _isInitialized = false;
      }
    } finally {
      _releaseLock();
    }
  }

  String getPromptForFormat(String format, String input) {
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

    return '<|im_start|>system\nYou are an expert copywriter and editor. Your task is to accurately organize and format transcriptions. Output the formatted text directly. Stop immediately after completing the request.<|im_end|>\n<|im_start|>user\n$instruction\n\nTranscription:\n"""\n$input\n"""<|im_end|>\n<|im_start|>assistant\n';
  }

    Stream<String> generateFormattedTextStream(String input, String format) async* {
    await ensureModelLoaded();

    // Load context size to determine safe truncation limit
    final prefs = await SharedPreferences.getInstance();
    final contextSize = prefs.getInt('max_context_tokens') ?? 4096;

    final cleanInput = input.replaceAll('<|im_end|>', '').replaceAll('"""', "'''");
    
    // Safety Truncation: 1.5 chars per token for high-density, 2.5 for balanced.
    // Increased to a more generous limit now that batchSize alignment is resolved.
    final int safeCharLimit = ((contextSize - 512) * 2.5).floor();
    
    String finalInput = cleanInput;
    if (cleanInput.length > safeCharLimit) {
      debugPrint('LLMService: Input too long (${cleanInput.length} chars). Truncating to $safeCharLimit chars for stability.');
      finalInput = cleanInput.substring(0, safeCharLimit);
    }

    final prompt = getPromptForFormat(format, finalInput);
    debugPrint('LLMService: Final prompt length: ${prompt.length} characters.');

    final params = GenerationParams(
      prompt: prompt,
      maxTokens: 512,
      temperature: 0.7,
    );

    await for (final token in _llama.generateStream(params)) {
      if (token.contains('<|im_end|>')) {
        yield token.split('<|im_end|>')[0];
        break;
      }
      yield token;
    }
    // Model stays loaded — unloadModel() is a no-op to avoid native crash.
  }
}
