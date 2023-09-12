import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class EditTitle extends StatefulWidget {
  const EditTitle({
    Key? key,
    this.title,
    this.onEditTitle,
    this.onFocusTitleChange
  }) : super(key: key);

  final title;
  final onEditTitle;
  final Function(bool)? onFocusTitleChange;

  @override
  State<EditTitle> createState() => _EditTitleState();
}

class _EditTitleState extends State<EditTitle> {
  
  TextEditingController titleController = TextEditingController();
  FocusNode titleNode = FocusNode();
  bool editTitle = false;

  @override
  void initState() {
    titleController.text = widget.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    double deviceWidth = MediaQuery.of(context).size.width;
    

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
          bottom: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
        ),
      ),
      child: Wrap(
        children: [
          Container(
            height: 44,
            width: deviceWidth,
            color: isDark ? Color(0xff4C4C4C) : Color(0xffffffff),
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            child: Text(S.current.title, style: TextStyle(fontSize: 14))
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18),
            height: 44,
            color: isDark ? Color(0xff3D3D3D) : Color(0xffffffff),
            child: Focus(
              onFocusChange: ((value) {
                if (widget.onFocusTitleChange != null) widget.onFocusTitleChange!(value);
                if(!value) {
                  widget.onEditTitle(titleController.text);
                }
              }),
              child: Center(
                child: CupertinoTextField(
                  style: TextStyle(fontSize: 14, color: isDark ? Color(0xffC9C9C9):Color(0xff5E5E5E)),
                  cursorColor: Color(0xffFAAD14),
                  controller: titleController,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff3D3D3D) : Color(0xffffffff),
                  ),
                  onSubmitted: (value) {
                    widget.onEditTitle(value);
                  },
                  focusNode: titleNode,
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
