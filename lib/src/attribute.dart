import 'package:flutter_quill/flutter_quill.dart';

class MentionAttribute extends Attribute<String?> {
  const MentionAttribute(String? val) : super('mention', AttributeScope.INLINE, val);
}