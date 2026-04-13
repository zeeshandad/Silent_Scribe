import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transcription_entry.dart';

class TranscriptionRepository {
  static late Isar _isar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TranscriptionEntrySchema],
      directory: dir.path,
    );
    _initialized = true;
  }

  Future<List<TranscriptionEntry>> getAllEntries({int offset = 0, int limit = 20}) async {
    return await _isar.transcriptionEntrys
        .where()
        .sortByTimestampDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<TranscriptionEntry>> searchEntries(String query, {int offset = 0, int limit = 20}) async {
    if (query.isEmpty) return getAllEntries(offset: offset, limit: limit);
    
    return await _isar.transcriptionEntrys
        .filter()
        .rawTranscriptContains(query, caseSensitive: false)
        .or()
        .formattedTextContains(query, caseSensitive: false)
        .sortByTimestampDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<int> saveEntry(TranscriptionEntry entry) async {
    return await _isar.writeTxn(() async {
      return await _isar.transcriptionEntrys.put(entry);
    });
  }

  Future<bool> deleteEntry(Id id) async {
    return await _isar.writeTxn(() async {
      return await _isar.transcriptionEntrys.delete(id);
    });
  }

  Future<TranscriptionEntry?> getEntry(Id id) async {
    return await _isar.transcriptionEntrys.get(id);
  }
}
