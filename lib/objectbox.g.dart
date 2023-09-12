// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'components/isar/message_conversation/message_object_box.dart';
import 'components/media_conversation/model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(2, 6453465181482896900),
      name: 'MessageConversationIOS',
      lastPropertyId: const IdUid(20, 4113167053055541425),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 4261780753090688879),
            name: 'localId',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 6024026088893480647),
            name: 'message',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 2284444311909343353),
            name: 'messageParse',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 159473349010824272),
            name: 'conversationId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 146005187430319394),
            name: 'currentTime',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 6183000446665532057),
            name: 'attachments',
            type: 30,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 9016135309349553125),
            name: 'dataRead',
            type: 30,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 4810202783447904259),
            name: 'id',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 4329715800264435382),
            name: 'count',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 822249155452906581),
            name: 'success',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 8720433817127096247),
            name: 'sending',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 6109891891531833424),
            name: 'isBlur',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 7089458312888785248),
            name: 'parentId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 2959628561043527373),
            name: 'insertedAt',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(15, 2419157526275889659),
            name: 'userId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(16, 7410492329949284505),
            name: 'fakeId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(17, 8377891110749821222),
            name: 'publicKeySender',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(18, 3177315924745445930),
            name: 'infoThread',
            type: 30,
            flags: 0),
        ModelProperty(
            id: const IdUid(19, 1737432001102519830),
            name: 'lastEditedAt',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(20, 4113167053055541425),
            name: 'action',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(7, 7604111303001212715),
      name: 'Media',
      lastPropertyId: const IdUid(10, 2027285325862699184),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 6284409418585258238),
            name: 'localId',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 9059684933333105409),
            name: 'pathInDevice',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 6060273658563265021),
            name: 'remoteUrl',
            type: 9,
            flags: 2048,
            indexId: const IdUid(9, 8272754819290603000)),
        ModelProperty(
            id: const IdUid(4, 3519558645750336407),
            name: 'name',
            type: 9,
            flags: 2048,
            indexId: const IdUid(10, 2597180293175932689)),
        ModelProperty(
            id: const IdUid(5, 3303009476477008010),
            name: 'type',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 1148365007302194444),
            name: 'metaData',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 1330528472833517779),
            name: 'size',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 3155003236418239392),
            name: 'keyEncrypt',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 6199032040532482702),
            name: 'status',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 2027285325862699184),
            name: 'version',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(8, 8831863981026055612),
      name: 'MediaConversation',
      lastPropertyId: const IdUid(8, 8531660936410949740),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5174502036103915040),
            name: 'localId',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 894113805085392189),
            name: 'messageId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 5058413165356184017),
            name: 'userId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 9171543939122486763),
            name: 'conversationId',
            type: 9,
            flags: 2048,
            indexId: const IdUid(11, 8112160987582570065)),
        ModelProperty(
            id: const IdUid(5, 4513829911587949234),
            name: 'insertedAt',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 1623088983643347553),
            name: 'keyDecrypt',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 3150806795718675691),
            name: 'currentTime',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 8531660936410949740),
            name: 'mediaId',
            type: 11,
            flags: 520,
            indexId: const IdUid(12, 2101587028252078222),
            relationTarget: 'Media')
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Open an ObjectBox store with the model declared in this file.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(8, 8831863981026055612),
      lastIndexId: const IdUid(12, 2101587028252078222),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [
        3205179996623346317,
        5318749224810403319,
        2265081848560833663,
        2733815809792894839,
        6523651895942149981
      ],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        5361573735342158374,
        6113532182769147483,
        4779947590923506105,
        2599199166009849908,
        4219983595472895450,
        6829130842844542900,
        4745809266828753898,
        4099064121505911469,
        8067296340122750609,
        2947231286464246141,
        4322804579680084983,
        986579690515288867,
        6876642736237344431,
        5896628877256223722,
        8053184817214659704,
        1654871450384287567,
        5669803913396692198,
        6456396568709011919,
        3109026090664721887,
        1581797407585485640,
        1320047323794366778,
        759666354328324744,
        1496769996258580341,
        7503872107845036180,
        1900793560637303589,
        5796121829952202817,
        7098410366453461869,
        2307543296561561794,
        4431097797031360342,
        411135517486073398,
        6597653758370303019,
        6067311251485336816,
        4941771624477646431,
        1293861632180489738,
        5268202608453498673,
        233521269841728801,
        6661821141866290796,
        3163215932000262818,
        5824678437333496276,
        2185267011536061226,
        7674943285323473069,
        6911626615590654162
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    MessageConversationIOS: EntityDefinition<MessageConversationIOS>(
        model: _entities[0],
        toOneRelations: (MessageConversationIOS object) => [],
        toManyRelations: (MessageConversationIOS object) => {},
        getId: (MessageConversationIOS object) => object.localId,
        setId: (MessageConversationIOS object, int id) {
          object.localId = id;
        },
        objectToFB: (MessageConversationIOS object, fb.Builder fbb) {
          final messageOffset = fbb.writeString(object.message);
          final messageParseOffset = fbb.writeString(object.messageParse);
          final conversationIdOffset = fbb.writeString(object.conversationId);
          final attachmentsOffset = fbb.writeList(
              object.attachments.map(fbb.writeString).toList(growable: false));
          final dataReadOffset = fbb.writeList(
              object.dataRead.map(fbb.writeString).toList(growable: false));
          final idOffset = fbb.writeString(object.id);
          final parentIdOffset = fbb.writeString(object.parentId);
          final insertedAtOffset = fbb.writeString(object.insertedAt);
          final userIdOffset = fbb.writeString(object.userId);
          final fakeIdOffset = fbb.writeString(object.fakeId);
          final publicKeySenderOffset = fbb.writeString(object.publicKeySender);
          final infoThreadOffset = fbb.writeList(
              object.infoThread.map(fbb.writeString).toList(growable: false));
          final lastEditedAtOffset = fbb.writeString(object.lastEditedAt);
          final actionOffset =
              object.action == null ? null : fbb.writeString(object.action!);
          fbb.startTable(21);
          fbb.addInt64(0, object.localId);
          fbb.addOffset(1, messageOffset);
          fbb.addOffset(2, messageParseOffset);
          fbb.addOffset(3, conversationIdOffset);
          fbb.addInt64(4, object.currentTime);
          fbb.addOffset(5, attachmentsOffset);
          fbb.addOffset(6, dataReadOffset);
          fbb.addOffset(7, idOffset);
          fbb.addInt64(8, object.count);
          fbb.addBool(9, object.success);
          fbb.addBool(10, object.sending);
          fbb.addBool(11, object.isBlur);
          fbb.addOffset(12, parentIdOffset);
          fbb.addOffset(13, insertedAtOffset);
          fbb.addOffset(14, userIdOffset);
          fbb.addOffset(15, fakeIdOffset);
          fbb.addOffset(16, publicKeySenderOffset);
          fbb.addOffset(17, infoThreadOffset);
          fbb.addOffset(18, lastEditedAtOffset);
          fbb.addOffset(19, actionOffset);
          fbb.finish(fbb.endTable());
          return object.localId;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = MessageConversationIOS(
              localId:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              message: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              messageParse: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              conversationId: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              currentTime:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0),
              attachments:
                  const fb.ListReader<String>(fb.StringReader(asciiOptimization: true), lazy: false)
                      .vTableGet(buffer, rootOffset, 14, []),
              dataRead: const fb.ListReader<String>(fb.StringReader(asciiOptimization: true), lazy: false)
                  .vTableGet(buffer, rootOffset, 16, []),
              id: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 18, ''),
              count: const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0),
              success: const fb.BoolReader().vTableGet(buffer, rootOffset, 22, false),
              sending: const fb.BoolReader().vTableGet(buffer, rootOffset, 24, false),
              isBlur: const fb.BoolReader().vTableGet(buffer, rootOffset, 26, false),
              parentId: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 28, ''),
              insertedAt: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 30, ''),
              userId: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 32, ''),
              fakeId: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 34, ''),
              publicKeySender: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 36, ''),
              infoThread: const fb.ListReader<String>(fb.StringReader(asciiOptimization: true), lazy: false).vTableGet(buffer, rootOffset, 38, []),
              lastEditedAt: const fb.StringReader(asciiOptimization: true).vTableGet(buffer, rootOffset, 40, ''),
              action: const fb.StringReader(asciiOptimization: true).vTableGetNullable(buffer, rootOffset, 42));

          return object;
        }),
    Media: EntityDefinition<Media>(
        model: _entities[1],
        toOneRelations: (Media object) => [],
        toManyRelations: (Media object) => {},
        getId: (Media object) => object.localId,
        setId: (Media object, int id) {
          object.localId = id;
        },
        objectToFB: (Media object, fb.Builder fbb) {
          final pathInDeviceOffset = object.pathInDevice == null
              ? null
              : fbb.writeString(object.pathInDevice!);
          final remoteUrlOffset = fbb.writeString(object.remoteUrl);
          final nameOffset = fbb.writeString(object.name);
          final typeOffset = fbb.writeString(object.type);
          final metaDataOffset = fbb.writeString(object.metaData);
          final keyEncryptOffset = fbb.writeString(object.keyEncrypt);
          final statusOffset = fbb.writeString(object.status);
          fbb.startTable(11);
          fbb.addInt64(0, object.localId);
          fbb.addOffset(1, pathInDeviceOffset);
          fbb.addOffset(2, remoteUrlOffset);
          fbb.addOffset(3, nameOffset);
          fbb.addOffset(4, typeOffset);
          fbb.addOffset(5, metaDataOffset);
          fbb.addInt64(6, object.size);
          fbb.addOffset(7, keyEncryptOffset);
          fbb.addOffset(8, statusOffset);
          fbb.addInt64(9, object.version);
          fbb.finish(fbb.endTable());
          return object.localId;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Media(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 6),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 14, ''),
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 18, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 20, ''),
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 22));

          return object;
        }),
    MediaConversation: EntityDefinition<MediaConversation>(
        model: _entities[2],
        toOneRelations: (MediaConversation object) => [object.media],
        toManyRelations: (MediaConversation object) => {},
        getId: (MediaConversation object) => object.localId,
        setId: (MediaConversation object, int id) {
          object.localId = id;
        },
        objectToFB: (MediaConversation object, fb.Builder fbb) {
          final messageIdOffset = fbb.writeString(object.messageId);
          final userIdOffset = fbb.writeString(object.userId);
          final conversationIdOffset = fbb.writeString(object.conversationId);
          final insertedAtOffset = fbb.writeString(object.insertedAt);
          final keyDecryptOffset = fbb.writeString(object.keyDecrypt);
          fbb.startTable(9);
          fbb.addInt64(0, object.localId);
          fbb.addOffset(1, messageIdOffset);
          fbb.addOffset(2, userIdOffset);
          fbb.addOffset(3, conversationIdOffset);
          fbb.addOffset(4, insertedAtOffset);
          fbb.addOffset(5, keyDecryptOffset);
          fbb.addInt64(6, object.currentTime);
          fbb.addInt64(7, object.media.targetId);
          fbb.finish(fbb.endTable());
          return object.localId;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = MediaConversation(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, ''),
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0),
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 14, ''));
          object.media.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 18, 0);
          object.media.attach(store);
          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [MessageConversationIOS] entity fields to define ObjectBox queries.
class MessageConversationIOS_ {
  /// see [MessageConversationIOS.localId]
  static final localId =
      QueryIntegerProperty<MessageConversationIOS>(_entities[0].properties[0]);

  /// see [MessageConversationIOS.message]
  static final message =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[1]);

  /// see [MessageConversationIOS.messageParse]
  static final messageParse =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[2]);

  /// see [MessageConversationIOS.conversationId]
  static final conversationId =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[3]);

  /// see [MessageConversationIOS.currentTime]
  static final currentTime =
      QueryIntegerProperty<MessageConversationIOS>(_entities[0].properties[4]);

  /// see [MessageConversationIOS.attachments]
  static final attachments = QueryStringVectorProperty<MessageConversationIOS>(
      _entities[0].properties[5]);

  /// see [MessageConversationIOS.dataRead]
  static final dataRead = QueryStringVectorProperty<MessageConversationIOS>(
      _entities[0].properties[6]);

  /// see [MessageConversationIOS.id]
  static final id =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[7]);

  /// see [MessageConversationIOS.count]
  static final count =
      QueryIntegerProperty<MessageConversationIOS>(_entities[0].properties[8]);

  /// see [MessageConversationIOS.success]
  static final success =
      QueryBooleanProperty<MessageConversationIOS>(_entities[0].properties[9]);

  /// see [MessageConversationIOS.sending]
  static final sending =
      QueryBooleanProperty<MessageConversationIOS>(_entities[0].properties[10]);

  /// see [MessageConversationIOS.isBlur]
  static final isBlur =
      QueryBooleanProperty<MessageConversationIOS>(_entities[0].properties[11]);

  /// see [MessageConversationIOS.parentId]
  static final parentId =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[12]);

  /// see [MessageConversationIOS.insertedAt]
  static final insertedAt =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[13]);

  /// see [MessageConversationIOS.userId]
  static final userId =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[14]);

  /// see [MessageConversationIOS.fakeId]
  static final fakeId =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[15]);

  /// see [MessageConversationIOS.publicKeySender]
  static final publicKeySender =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[16]);

  /// see [MessageConversationIOS.infoThread]
  static final infoThread = QueryStringVectorProperty<MessageConversationIOS>(
      _entities[0].properties[17]);

  /// see [MessageConversationIOS.lastEditedAt]
  static final lastEditedAt =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[18]);

  /// see [MessageConversationIOS.action]
  static final action =
      QueryStringProperty<MessageConversationIOS>(_entities[0].properties[19]);
}

/// [Media] entity fields to define ObjectBox queries.
class Media_ {
  /// see [Media.localId]
  static final localId =
      QueryIntegerProperty<Media>(_entities[1].properties[0]);

  /// see [Media.pathInDevice]
  static final pathInDevice =
      QueryStringProperty<Media>(_entities[1].properties[1]);

  /// see [Media.remoteUrl]
  static final remoteUrl =
      QueryStringProperty<Media>(_entities[1].properties[2]);

  /// see [Media.name]
  static final name = QueryStringProperty<Media>(_entities[1].properties[3]);

  /// see [Media.type]
  static final type = QueryStringProperty<Media>(_entities[1].properties[4]);

  /// see [Media.metaData]
  static final metaData =
      QueryStringProperty<Media>(_entities[1].properties[5]);

  /// see [Media.size]
  static final size = QueryIntegerProperty<Media>(_entities[1].properties[6]);

  /// see [Media.keyEncrypt]
  static final keyEncrypt =
      QueryStringProperty<Media>(_entities[1].properties[7]);

  /// see [Media.status]
  static final status = QueryStringProperty<Media>(_entities[1].properties[8]);

  /// see [Media.version]
  static final version =
      QueryIntegerProperty<Media>(_entities[1].properties[9]);
}

/// [MediaConversation] entity fields to define ObjectBox queries.
class MediaConversation_ {
  /// see [MediaConversation.localId]
  static final localId =
      QueryIntegerProperty<MediaConversation>(_entities[2].properties[0]);

  /// see [MediaConversation.messageId]
  static final messageId =
      QueryStringProperty<MediaConversation>(_entities[2].properties[1]);

  /// see [MediaConversation.userId]
  static final userId =
      QueryStringProperty<MediaConversation>(_entities[2].properties[2]);

  /// see [MediaConversation.conversationId]
  static final conversationId =
      QueryStringProperty<MediaConversation>(_entities[2].properties[3]);

  /// see [MediaConversation.insertedAt]
  static final insertedAt =
      QueryStringProperty<MediaConversation>(_entities[2].properties[4]);

  /// see [MediaConversation.keyDecrypt]
  static final keyDecrypt =
      QueryStringProperty<MediaConversation>(_entities[2].properties[5]);

  /// see [MediaConversation.currentTime]
  static final currentTime =
      QueryIntegerProperty<MediaConversation>(_entities[2].properties[6]);

  /// see [MediaConversation.media]
  static final media =
      QueryRelationToOne<MediaConversation, Media>(_entities[2].properties[7]);
}
