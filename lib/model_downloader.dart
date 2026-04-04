import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class ModelDownloader {
  static const String whisperModelUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin';
  static const String llamaModelUrl = 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf';

  static const String whisperFileName = 'ggml-tiny.en.bin';
  static const String llamaFileName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf';

  static Future<bool> areModelsDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final whisperFile = File(p.join(dir.path, whisperFileName));
    final llamaFile = File(p.join(dir.path, llamaFileName));

    return await whisperFile.exists() && await llamaFile.exists();
  }

  static Future<String> getWhisperModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, whisperFileName);
  }

  static Future<String> getLlamaModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, llamaFileName);
  }

  static Future<void> downloadModels(void Function(double) onProgress) async {
    final dir = await getApplicationDocumentsDirectory();

    final whisperFile = File(p.join(dir.path, whisperFileName));
    if (!await whisperFile.exists()) {
      await _downloadFile(whisperModelUrl, whisperFile, (p) => onProgress(p * 0.2)); 
    }

    final llamaFile = File(p.join(dir.path, llamaFileName));
    if (!await llamaFile.exists()) {
      await _downloadFile(llamaModelUrl, llamaFile, (p) => onProgress(0.2 + (p * 0.8)));
    }
    
    onProgress(1.0);
  }

  static Future<void> _downloadFile(String url, File file, void Function(double) onProgress) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      final contentLength = response.contentLength ?? 1;

      int downloaded = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        onProgress(downloaded / contentLength);
      }

      await sink.close();
    } catch (e) {
      debugPrint('Error downloading model: $e');
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }
}
