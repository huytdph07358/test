import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key, required this.onTap, required this.text, this.isLoading = false}) : super(key: key);
  final onTap;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 11.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, 3),
              blurRadius: 8,
            )
          ],
          color: Color(0xff2A5298)
        ),
        child: isLoading ? SpinKitFadingCircle(
          color: Colors.white,
          size: Platform.isIOS ? 19 : 16,
        ) : Text(
          text,
          style: TextStyle(fontSize: Platform.isIOS ? 16 : 14, color: Colors.white, fontWeight: FontWeight.w500),
        )
      ),
    );
  }
}
