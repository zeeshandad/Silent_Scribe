import 'package:isar/isar.dart';

part 'transcription_entry.g.dart';

@collection
class TranscriptionEntry {
  Id id = Isar.autoIncrement;

  late String rawTranscript;
  late String formattedText;
  late DateTime timestamp;
  late String selectedStyle;
  String? audioFilePath;

  // Searchable index
  @Index(type: IndexType.value)
  List<String> get searchWords {
    return [
      ...rawTranscript.toLowerCase().split(RegExp(r'\s+')),
      ...formattedText.toLowerCase().split(RegExp(r'\s+')),
    ];
  }
}
