
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

import 'list_card_view.dart';

class ListBoardItems extends StatefulWidget {
  const ListBoardItems({
    Key? key,
    this.workspaceId,
    this.channelId
  }) : super(key: key);

  final workspaceId;
  final channelId;

  @override
  State<ListBoardItems> createState() => _ListBoardItemsState();
}

class _ListBoardItemsState extends State<ListBoardItems> {
  @override
  void initState() { 
    super.initState();
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    Provider.of<Boards>(context, listen: false).getListBoards(token, currentWorkspace["id"], currentChannel["id"]).then((e) {
      if (!mounted) return;
      try {
        final data = Provider.of<Boards>(context, listen: false).data;
        if (data.length > 0) {
          Provider.of<Boards>(context, listen: false).onChangeBoard(data[data.length - 1]);
        }
      } catch (e) {
        print("init list board item ${e.toString()}");
      }
    });
  }

  @override
  void didUpdateWidget (oldWidget) {
    if ((oldWidget.workspaceId != null && oldWidget.workspaceId != widget.workspaceId) || (oldWidget.channelId != null && oldWidget.channelId != widget.channelId)) {
      final token = Provider.of<Auth>(context, listen: false).token;
      final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
      final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

      Provider.of<Boards>(context, listen: false).getListBoards(token, currentWorkspace["id"], currentChannel["id"]).then((e) {
        final data = Provider.of<Boards>(context, listen: false).data;
        if (data.length > 0) {
          Provider.of<Boards>(context, listen: false).onChangeBoard(data[data.length - 1]);
        }
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Boards>(context, listen: true).data;

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 96),
      child: SingleChildScrollView(
        child: Column(
          children: data.reversed.map((e) {
            return ListBoardItem(board: e);
          }).toList()
        ),
      )
    );
  }
}

class ListBoardItem extends StatefulWidget {
  const ListBoardItem({
    Key? key,
    required this.board,
  }) : super(key: key);

  final Map board;

  @override
  State<ListBoardItem> createState() => _ListBoardItemState();
}

class _ListBoardItemState extends State<ListBoardItem> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    textController.text = widget.board["title"];
  }

  onChangeBoardInfo() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    if (textController.text.trim() == "") return;
    this.setState(() {
      widget.board["title"] = textController.text.trim();
    });
    var newBoard = {...widget.board, "title": textController.text.trim()};
    Provider.of<Boards>(context, listen: false).changeBoardInfo(token, currentWorkspace["id"], currentChannel["id"], newBoard);
    Navigator.pop(context);
  }

  onRenameBoard() {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      builder: (BuildContext context) {
        return Container(
          padding: (MediaQuery.of(context).viewInsets),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Color(0xff3D3D3D) 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xff828282),
                    borderRadius: BorderRadius.circular(100)
                  )
                )
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(onTap: () { Navigator.pop(context); }, child: Text("${widget.board["title"]}")),
                    InkWell(
                      onTap: () {
                        onChangeBoardInfo();
                      },
                      child: Text("Done", style: TextStyle(color: Color(0xffFAAD14)))
                    )
                  ]
                )
              ),
              Divider(height: 24, color: Color(0xff5E5E5E)),
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoTextField(
                  autofocus: true,
                  controller: textController,
                  padding: EdgeInsets.only(left: 12),
                  placeholder: "Name Board",
                  placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontSize: 14),
                  style: TextStyle(color: Color(0xffDBDBDB), fontSize: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff5E5E5E)),
                    borderRadius: BorderRadius.circular(4),
                    color: Color(0xff2E2E2E)
                  )
                )
              ),
              SizedBox(height: 18)
            ]
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      height: 44,
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff444444) : Color(0xffDBDBDB),
        borderRadius: BorderRadius.circular(4)
      ),
      child: InkWell(
        onTap: () {  
          Provider.of<Boards>(context, listen: false).onChangeBoard(widget.board);
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => ListCardView(board: widget.board), fullscreenDialog: true)
          );
        },
        onLongPress: () {
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: Text("${widget.board["title"]}", style: TextStyle(color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E), fontSize: 16, fontWeight: FontWeight.w500)),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    onRenameBoard();
                  },
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(PhosphorIcons.pencilSimpleLine, size: 18, color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E)),
                      SizedBox(width: 10),
                      Text('Rename', style: TextStyle(color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E), fontSize: 16)),
                    ],
                  ),
                ),
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(PhosphorIcons.archive, size: 18, color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E)),
                      SizedBox(width: 10),
                      Text(S.current.archive, style: TextStyle(color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E), fontSize: 16)),
                    ]
                  )
                )
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text(S.current.cancel, style: TextStyle(color: isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E), fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context);
                }
              )
            )
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.board["title"], style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), fontSize: 14))
          ]
        )
      )
    );
  }
}