import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/models/models.dart';

class MarkdownCheckbox extends StatefulWidget {
  const MarkdownCheckbox({
    Key? key,
    required this.value,
    required this.variable,
    required this.onChangeCheckBox,
    this.isBlockCheckBox = false,
    this.commentId,
    required this.index
  }) : super(key: key);

  final value;
  final variable;
  final Function onChangeCheckBox;
  final commentId;
  final bool isBlockCheckBox;
  final int index;

  @override
  _MarkdownCheckboxState createState() => _MarkdownCheckboxState();
}

class _MarkdownCheckboxState extends State<MarkdownCheckbox> {
  var value;

  @override
  void initState() {
    super.initState();
    this.setState(() {
      value = widget.value;
    });
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value;
    } 
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;

    return Container(
      margin: EdgeInsets.only(right: 6),
      child: Transform.scale(
        scale: 1,
        child: SizedBox(
          height: 15.0,
          width: 24.0,
          child: Checkbox(
            onChanged: widget.isBlockCheckBox ? null : (newValue) {
              this.setState(() { value = newValue; });
              widget.onChangeCheckBox(newValue, widget.variable, widget.commentId, widget.index);
            },
            value: value,
            activeColor: isDark ? Palette.calendulaGold : Palette.dayBlue,
            checkColor: isDark ? Colors.black : Colors.white,
          )
        ),
      ),
    );
  }
}