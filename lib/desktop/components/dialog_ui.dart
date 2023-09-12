import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:workcake/service_locator.dart';

enum DialogType{error}


void setupDialogUI(){
  final dialogService = sl<DialogService>();
  final builders = {
    DialogType.error: (context, sheetRequest, completer) =>
        _ErrorDialog(request: sheetRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
class _ErrorDialog extends StatelessWidget {
  final request;
  final completer;
  const _ErrorDialog({Key? key, this.request, this.completer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      animationDuration: Duration(milliseconds: 500),
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            top: 80,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10.0, offset: Offset(1,2))],
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Color(0xffEE3B3B)
              ),
              width: 400,
              height: 70,
              padding: EdgeInsets.all(20),
              child: Center(child: Text(request.customData))
            ),
          ),
        ],
      ),
    );
  }
}
