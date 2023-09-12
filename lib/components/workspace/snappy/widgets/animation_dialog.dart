import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/models/models.dart';

class RequestConfirmDialog extends FunkyOverlay {
  final String information;
  final Function onAccepted;
  final Function onDenied;

  RequestConfirmDialog({required this.information, required this.onAccepted, required this.onDenied});
  
  @override
  State<StatefulWidget> createState() => _RequestConfirmDialogState();
}

class _RequestConfirmDialogState extends _FunkyOverlayState<RequestConfirmDialog> {
  @override
  Widget? get child {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.information),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(2.0),
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                foregroundColor: MaterialStateProperty.all(Colors.black)
              ),
              onPressed: () => {
                widget.onDenied.call(),
                Navigator.pop(context),
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) {
                    return InformationDialog(information: "Denied success!");
                  }
                )
              }, 
              child: Text("Deny")
            ),
            SizedBox(width: 50),
            TextButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(2.0),
                backgroundColor: MaterialStateProperty.all(Colors.blue.shade400),
                foregroundColor: MaterialStateProperty.all(Colors.black)
              ),
              onPressed: () => {
                widget.onAccepted.call(),
                Navigator.pop(context),
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) {
                    return InformationDialog(information: "Accepted success!");
                  }
                )
              },
              child: Text("Accept")
            )
          ],
        ),
      ],
    );
  }
}

class ActionDialog extends FunkyOverlay {
  final Widget child;

  ActionDialog({required this.child});
  @override
  State<StatefulWidget> createState() => ActionDialogState();

}

class ActionDialogState extends _FunkyOverlayState<ActionDialog> {
  @override
  Widget? get child => widget.child;
}

class InformationDialog extends FunkyOverlay {
  final String information;

  InformationDialog({required this.information});
  @override
  State<StatefulWidget> createState() => InformationDialogState();
}

class InformationDialogState extends _FunkyOverlayState<InformationDialog> {
  @override
  Widget? get child => Text(widget.information, style: TextStyle(fontSize: 20, color: Colors.green));
}

abstract class FunkyOverlay extends StatefulWidget {
  const FunkyOverlay({Key? key}) : super(key: key);
}

abstract class _FunkyOverlayState<T extends FunkyOverlay> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  Widget? child;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    controller.addListener(() => setState(() {}));
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<Auth>().theme == ThemeType.DARK;
    return Center(
      child: Theme(
        data: (isDark
        ? Themes.darkTheme
        : Themes.lightTheme).copyWith(textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        )),
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              decoration: ShapeDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: child
              ),
            ),
          ),
        ),
      ),
    );
  }
}