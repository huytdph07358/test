import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

import 'BoardListObject.dart';
import 'list_board_item.dart';

// ignore: must_be_immutable
class BoardViewScreen extends StatefulWidget {
  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  List<BoardListObject> listData = [];
  TextEditingController textController = TextEditingController();

  createNewBoard(context) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    if (textController.text.trim() != "") {
      Provider.of<Boards>(context, listen: false).createNewBoard(token, currentWorkspace["id"], currentChannel["id"], textController.text);
      textController.clear();
      Navigator.pop(context);
    }
  }

  onCreateBoard() {
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
                    InkWell(onTap: () { Navigator.pop(context); }, child: Text(S.current.createBoard)),
                    InkWell(
                      onTap: () {
                        createNewBoard(context);
                      },
                      child: Text(S.current.done, style: TextStyle(color: Color(0xffFAAD14)))
                    )
                  ]
                )
              ),
              Divider(height: 24, color: Color(0xff5E5E5E)),
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoTextField(
                  controller: textController,
                  padding: EdgeInsets.only(left: 12),
                  placeholder: S.current.nameBoard,
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
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;

    return Scaffold(
      backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
        title: Text(S.current.boards, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), fontSize: 15)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), size: 19),
          onPressed: () => Navigator.of(context).pop()
        ), 
        actions: [
          Center(
            child: InkWell(
              onTap: () { },
              child: Container(
                height: 60,
                width: 60, 
                child: Icon(PhosphorIcons.archive, size: 19, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))
              )
            )
          )
        ],
        bottom: PreferredSize(
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))),
            padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
            height: 44,
            width: MediaQuery.of(context).size.width,
            child: CupertinoTextField(
              padding: EdgeInsets.only(left: 8),
              placeholder: S.current.search,
              placeholderStyle: TextStyle(fontSize: 13, color: Color(0xffA6A6A6)),
              style: TextStyle(fontSize: 13, color: Color(0xffA6A6A6)),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(PhosphorIcons.magnifyingGlass, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), size: 16)
              ),
              suffix: Container(
                padding: EdgeInsets.only(right: 12, left: 12, bottom: 4),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(margin: EdgeInsets.only(top: 4), height: 12, decoration: BoxDecoration(border: Border(left: BorderSide(color: Color(0xff5E5E5E))))),
                    SizedBox(width: 10),
                    Container(margin: EdgeInsets.only(top: 2), child: Icon(PhosphorIcons.funnel, size: 16, color:isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))),
                  ]
                )
              ),
              decoration: BoxDecoration(
                color: isDark ? Color(0xff444444) : Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(16)
              )
            )
          ),
          preferredSize: Size.fromHeight(28)
        )
      ),
      body: Stack(
        children: [
          ListBoardItems(workspaceId: currentWorkspace["id"], channelId: currentChannel["id"]),
          Positioned(
            bottom: 18,
            child: Container(
              height: 72,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: () {
                  onCreateBoard();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Color(0xffFAAD14)
                  ),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.plus, color: Color(0xff2E2E2E), size: 19),
                      SizedBox(width: 10),
                      Text(S.current.newBoards, style: TextStyle(color: Color(0xff2E2E2E), fontWeight: FontWeight.w500))
                    ]
                  )
                ),
              )
            )
          )
        ]
      )
    );
  }
}

class ButtonAddCardList extends StatefulWidget {
  const ButtonAddCardList({
    Key? key,
  }) : super(key: key);

  @override
  State<ButtonAddCardList> createState() => _ButtonAddCardListState();
}

class _ButtonAddCardListState extends State<ButtonAddCardList> {
  bool onAddCard = false;
  final controller = TextEditingController();

  createNewCardList(token, workspaceId, channelId, boardId, title) async {
    if (title.trim() == "") return;
    await Provider.of<Boards>(context, listen: false).createNewCardList(token, workspaceId, channelId, boardId, title);
    controller.clear();
    onAddCard = false;
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: true).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;
    final data = Provider.of<Boards>(context, listen: true).data;

    return data.length == 0 ? Container() : InkWell(
      onTap: () { 
        // showDialogCreateCardList(context);
      },
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        width: 100,
        height: onAddCard ? 80 : 30,
        decoration: BoxDecoration(
          color: onAddCard ? Colors.white : Color.fromARGB(255, 235, 236, 240),
          borderRadius: BorderRadius.circular(2)
        ),
        child: !onAddCard ? Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey[700], size: 18),
            Text(" ${S.current.addNewList}", style: TextStyle(color: Colors.grey[800], fontSize: 13)),
          ],
        ) : Container(
          padding: EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoTextField(
                padding: EdgeInsets.all(4),
                autofocus: true,
                controller: controller,
                placeholder: S.current.enterListTitle,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.blueGrey[300]!)
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    color: Colors.lightBlue,
                    child: TextButton(
                      onPressed: (){
                        createNewCardList(token, currentWorkspace["id"], currentChannel["id"], selectedBoard["id"], controller.text);
                      }, 
                      child: Text(S.current.addList, style: TextStyle(color: Colors.white))
                    ),
                  ),
                  SizedBox(width: 12),
                  InkWell(
                    onTap: () {onAddCard = false;},
                    child: Icon(Icons.close, color: Colors.grey[600], size: 20)
                  )
                ]
              )
            ]
          )
        )
      ),
    );
  }
}