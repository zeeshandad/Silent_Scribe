// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranscriptionEntryCollection on Isar {
  IsarCollection<TranscriptionEntry> get transcriptionEntrys =>
      this.collection();
}

const TranscriptionEntrySchema = CollectionSchema(
  name: r'TranscriptionEntry',
  id: 3721183978667788913,
  properties: {
    r'audioFilePath': PropertySchema(
      id: 0,
      name: r'audioFilePath',
      type: IsarType.string,
    ),
    r'formattedText': PropertySchema(
      id: 1,
      name: r'formattedText',
      type: IsarType.string,
    ),
    r'rawTranscript': PropertySchema(
      id: 2,
      name: r'rawTranscript',
      type: IsarType.string,
    ),
    r'searchWords': PropertySchema(
      id: 3,
      name: r'searchWords',
      type: IsarType.stringList,
    ),
    r'selectedStyle': PropertySchema(
      id: 4,
      name: r'selectedStyle',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _transcriptionEntryEstimateSize,
  serialize: _transcriptionEntrySerialize,
  deserialize: _transcriptionEntryDeserialize,
  deserializeProp: _transcriptionEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'searchWords': IndexSchema(
      id: -8223905966804274419,
      name: r'searchWords',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchWords',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _transcriptionEntryGetId,
  getLinks: _transcriptionEntryGetLinks,
  attach: _transcriptionEntryAttach,
  version: '3.1.0+1',
);

int _transcriptionEntryEstimateSize(
  TranscriptionEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.audioFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.formattedText.length * 3;
  bytesCount += 3 + object.rawTranscript.length * 3;
  bytesCount += 3 + object.searchWords.length * 3;
  {
    for (var i = 0; i < object.searchWords.length; i++) {
      final value = object.searchWords[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedStyle.length * 3;
  return bytesCount;
}

void _transcriptionEntrySerialize(
  TranscriptionEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audioFilePath);
  writer.writeString(offsets[1], object.formattedText);
  writer.writeString(offsets[2], object.rawTranscript);
  writer.writeStringList(offsets[3], object.searchWords);
  writer.writeString(offsets[4], object.selectedStyle);
  writer.writeDateTime(offsets[5], object.timestamp);
}

TranscriptionEntry _transcriptionEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranscriptionEntry();
  object.audioFilePath = reader.readStringOrNull(offsets[0]);
  object.formattedText = reader.readString(offsets[1]);
  object.id = id;
  object.rawTranscript = reader.readString(offsets[2]);
  object.selectedStyle = reader.readString(offsets[4]);
  object.timestamp = reader.readDateTime(offsets[5]);
  return object;
}

P _transcriptionEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transcriptionEntryGetId(TranscriptionEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transcriptionEntryGetLinks(
    TranscriptionEntry object) {
  return [];
}

void _transcriptionEntryAttach(
    IsarCollection<dynamic> col, Id id, TranscriptionEntry object) {
  object.id = id;
}

extension TranscriptionEntryQueryWhereSort
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QWhere> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhere>
      anySearchWordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'searchWords'),
      );
    });
  }
}

extension TranscriptionEntryQueryWhere
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QWhereClause> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementEqualTo(String searchWordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchWords',
        value: [searchWordsElement],
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementNotEqualTo(String searchWordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchWords',
              lower: [],
              upper: [searchWordsElement],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchWords',
              lower: [searchWordsElement],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchWords',
              lower: [searchWordsElement],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchWords',
              lower: [],
              upper: [searchWordsElement],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementGreaterThan(
    String searchWordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchWords',
        lower: [searchWordsElement],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementLessThan(
    String searchWordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchWords',
        lower: [],
        upper: [searchWordsElement],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementBetween(
    String lowerSearchWordsElement,
    String upperSearchWordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchWords',
        lower: [lowerSearchWordsElement],
        includeLower: includeLower,
        upper: [upperSearchWordsElement],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementStartsWith(String SearchWordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchWords',
        lower: [SearchWordsElementPrefix],
        upper: ['$SearchWordsElementPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchWords',
        value: [''],
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterWhereClause>
      searchWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchWords',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchWords',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchWords',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchWords',
              upper: [''],
            ));
      }
    });
  }
}

extension TranscriptionEntryQueryFilter
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QFilterCondition> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioFilePath',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioFilePath',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioFilePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      audioFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedText',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      formattedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedText',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawTranscript',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawTranscript',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      rawTranscriptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchWords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchWords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchWords',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchWords',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      searchWordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchWords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedStyle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedStyle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      selectedStyleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptionEntryQueryObject
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QFilterCondition> {}

extension TranscriptionEntryQueryLinks
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QFilterCondition> {}

extension TranscriptionEntryQuerySortBy
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QSortBy> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByAudioFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFilePath', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByAudioFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFilePath', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByFormattedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedText', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByFormattedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedText', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByRawTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByRawTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortBySelectedStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedStyle', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortBySelectedStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedStyle', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension TranscriptionEntryQuerySortThenBy
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QSortThenBy> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByAudioFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFilePath', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByAudioFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFilePath', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByFormattedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedText', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByFormattedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedText', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByRawTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByRawTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenBySelectedStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedStyle', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenBySelectedStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedStyle', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension TranscriptionEntryQueryWhereDistinct
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct> {
  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctByAudioFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFilePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctByFormattedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctByRawTranscript({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawTranscript',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctBySearchWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchWords');
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctBySelectedStyle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedStyle',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptionEntry, TranscriptionEntry, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension TranscriptionEntryQueryProperty
    on QueryBuilder<TranscriptionEntry, TranscriptionEntry, QQueryProperty> {
  QueryBuilder<TranscriptionEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TranscriptionEntry, String?, QQueryOperations>
      audioFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFilePath');
    });
  }

  QueryBuilder<TranscriptionEntry, String, QQueryOperations>
      formattedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedText');
    });
  }

  QueryBuilder<TranscriptionEntry, String, QQueryOperations>
      rawTranscriptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawTranscript');
    });
  }

  QueryBuilder<TranscriptionEntry, List<String>, QQueryOperations>
      searchWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchWords');
    });
  }

  QueryBuilder<TranscriptionEntry, String, QQueryOperations>
      selectedStyleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedStyle');
    });
  }

  QueryBuilder<TranscriptionEntry, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
