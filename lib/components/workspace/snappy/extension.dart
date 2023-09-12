import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/workspace/snappy/widgets/animation_dialog.dart';
import 'package:workcake/models/models.dart';

extension ShowDialogContext on BuildContext {
  Future<void> showCustomDialog({child}) async {
    await showCupertinoDialog(
      context: this,
      barrierDismissible: true,
      builder: (_) => ActionDialog(
        child: child,
      )
    );
  }
  Future<void> showDialog({icon, iconColor, message}) async {
    await showCupertinoDialog(
      barrierDismissible: true,
      context: this,
      builder: (_) => ActionDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor),
          SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ))
    );
  }
  Future<void> showDialogWithSuccess(message) async {
    await this.showDialog(
      icon: CupertinoIcons.checkmark_circle_fill, 
      iconColor: Colors.green,
      message: message
    );
  }
  Future<void> showDialogWithFailure(message) async {
    await this.showDialog(
      icon: CupertinoIcons.xmark_circle_fill, 
      iconColor: Colors.red, 
      message: message
    );
  }
  Future<void> showLoadingDialog() async {
    await showCupertinoDialog(
      barrierDismissible: true,
      context: this,
      builder: (_) => SimpleDialog(
      children: <Widget>[
        Center(
          child: Container(
            child: CircularProgressIndicator()
          )
        )
      ])
    );
  }
  Future<void> showActionDialog({required String message, required String actionText, required void Function() action}) async {
    final isDark = this.read<Auth>().theme == ThemeType.DARK;
    await showCupertinoDialog(
      context: this,
      barrierDismissible: true,
      builder: (_) => ActionDialog(
      child: SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.exclamationmark_shield_fill, color: Colors.red),
            SizedBox(height: 10),
            Text(message),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(right: 12),
              child: OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Palette.calendulaGold),
                ),
                onPressed: action,
                child: Text(
                  actionText,
                  style: TextStyle(color: isDark ? Palette.darkPrimary : Palette.defaultTextLight)
                ),
              ),
            ),
          ],
        ),
      ))
    );
  }
}