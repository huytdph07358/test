import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: AssetImage("assets/images/logoPanchat.png"),
          height: 34,  
        ),
        SizedBox(width: 8.0,),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Pancake',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headline4,
              fontSize: Platform.isIOS ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff5b86e5),
            ),
            // children: [
            //   TextSpan(
            //     text: 'Chat',
            //     style: TextStyle(color: Colors.black, fontSize: Platform.isIOS ? 20 : 18),
            //   )
            // ]
          ),
        ),
      ],
    );
  }
}
