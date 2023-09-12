import 'package:flutter/material.dart';

class NotFoundConversationException extends StatefulWidget {
  const NotFoundConversationException({ Key? key, required this.onTap }) : super(key: key);
  final Function onTap;

  @override
  State<NotFoundConversationException> createState() => _NotFoundConversationExceptionState();
}

class _NotFoundConversationExceptionState extends State<NotFoundConversationException> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Wrap(
            children: [
              Image.asset("assets/images/some_thing_wrong.png"),
              Center(
                child: InkWell(
                  onTap: (){
                    widget.onTap();
                  },
                  child: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1890FF),
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Text("Go Back", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, ),)),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}