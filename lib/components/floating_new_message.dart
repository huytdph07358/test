
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/floating_new_message_item.dart';
import 'package:workcake/models/models.dart';

class FloatingNewMessage extends StatefulWidget {
  // require content, sender Infor, reviver infor, action

  @override
  _FloatingNewMessage createState() => _FloatingNewMessage();
}

class _FloatingNewMessage extends State<FloatingNewMessage> {

  @override
  Widget build(BuildContext context) {
    // a animation width 3s from top to bottom when start end left to right when end and can over all View
    final dataMessage = Provider.of<DirectMessage>(context, listen: true).dataMessage;
    
    return Stack(
      children: dataMessage.map((e,) =>  FloatingNewMessageItem(data:  e,)).toList(),
    );

}

}
