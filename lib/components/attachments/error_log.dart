import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorLog extends StatefulWidget {
  final att;
  ErrorLog({Key? key, this.att}) : super(key: key);

  @override
  State<ErrorLog> createState() => _ErrorLogState();
}

class _ErrorLogState extends State<ErrorLog> {
  @override
  Widget build(BuildContext context) {
    final att = widget.att;

    return Container(
      child: Column(
        children: [
          ...att["data"]!.map((e) {
            int color = 0xffef9a9a;
            if (e["color"].toString().startsWith("#") && e["color"].toString().length == 7) color = int.parse(e["color"].toString().replaceAll("#", "0xff"));
            var index = att["data"].indexOf(e);

            return Container(
              margin: EdgeInsets.only(bottom: index != att["data"].length - 1 ? 10 : 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10, bottom: 2),
                      width: 5,
                      constraints: BoxConstraints(minHeight: 44),
                      decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Text(e["title"].toString(), style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                            )),
                          ),
                          Container(
                            child: Text(e["text"].toString(), style: GoogleFonts.nunito(
                              fontSize: 15,
                            )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            );
          })
        ],
      ),
    );
  }
}