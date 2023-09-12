import 'package:objectbox/objectbox.dart';
@Entity()
class MessageConversationIOS {
  @Id(assignable: true)
  int localId;

  String message;
  String messageParse;
  String conversationId;
  int currentTime;
  List<String> attachments;
  List<String> dataRead;
  String id;
  int count;
  bool success;
  bool sending;
  bool isBlur;
  String parentId;
  String insertedAt;
  String userId;
  String fakeId;
  String publicKeySender;
  List<String> infoThread;
  String lastEditedAt;
  String? action;


  MessageConversationIOS({
    this.localId = 0, 
    required this.message, 
    required this.messageParse,
    required this.conversationId, 
    required this.currentTime,
    required this.attachments, 
    required this.dataRead, 
    required this.id,
    required this.count, 
    required this.success,
    required this.sending, 
    required this.isBlur,
    required this.parentId, 
    required this.insertedAt,
    required this.userId, 
    required this.fakeId,
    required this.publicKeySender, 
    required this.infoThread,
    required this.lastEditedAt,
    required this.action
  });
}