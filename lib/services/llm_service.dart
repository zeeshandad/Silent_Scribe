import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_llama/flutter_llama.dart';
import '../model_downloader.dart';

class LLMService {
  final FlutterLlama _llama = FlutterLlama.instance;
  bool _isInitialized = false;

  Future<void> ensureModelLoaded() async {
    if (_llama.isModelLoaded) return;

    debugPrint('LLMService: Loading Llama model...');
    final modelPath = await ModelDownloader.getLlamaModelPath();
    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      throw Exception('LLM Model file missing.');
    }

    final success = await _llama.loadModel(LlamaConfig(
      modelPath: modelPath,
      contextSize: 1024,
      useGpu: false,
    ));
    
    if (!success) {
      throw Exception('Failed to load LLM model.');
    }
    _isInitialized = true;
  }

  Future<void> unloadModel() async {
    // NOTE: Calling _llama.unloadModel() triggers EXC_BAD_ACCESS in the native
    // llama_model destructor (flutter_llama plugin bug). The model is kept
    // resident for the app lifetime; iOS will reclaim memory on app termination.
    _isInitialized = false;
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

    final cleanInput = input.replaceAll('<|im_end|>', '').replaceAll('"""', "'''");
    final prompt = getPromptForFormat(format, cleanInput);

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
