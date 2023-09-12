// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'components/isar/message_conversation/message_conversation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"MessageConversation","idProperty":"localId","properties":[{"name":"localId","type":3},{"name":"message","type":5},{"name":"messageParse","type":5},{"name":"conversationId","type":5},{"name":"currentTime","type":3},{"name":"attachments","type":11},{"name":"dataRead","type":11},{"name":"id","type":5},{"name":"count","type":3},{"name":"success","type":0},{"name":"sending","type":0},{"name":"isBlur","type":0},{"name":"parentId","type":5},{"name":"insertedAt","type":5},{"name":"userId","type":5},{"name":"fakeId","type":5},{"name":"publicKeySender","type":5},{"name":"infoThread","type":11},{"name":"lastEditedAt","type":5},{"name":"action","type":5}],"indexes":[{"unique":false,"replace":false,"properties":[{"name":"messageParse","indexType":2,"caseSensitive":true}]},{"unique":false,"replace":false,"properties":[{"name":"conversationId","indexType":1,"caseSensitive":true}]},{"unique":false,"replace":false,"properties":[{"name":"id","indexType":1,"caseSensitive":true}]},{"unique":false,"replace":false,"properties":[{"name":"parentId","indexType":1,"caseSensitive":true},{"name":"conversationId","indexType":1,"caseSensitive":true}]}],"links":[]}]';

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  final path = await _preparePath(directory);
  return openIsarInternal(
      name: name,
      directory: path,
      maxSize: maxSize,
      encryptionKey: encryptionKey,
      schema: _schema,
      getCollections: (isar) {
        final collectionPtrPtr = malloc<Pointer>();
        final propertyOffsetsPtr = malloc<Uint32>(20);
        final propertyOffsets = propertyOffsetsPtr.asTypedList(20);
        final collections = <String, IsarCollection>{};
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 0));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['MessageConversation'] =
            IsarCollectionImpl<MessageConversation>(
          isar: isar,
          adapter: _MessageConversationAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 20),
          propertyIds: {
            'localId': 0,
            'message': 1,
            'messageParse': 2,
            'conversationId': 3,
            'currentTime': 4,
            'attachments': 5,
            'dataRead': 6,
            'id': 7,
            'count': 8,
            'success': 9,
            'sending': 10,
            'isBlur': 11,
            'parentId': 12,
            'insertedAt': 13,
            'userId': 14,
            'fakeId': 15,
            'publicKeySender': 16,
            'infoThread': 17,
            'lastEditedAt': 18,
            'action': 19
          },
          indexIds: {
            'messageParse': 0,
            'conversationId': 1,
            'id': 2,
            'parentId': 3
          },
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.localId,
          setId: (obj, id) => obj.localId = id,
        );
        malloc.free(propertyOffsetsPtr);
        malloc.free(collectionPtrPtr);

        return collections;
      });
}

Future<String> _preparePath(String? path) async {
  if (path == null || p.isRelative(path)) {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, path ?? 'isar');
  } else {
    return path;
  }
}

class _MessageConversationAdapter extends TypeAdapter<MessageConversation> {
  @override
  int serialize(IsarCollectionImpl<MessageConversation> collection,
      RawObject rawObj, MessageConversation object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.localId;
    final _localId = value0;
    final value1 = object.message;
    Uint8List? _message;
    if (value1 != null) {
      _message = _utf8Encoder.convert(value1);
    }
    dynamicSize += _message?.length ?? 0;
    final value2 = object.messageParse;
    Uint8List? _messageParse;
    if (value2 != null) {
      _messageParse = _utf8Encoder.convert(value2);
    }
    dynamicSize += _messageParse?.length ?? 0;
    final value3 = object.conversationId;
    Uint8List? _conversationId;
    if (value3 != null) {
      _conversationId = _utf8Encoder.convert(value3);
    }
    dynamicSize += _conversationId?.length ?? 0;
    final value4 = object.currentTime;
    final _currentTime = value4;
    final value5 = object.attachments;
    dynamicSize += (value5?.length ?? 0) * 8;
    List<Uint8List?>? bytesList5;
    if (value5 != null) {
      bytesList5 = [];
      for (var str in value5) {
        final bytes = _utf8Encoder.convert(str);
        bytesList5.add(bytes);
        dynamicSize += bytes.length;
      }
    }
    final _attachments = bytesList5;
    final value6 = object.dataRead;
    dynamicSize += (value6?.length ?? 0) * 8;
    List<Uint8List?>? bytesList6;
    if (value6 != null) {
      bytesList6 = [];
      for (var str in value6) {
        final bytes = _utf8Encoder.convert(str);
        bytesList6.add(bytes);
        dynamicSize += bytes.length;
      }
    }
    final _dataRead = bytesList6;
    final value7 = object.id;
    Uint8List? _id;
    if (value7 != null) {
      _id = _utf8Encoder.convert(value7);
    }
    dynamicSize += _id?.length ?? 0;
    final value8 = object.count;
    final _count = value8;
    final value9 = object.success;
    final _success = value9;
    final value10 = object.sending;
    final _sending = value10;
    final value11 = object.isBlur;
    final _isBlur = value11;
    final value12 = object.parentId;
    Uint8List? _parentId;
    if (value12 != null) {
      _parentId = _utf8Encoder.convert(value12);
    }
    dynamicSize += _parentId?.length ?? 0;
    final value13 = object.insertedAt;
    Uint8List? _insertedAt;
    if (value13 != null) {
      _insertedAt = _utf8Encoder.convert(value13);
    }
    dynamicSize += _insertedAt?.length ?? 0;
    final value14 = object.userId;
    Uint8List? _userId;
    if (value14 != null) {
      _userId = _utf8Encoder.convert(value14);
    }
    dynamicSize += _userId?.length ?? 0;
    final value15 = object.fakeId;
    Uint8List? _fakeId;
    if (value15 != null) {
      _fakeId = _utf8Encoder.convert(value15);
    }
    dynamicSize += _fakeId?.length ?? 0;
    final value16 = object.publicKeySender;
    Uint8List? _publicKeySender;
    if (value16 != null) {
      _publicKeySender = _utf8Encoder.convert(value16);
    }
    dynamicSize += _publicKeySender?.length ?? 0;
    final value17 = object.infoThread;
    dynamicSize += (value17?.length ?? 0) * 8;
    List<Uint8List?>? bytesList17;
    if (value17 != null) {
      bytesList17 = [];
      for (var str in value17) {
        final bytes = _utf8Encoder.convert(str);
        bytesList17.add(bytes);
        dynamicSize += bytes.length;
      }
    }
    final _infoThread = bytesList17;
    final value18 = object.lastEditedAt;
    Uint8List? _lastEditedAt;
    if (value18 != null) {
      _lastEditedAt = _utf8Encoder.convert(value18);
    }
    dynamicSize += _lastEditedAt?.length ?? 0;
    final value19 = object.action;
    Uint8List? _action;
    if (value19 != null) {
      _action = _utf8Encoder.convert(value19);
    }
    dynamicSize += _action?.length ?? 0;
    final size = dynamicSize + 141;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 141);
    writer.writeLong(offsets[0], _localId);
    writer.writeBytes(offsets[1], _message);
    writer.writeBytes(offsets[2], _messageParse);
    writer.writeBytes(offsets[3], _conversationId);
    writer.writeLong(offsets[4], _currentTime);
    writer.writeStringList(offsets[5], _attachments);
    writer.writeStringList(offsets[6], _dataRead);
    writer.writeBytes(offsets[7], _id);
    writer.writeLong(offsets[8], _count);
    writer.writeBool(offsets[9], _success);
    writer.writeBool(offsets[10], _sending);
    writer.writeBool(offsets[11], _isBlur);
    writer.writeBytes(offsets[12], _parentId);
    writer.writeBytes(offsets[13], _insertedAt);
    writer.writeBytes(offsets[14], _userId);
    writer.writeBytes(offsets[15], _fakeId);
    writer.writeBytes(offsets[16], _publicKeySender);
    writer.writeStringList(offsets[17], _infoThread);
    writer.writeBytes(offsets[18], _lastEditedAt);
    writer.writeBytes(offsets[19], _action);
    return bufferSize;
  }

  @override
  MessageConversation deserialize(
      IsarCollectionImpl<MessageConversation> collection,
      BinaryReader reader,
      List<int> offsets) {
    final object = MessageConversation();
    object.localId = reader.readLongOrNull(offsets[0]);
    object.message = reader.readStringOrNull(offsets[1]);
    object.messageParse = reader.readStringOrNull(offsets[2]);
    object.conversationId = reader.readStringOrNull(offsets[3]);
    object.currentTime = reader.readLongOrNull(offsets[4]);
    object.attachments = reader.readStringList(offsets[5]);
    object.dataRead = reader.readStringList(offsets[6]);
    object.id = reader.readStringOrNull(offsets[7]);
    object.count = reader.readLongOrNull(offsets[8]);
    object.success = reader.readBoolOrNull(offsets[9]);
    object.sending = reader.readBoolOrNull(offsets[10]);
    object.isBlur = reader.readBoolOrNull(offsets[11]);
    object.parentId = reader.readStringOrNull(offsets[12]);
    object.insertedAt = reader.readStringOrNull(offsets[13]);
    object.userId = reader.readStringOrNull(offsets[14]);
    object.fakeId = reader.readStringOrNull(offsets[15]);
    object.publicKeySender = reader.readStringOrNull(offsets[16]);
    object.infoThread = reader.readStringList(offsets[17]);
    object.lastEditedAt = reader.readStringOrNull(offsets[18]);
    object.action = reader.readStringOrNull(offsets[19]);
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readStringOrNull(offset)) as P;
      case 2:
        return (reader.readStringOrNull(offset)) as P;
      case 3:
        return (reader.readStringOrNull(offset)) as P;
      case 4:
        return (reader.readLongOrNull(offset)) as P;
      case 5:
        return (reader.readStringList(offset)) as P;
      case 6:
        return (reader.readStringList(offset)) as P;
      case 7:
        return (reader.readStringOrNull(offset)) as P;
      case 8:
        return (reader.readLongOrNull(offset)) as P;
      case 9:
        return (reader.readBoolOrNull(offset)) as P;
      case 10:
        return (reader.readBoolOrNull(offset)) as P;
      case 11:
        return (reader.readBoolOrNull(offset)) as P;
      case 12:
        return (reader.readStringOrNull(offset)) as P;
      case 13:
        return (reader.readStringOrNull(offset)) as P;
      case 14:
        return (reader.readStringOrNull(offset)) as P;
      case 15:
        return (reader.readStringOrNull(offset)) as P;
      case 16:
        return (reader.readStringOrNull(offset)) as P;
      case 17:
        return (reader.readStringList(offset)) as P;
      case 18:
        return (reader.readStringOrNull(offset)) as P;
      case 19:
        return (reader.readStringOrNull(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

extension GetCollection on Isar {
  IsarCollection<MessageConversation> get messageConversations {
    return getCollection('MessageConversation');
  }
}

extension MessageConversationQueryWhereSort
    on QueryBuilder<MessageConversation, QWhere> {
  QueryBuilder<MessageConversation, QAfterWhere> anyLocalId() {
    return addWhereClause(WhereClause(indexName: 'localId'));
  }
}

extension MessageConversationQueryWhere
    on QueryBuilder<MessageConversation, QWhereClause> {
  QueryBuilder<MessageConversation, QAfterWhereClause> messageParseWordEqualTo(
      String? messageParse) {
    return addWhereClause(WhereClause(
      indexName: 'messageParse',
      upper: [messageParse],
      includeUpper: true,
      lower: [messageParse],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause>
      messageParseWordStartsWith(String? value) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addWhereClause(WhereClause(
      indexName: 'messageParse',
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> conversationIdEqualTo(
      String? conversationId) {
    return addWhereClause(WhereClause(
      indexName: 'conversationId',
      upper: [conversationId],
      includeUpper: true,
      lower: [conversationId],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> conversationIdNotEqualTo(
      String? conversationId) {
    return addWhereClause(WhereClause(
      indexName: 'conversationId',
      upper: [conversationId],
      includeUpper: false,
    )).addWhereClause(WhereClause(
      indexName: 'conversationId',
      lower: [conversationId],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> conversationIdIsNull() {
    return addWhereClause(WhereClause(
      indexName: 'conversationId',
      upper: [null],
      includeUpper: true,
      lower: [null],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause>
      conversationIdIsNotNull() {
    return addWhereClause(WhereClause(
      indexName: 'conversationId',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> idEqualTo(String? id) {
    return addWhereClause(WhereClause(
      indexName: 'id',
      upper: [id],
      includeUpper: true,
      lower: [id],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> idNotEqualTo(
      String? id) {
    return addWhereClause(WhereClause(
      indexName: 'id',
      upper: [id],
      includeUpper: false,
    )).addWhereClause(WhereClause(
      indexName: 'id',
      lower: [id],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> idIsNull() {
    return addWhereClause(WhereClause(
      indexName: 'id',
      upper: [null],
      includeUpper: true,
      lower: [null],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> idIsNotNull() {
    return addWhereClause(WhereClause(
      indexName: 'id',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> parentIdEqualTo(
      String? parentId) {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      upper: [parentId],
      includeUpper: true,
      lower: [parentId],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> parentIdNotEqualTo(
      String? parentId) {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      upper: [parentId],
      includeUpper: false,
    )).addWhereClause(WhereClause(
      indexName: 'parentId',
      lower: [parentId],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> parentIdIsNull() {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      upper: [null],
      includeUpper: true,
      lower: [null],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause> parentIdIsNotNull() {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause>
      parentIdConversationIdEqualTo(String? parentId, String? conversationId) {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      upper: [parentId, conversationId],
      includeUpper: true,
      lower: [parentId, conversationId],
      includeLower: true,
    ));
  }

  QueryBuilder<MessageConversation, QAfterWhereClause>
      parentIdConversationIdNotEqualTo(
          String? parentId, String? conversationId) {
    return addWhereClause(WhereClause(
      indexName: 'parentId',
      upper: [parentId, conversationId],
      includeUpper: false,
    )).addWhereClause(WhereClause(
      indexName: 'parentId',
      lower: [parentId, conversationId],
      includeLower: false,
    ));
  }
}

extension MessageConversationQueryFilter
    on QueryBuilder<MessageConversation, QFilterCondition> {
  QueryBuilder<MessageConversation, QAfterFilterCondition> localIdIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'localId',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> localIdEqualTo(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'localId',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> localIdGreaterThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'localId',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> localIdLessThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'localId',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> localIdBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'localId',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'message',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'message',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'message',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'message',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'message',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'message',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      messageParseIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'messageParse',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageParseEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'messageParse',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      messageParseStartsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'messageParse',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageParseEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'messageParse',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageParseContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'messageParse',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> messageParseMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'messageParse',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'conversationId',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdEqualTo(String? value, {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'conversationId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdStartsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'conversationId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdEndsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'conversationId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdContains(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'conversationId',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'conversationId',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> currentTimeIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'currentTime',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> currentTimeEqualTo(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'currentTime',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      currentTimeGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'currentTime',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> currentTimeLessThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'currentTime',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> currentTimeBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'currentTime',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'id',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'id',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'id',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'id',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> countIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'count',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> countEqualTo(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'count',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> countGreaterThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'count',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> countLessThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'count',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> countBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'count',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> successIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'success',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> successEqualTo(
      bool? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'success',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> sendingIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'sending',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> sendingEqualTo(
      bool? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'sending',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> isBlurIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'isBlur',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> isBlurEqualTo(
      bool? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'isBlur',
      value: value,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'parentId',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'parentId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'parentId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'parentId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'parentId',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> parentIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'parentId',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'insertedAt',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'insertedAt',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'insertedAt',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'insertedAt',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'insertedAt',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> insertedAtMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'insertedAt',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'userId',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'userId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'userId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'userId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'userId',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'userId',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'fakeId',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'fakeId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'fakeId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'fakeId',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'fakeId',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> fakeIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'fakeId',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'publicKeySender',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderEqualTo(String? value, {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'publicKeySender',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderStartsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'publicKeySender',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderEndsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'publicKeySender',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderContains(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'publicKeySender',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      publicKeySenderMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'publicKeySender',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      lastEditedAtIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lastEditedAt',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> lastEditedAtEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lastEditedAt',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition>
      lastEditedAtStartsWith(String? value, {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'lastEditedAt',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> lastEditedAtEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'lastEditedAt',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> lastEditedAtContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lastEditedAt',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> lastEditedAtMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lastEditedAt',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'action',
      value: null,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionEqualTo(
      String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'action',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'action',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'action',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'action',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MessageConversation, QAfterFilterCondition> actionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'action',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension MessageConversationQueryLinks
    on QueryBuilder<MessageConversation, QFilterCondition> {}

extension MessageConversationQueryWhereSortBy
    on QueryBuilder<MessageConversation, QSortBy> {
  QueryBuilder<MessageConversation, QAfterSortBy> sortByLocalId() {
    return addSortByInternal('localId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByLocalIdDesc() {
    return addSortByInternal('localId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByMessage() {
    return addSortByInternal('message', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByMessageDesc() {
    return addSortByInternal('message', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByMessageParse() {
    return addSortByInternal('messageParse', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByMessageParseDesc() {
    return addSortByInternal('messageParse', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByConversationId() {
    return addSortByInternal('conversationId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByConversationIdDesc() {
    return addSortByInternal('conversationId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByCurrentTime() {
    return addSortByInternal('currentTime', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByCurrentTimeDesc() {
    return addSortByInternal('currentTime', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByCount() {
    return addSortByInternal('count', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByCountDesc() {
    return addSortByInternal('count', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortBySuccess() {
    return addSortByInternal('success', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortBySuccessDesc() {
    return addSortByInternal('success', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortBySending() {
    return addSortByInternal('sending', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortBySendingDesc() {
    return addSortByInternal('sending', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByIsBlur() {
    return addSortByInternal('isBlur', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByIsBlurDesc() {
    return addSortByInternal('isBlur', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByParentId() {
    return addSortByInternal('parentId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByParentIdDesc() {
    return addSortByInternal('parentId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByInsertedAt() {
    return addSortByInternal('insertedAt', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByInsertedAtDesc() {
    return addSortByInternal('insertedAt', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByUserId() {
    return addSortByInternal('userId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByUserIdDesc() {
    return addSortByInternal('userId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByFakeId() {
    return addSortByInternal('fakeId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByFakeIdDesc() {
    return addSortByInternal('fakeId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByPublicKeySender() {
    return addSortByInternal('publicKeySender', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByPublicKeySenderDesc() {
    return addSortByInternal('publicKeySender', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByLastEditedAt() {
    return addSortByInternal('lastEditedAt', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByLastEditedAtDesc() {
    return addSortByInternal('lastEditedAt', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByAction() {
    return addSortByInternal('action', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> sortByActionDesc() {
    return addSortByInternal('action', Sort.Desc);
  }
}

extension MessageConversationQueryWhereSortThenBy
    on QueryBuilder<MessageConversation, QSortThenBy> {
  QueryBuilder<MessageConversation, QAfterSortBy> thenByLocalId() {
    return addSortByInternal('localId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByLocalIdDesc() {
    return addSortByInternal('localId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByMessage() {
    return addSortByInternal('message', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByMessageDesc() {
    return addSortByInternal('message', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByMessageParse() {
    return addSortByInternal('messageParse', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByMessageParseDesc() {
    return addSortByInternal('messageParse', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByConversationId() {
    return addSortByInternal('conversationId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByConversationIdDesc() {
    return addSortByInternal('conversationId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByCurrentTime() {
    return addSortByInternal('currentTime', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByCurrentTimeDesc() {
    return addSortByInternal('currentTime', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByCount() {
    return addSortByInternal('count', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByCountDesc() {
    return addSortByInternal('count', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenBySuccess() {
    return addSortByInternal('success', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenBySuccessDesc() {
    return addSortByInternal('success', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenBySending() {
    return addSortByInternal('sending', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenBySendingDesc() {
    return addSortByInternal('sending', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByIsBlur() {
    return addSortByInternal('isBlur', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByIsBlurDesc() {
    return addSortByInternal('isBlur', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByParentId() {
    return addSortByInternal('parentId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByParentIdDesc() {
    return addSortByInternal('parentId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByInsertedAt() {
    return addSortByInternal('insertedAt', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByInsertedAtDesc() {
    return addSortByInternal('insertedAt', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByUserId() {
    return addSortByInternal('userId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByUserIdDesc() {
    return addSortByInternal('userId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByFakeId() {
    return addSortByInternal('fakeId', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByFakeIdDesc() {
    return addSortByInternal('fakeId', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByPublicKeySender() {
    return addSortByInternal('publicKeySender', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByPublicKeySenderDesc() {
    return addSortByInternal('publicKeySender', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByLastEditedAt() {
    return addSortByInternal('lastEditedAt', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByLastEditedAtDesc() {
    return addSortByInternal('lastEditedAt', Sort.Desc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByAction() {
    return addSortByInternal('action', Sort.Asc);
  }

  QueryBuilder<MessageConversation, QAfterSortBy> thenByActionDesc() {
    return addSortByInternal('action', Sort.Desc);
  }
}

extension MessageConversationQueryWhereDistinct
    on QueryBuilder<MessageConversation, QDistinct> {
  QueryBuilder<MessageConversation, QDistinct> distinctByLocalId() {
    return addDistinctByInternal('localId');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByMessage(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('message', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByMessageParse(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('messageParse', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByConversationId(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('conversationId',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByCurrentTime() {
    return addDistinctByInternal('currentTime');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('id', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByCount() {
    return addDistinctByInternal('count');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctBySuccess() {
    return addDistinctByInternal('success');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctBySending() {
    return addDistinctByInternal('sending');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByIsBlur() {
    return addDistinctByInternal('isBlur');
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByParentId(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('parentId', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByInsertedAt(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('insertedAt', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('userId', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByFakeId(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('fakeId', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByPublicKeySender(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('publicKeySender',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByLastEditedAt(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('lastEditedAt', caseSensitive: caseSensitive);
  }

  QueryBuilder<MessageConversation, QDistinct> distinctByAction(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('action', caseSensitive: caseSensitive);
  }
}

extension MessageConversationQueryProperty
    on QueryBuilder<MessageConversation, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> localIdProperty() {
    return addPropertyName('localId');
  }

  QueryBuilder<String?, QQueryOperations> messageProperty() {
    return addPropertyName('message');
  }

  QueryBuilder<String?, QQueryOperations> messageParseProperty() {
    return addPropertyName('messageParse');
  }

  QueryBuilder<String?, QQueryOperations> conversationIdProperty() {
    return addPropertyName('conversationId');
  }

  QueryBuilder<int?, QQueryOperations> currentTimeProperty() {
    return addPropertyName('currentTime');
  }

  QueryBuilder<List<String>?, QQueryOperations> attachmentsProperty() {
    return addPropertyName('attachments');
  }

  QueryBuilder<List<String>?, QQueryOperations> dataReadProperty() {
    return addPropertyName('dataRead');
  }

  QueryBuilder<String?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<int?, QQueryOperations> countProperty() {
    return addPropertyName('count');
  }

  QueryBuilder<bool?, QQueryOperations> successProperty() {
    return addPropertyName('success');
  }

  QueryBuilder<bool?, QQueryOperations> sendingProperty() {
    return addPropertyName('sending');
  }

  QueryBuilder<bool?, QQueryOperations> isBlurProperty() {
    return addPropertyName('isBlur');
  }

  QueryBuilder<String?, QQueryOperations> parentIdProperty() {
    return addPropertyName('parentId');
  }

  QueryBuilder<String?, QQueryOperations> insertedAtProperty() {
    return addPropertyName('insertedAt');
  }

  QueryBuilder<String?, QQueryOperations> userIdProperty() {
    return addPropertyName('userId');
  }

  QueryBuilder<String?, QQueryOperations> fakeIdProperty() {
    return addPropertyName('fakeId');
  }

  QueryBuilder<String?, QQueryOperations> publicKeySenderProperty() {
    return addPropertyName('publicKeySender');
  }

  QueryBuilder<List<String>?, QQueryOperations> infoThreadProperty() {
    return addPropertyName('infoThread');
  }

  QueryBuilder<String?, QQueryOperations> lastEditedAtProperty() {
    return addPropertyName('lastEditedAt');
  }

  QueryBuilder<String?, QQueryOperations> actionProperty() {
    return addPropertyName('action');
  }
}
