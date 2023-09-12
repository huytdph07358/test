// ignore_for_file: must_call_super

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

import 'board_item.dart';
import 'boardview.dart';

typedef void OnDropList(int? listIndex,int? oldListIndex);
typedef void OnTapList(int? listIndex);
typedef void OnStartDragList(int? listIndex);

class BoardList extends StatefulWidget {
  final List<Widget>? header;
  final Widget? footer;
  final List<BoardItem>? items;
  final Color? backgroundColor;
  final BoardViewState? boardView;
  final OnDropList? onDropList;
  final OnTapList? onTapList;
  final OnStartDragList? onStartDragList;
  final bool draggable;

  const BoardList({
    Key? key,
    this.header,
    this.items,
    this.footer,
    this.backgroundColor,
    this.boardView,
    this.draggable = true,
    this.index, this.onDropList, this.onTapList, this.onStartDragList,
  }) : super(key: key);

  final int? index;

  @override
  State<StatefulWidget> createState() {
    return BoardListState();
  }
}

class BoardListState extends State<BoardList> with AutomaticKeepAliveClientMixin{
  List<BoardItemState> itemStates = [];
  ScrollController boardListController = new ScrollController();

  void onDropList(int? listIndex) {
    if(widget.onDropList != null){
      widget.onDropList!(listIndex,widget.boardView!.startListIndex);
    }
    widget.boardView!.draggedListIndex = null;
    if(widget.boardView!.mounted) {
      widget.boardView!.setState(() {

      });
    }
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.boardView != null && widget.draggable) {
      if(widget.onStartDragList != null){
        widget.onStartDragList!(widget.index);
      }
      widget.boardView!.startListIndex = widget.index;
      widget.boardView!.height = context.size!.height;
      widget.boardView!.draggedListIndex = widget.index!;
      widget.boardView!.draggedItemIndex = null;
      widget.boardView!.draggedItem = item;
      widget.boardView!.onDropList = onDropList;
      widget.boardView!.run();
      if(widget.boardView!.mounted) {
        widget.boardView!.setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  createNewCard(title) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    

    if (widget.index == null) return;

    final listCardId = selectedBoard["list_cards"][widget.index]["id"];
    final index = selectedBoard["list_cards"][widget.index]["cards"].indexWhere((e) => e["title"].trim() == title.trim());

    if (index != -1) return;
    
    if (title.trim() == "") return;

    await Provider.of<Boards>(context, listen: false).createNewCard(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], listCardId, title);
    setState(() {
      controller.clear();
      onAddCard = false;
    });
  }

  bool onAddCard = false;
  TextEditingController controller = TextEditingController();
  Timer? timer;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    List<Widget> listWidgets = [];

    if (widget.header != null) {
      listWidgets.add(GestureDetector(
        onTap: (){
          if(widget.onTapList != null){
            widget.onTapList!(widget.index);
          }
        },
        onTapDown: (otd) {
          if(widget.draggable) {
            RenderBox object = context.findRenderObject() as RenderBox;
            Offset pos = object.localToGlobal(Offset.zero);
            widget.boardView!.initialX = pos.dx;
            widget.boardView!.initialY = pos.dy;

            widget.boardView!.rightListX = pos.dx + object.size.width;
            widget.boardView!.leftListX = pos.dx;
          }
        },
        onTapCancel: () {},
        onLongPress: () {
          timer = Timer(Duration(milliseconds: 200), () async { 
            if(!widget.boardView!.widget.isSelecting && widget.draggable) {
              HapticFeedback.mediumImpact();
              _startDrag(widget, context);
            }
          });
        },
        onPanCancel: () => timer?.cancel(),
        child: Container(
          color: Color(0xff2E2E2E),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.header!
          )
        )
      ));
    }
    if (widget.items != null) {
      listWidgets.add(
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            controller: boardListController,
            itemCount: widget.items!.length,
            itemBuilder: (ctx, index) {
              if (widget.items![index].boardList == null ||
                  widget.items![index].index != index ||
                  widget.items![index].boardList!.widget.index != widget.index 
                ) {
                widget.items![index] = new BoardItem(
                  boardList: this,
                  item: widget.items![index].item,
                  draggable: widget.items![index].draggable,
                  index: index,
                  onDropItem: widget.items![index].onDropItem,
                  onTapItem: widget.items![index].onTapItem,
                  onDragItem: widget.items![index].onDragItem,
                  onStartDragItem: widget.items![index].onStartDragItem,
                );
              }
              if (widget.boardView!.draggedItemIndex == index &&
                  widget.boardView!.draggedListIndex == widget.index) {
                return Opacity(
                  opacity: 0.0,
                  child: widget.items![index],
                );
              } else {
                return widget.items![index];
              }
            }
          )
        )
      );
    }

    if (widget.footer != null) {
      listWidgets.add(widget.footer!);
    }

    if (widget.boardView!.listStates.length > widget.index!) {
      widget.boardView!.listStates.removeAt(widget.index!);
    }
    widget.boardView!.listStates.insert(widget.index!, this);

    return Container(
      margin: EdgeInsets.only(left: widget.index == 0 ? 16 : 0, right: widget.index == widget.boardView!.listStates.length - 1 ? 16 : 12, top: 12, bottom: 24),
      padding: EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 2),
      decoration: BoxDecoration(color: isDark ? Color(0xff2E2E2E) : Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: listWidgets
      )
    );
  }
}
