import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/boardview/BoardListObject.dart';
import 'package:workcake/components/boardview/CardItem.dart';
import 'package:workcake/components/boardview/card_detail.dart';
// import 'package:workcake/components/boardview/list_card_view.dart';
import 'package:workcake/models/auth_model.dart';
import 'package:workcake/models/boards_model.dart';

import '../../generated/l10n.dart';

class ListUnarchiveCard extends StatefulWidget{
  @override
  _ListUnarchiveCardState createState() => _ListUnarchiveCardState();

}
class _ListUnarchiveCardState extends State<ListUnarchiveCard> {
  TextEditingController renameCardController = TextEditingController();
  TextEditingController searchArchiveController = TextEditingController();
  bool showArchive = false;
  var cardToRename;
  Timer? debounce;

  getArchivedCard() {
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    List archivedCards = Provider.of<Boards>(context, listen: true).archivedCards["${selectedBoard["id"]}"] ?? [];
    List<CardItem> archivedCard = [];
    for (var index = 0; index < archivedCards.length; index++) {
      var e = archivedCards[index];
      CardItem card = CardItem.cardFrom({
        "id": e["id"],
        "title": e["title"],
        "description": e["description"],
        "workspaceId": e["workspace_id"],
        "channelId": e["channel_id"],
        "boardId": e["board_id"],
        "listCardId": e["list_cards_id"],
        "members": e["assignees"],
        "labels": e["labels"],
        "checklists": e["checklists"],
        "attachments": e["attachments"],
        "commentsCount": e["comments_count"],
        "attachmentsCount": e["attachments_count"],
        "tasks": e["tasks"],
        "isArchived": e["is_archived"],
        "priority": e["priority"],
        "dueDate": e["due_date"],
        "author": e["author_id"]
      });
      archivedCard.add(card);
    }

    return archivedCard;
  }
  getArchivedLists() {
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    List archivedLists = Provider.of<Boards>(context, listen: true).archivedLists["${selectedBoard["id"]}"] ?? [];
    return archivedLists;
  }
  onSwitchArchiveList(value) {
    setState(() {
      showArchive = value;
    });
  }

  onArchiveListCard(value, listCard) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    if (value) {
      final listCardIndex = selectedBoard["list_cards"].indexWhere((e) => e["id"] == listCard.id);
      if (listCardIndex == -1) return;
      this.setState(() {
        listCard.isArchived = value;
        selectedBoard["list_cards"][listCardIndex]["isArchived"] = value;
      });
    }

    Provider.of<Boards>(context, listen: false).changeListCardTitle(token, listCard.workspaceId, listCard.channelId, listCard.boardId, listCard.id, listCard.title, value);
  }

  selectCardToRename(card) {
    this.setState(() {
      cardToRename = card != null ? card.id : null;
    });

    if (card != null) {
      renameCardController.text = card.title;
    }
  }
  getPriority(priority) {
    final bool isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    Widget icon = priority == 1 ? Icon(PhosphorIcons.fire, color: Color(0xffFF7875), size: 19) 
      : priority == 2 ? 
        Container(
          height: 28,
          child: Stack(children: [
            Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xffFAAD14))),
            Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xffFAAD14))),
            Positioned(top: 8, child: Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xffFAAD14)))
          ]),
        ) 
      : priority == 3 ? 
        Container(
          height: 22,
          child: Stack(children: [
            Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xff27AE60))),
            Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xff27AE60)))
          ]),
        ) 
      : priority == 4 ? 
        Icon(PhosphorIcons.caretUpThin, size: 18.5, color: Color(0xff69C0FF))
      : Icon(PhosphorIcons.minus, size: 19);

    Widget text = Text(
      priority == 1 ? S.current.urgent : priority == 2 ? S.current.hight : priority == 3 ? S.current.medium : priority == 4 ? S.current.low : S.current.none,
      style: TextStyle(
        color: priority == 1
        ? Color(0xffFF7875)
        : priority == 2
          ? Palette.calendulaGold
          : priority == 3
            ? Color(0xff27AE60)
            : priority == 4
              ? Color(0xff69C0FF)
              : (isDark ? Palette.defaultTextDark : Palette.defaultTextLight)
      )
    );

    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
      icon,
      SizedBox(width: 8),
      text
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    List<CardItem> archivedCards = !showArchive  ? getArchivedCard() : [];
    List archivedLists = showArchive  ? getArchivedLists() : [];
    return Scaffold(
      body: Column(
        children: [
            Container(
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 38),
                Container(
                  height: 57,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 18),
                      Text(S.current.archive, style: TextStyle(fontSize: 16)),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(PhosphorIcons.x, size: 20,color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E)),
                        )
                      ),
                    ]
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 220,
                        height: 36,
                        child: CupertinoTextField(
                          padding: EdgeInsets.only(left: 10, bottom: 3, right: 10),
                          autofocus: false,
                          onChanged: (value) {
                            if (debounce?.isActive ?? false) debounce?.cancel();
                            debounce = Timer(const Duration(milliseconds: 200), () {
                              this.setState(() {});
                            });
                          },
                          controller: searchArchiveController,
                          placeholder: "${S.current.searchArchive}...",
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),)
                          ),
                          style: TextStyle(fontSize: 14, color: isDark ? Palette.defaultTextDark: Palette.defaultTextLight),
                        )
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showArchive = !showArchive;
                          });
                          searchArchiveController.clear();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff3D3D3D) : Colors.white,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          height: 36,
                          width: 130,
                          child: Center(child: Text(showArchive ? S.current.switchToCards : S.current.switchToLists, style: TextStyle(overflow: TextOverflow.ellipsis,),)),
                        )
                      )
                    ]
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child:!showArchive ? Column(
                    children: archivedCards.map<Widget>((CardItem cardItem) {
                      final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;

                      List labels = cardItem.labels.map((e) {
                        var index = selectedBoard["labels"].indexWhere((ele) => ele["id"] == e);
                        if (index == -1) return null;
                        var item = selectedBoard["labels"][index];
                        return Label(
                          colorHex: item["color_hex"],
                          title: item["name"],
                          id: item["id"].toString()
                        );
                      }).toList().where((e) => e != null).toList();

                      bool onSearch = searchArchiveController.text.trim() != "" ?
                      Utils.unSignVietnamese(cardItem.title).contains(Utils.unSignVietnamese(searchArchiveController.text.trim())) : true;
                      return onSearch ? InkWell(
                        onTap: () async {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            enableDrag: true,
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            builder: (BuildContext context) {
                              return CardDetail(card: cardItem);
                            }
                          );
                        },
                        child: Container(
                          width: 340,
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff3D3D3D) : cardItem.isArchived ? Color(0xfff3f3f3) : Colors.white,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          margin: EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                            if(cardItem.priority != null && cardItem.priority != 5) Container(
                              margin: EdgeInsets.only(bottom: 14),
                              height: 24,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  getPriority(cardItem.priority),
                                  ShowMoreCard(context: context, card: cardItem, selectCardToRename: selectCardToRename)
                                ]
                              )
                            ),
                            cardToRename == cardItem.id ?  Container(
                              height: 32,
                              child: Focus(
                                onFocusChange: (focus) {
                                  if (!focus) {
                                    this.setState(() {
                                      cardToRename = null;
                                    });
                                  }
                                },
                                child: TextField(
                                  autofocus: true,
                                  controller: renameCardController,
                                  cursorColor: isDark ? Color(0xffffffff) : Palette.defaultTextLight,
                                  style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: S.current.enterCardTitle,
                                    hintStyle: TextStyle(fontSize: 14),
                                    contentPadding: EdgeInsets.only(left: 8, right: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: isDark ? Palette.calendulaGold : Palette.dayBlue),
                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                    )
                                  ),
                                  onEditingComplete: () {
                                    if (renameCardController.text.trim() != "") {
                                      // onRenameCard(cardItem, renameCardController.text.trim());
                                    }
                                  }
                                )
                              )
                            ) : Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      width: 172,
                                      child: Text(
                                        cardItem.title,
                                        style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                      )
                                    ),
                                    if(cardItem.priority == null || cardItem.priority == 5) ShowMoreCard(context: context, card: cardItem, selectCardToRename: selectCardToRename)
                                  ]
                                )
                              ),
                              if (labels.length > 0) Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(bottom: 4,),
                                child: Wrap(
                                  children: labels.map<Widget>((label) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Color(int.parse("0xFF${label.colorHex}")),
                                        borderRadius: BorderRadius.circular(3)
                                      ),
                                      margin: EdgeInsets.only(right: 8, top: 4),
                                      height: 6,
                                      width: 32
                                    );
                                  }
                                ).toList()
                              )
                            ),
                          ],
                        ),
                      ),
                    ) : Container();
                  }).toList()
                  ) : Column(
                    children: archivedLists.map<Widget>((list) {
                      bool onSearch = searchArchiveController.text.trim() != "" ?
                      Utils.unSignVietnamese(list["title"]).contains(Utils.unSignVietnamese(searchArchiveController.text.trim())) : true;
                      return !onSearch ? Container() : Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        width: 340,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB))
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 340 - 128 - 24,
                              child: Text(list["title"], overflow: TextOverflow.ellipsis)
                            ),
                            InkWell(
                              onTap: () {
                                BoardListObject listCard = BoardListObject(
                                  id: list["id"],
                                  title: list["title"],
                                  workspaceId: list["workspace_id"],
                                  channelId: list["channel_id"],
                                  boardId: list["board_id"],
                                  isArchived: list["is_archived"]
                                );
                                onArchiveListCard(false, listCard);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                height: 32,
                                width: 128,
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xff3D3D3D) : Colors.white,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(PhosphorIcons.arrowUUpLeft, size: 15),
                                      Text(S.current.sendToBoard)
                                    ]
                                  )
                                )
                              ),
                            )
                          ]
                        )
                      );
                    }).toList()
                  )
                )
              ]
            )
          )
        ],
      ),
    );
  }
}
class Label{
  String colorHex;
  String title;
  String id;

  Label({required this.colorHex, required this.title, required this.id});
}

class ShowMoreCard extends StatefulWidget {
  const ShowMoreCard({
    Key? key,
    required this.context,
    this.selectCardToRename,
    this.card
  }) : super(key: key);

  final BuildContext context;
  final card;
  final selectCardToRename;

  @override
  State<ShowMoreCard> createState() => _ShowMoreCardState();
}

class _ShowMoreCardState extends State<ShowMoreCard> {

  onArchiveCard() {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    var payload = {
      "id": card.id,
      "description": card.description,
      "title": card.title,
      "is_archived": !card.isArchived,
      "due_date": card.dueDate != null ? card.dueDate!.toUtc().millisecondsSinceEpoch~/1000 + 86400 : null,
      "priority": card.priority
    };
   Provider.of<Boards>(context, listen: false).updateCardTitleOrDescription(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, payload);
  }

  @override
  Widget build(BuildContext context) {
    CardItem card = widget.card;
    final bool isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showPopover(
            backgroundColor: isDark ? Color(0xff4C4C4C) : Colors.white,
            radius: 4,
            context: context,
            transitionDuration: const Duration(milliseconds: 50),
            direction: PopoverDirection.bottom,
            barrierColor: Colors.transparent,
            width: 154,
            height: 90,
            arrowHeight: 0,
            arrowWidth: 0,
            bodyBuilder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffA6A6A6)),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Column(
                  children: [
                    Divider(color: Color(0xffA6A6A6), thickness: 0.5, height: 0.5),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onArchiveCard();
                      },
                      child: Container(
                        height: 43,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.archive, size: 18),
                            SizedBox(width: 8),
                            Text(card.isArchived ? S.current.unarchiveCard : S.current.archiveCard, style: TextStyle(fontSize: 14))
                          ]
                        )
                      ),
                    ),
                    Divider(color: Color(0xffA6A6A6), thickness: 0.5, height: 0.5),
                    Container(
                      height: 43,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.copy, size: 18),
                          SizedBox(width: 8),
                          Text("duplicated", style: TextStyle(fontSize: 14))
                        ]
                      )
                    )
                  ]
                )
              );
            }
          );
        },
        child: Container(
          height: 26,
          width: 26,
          child: Center(
            child: Icon(CupertinoIcons.ellipsis, color: isDark ? Color.fromARGB(255, 178, 168, 168) : Color.fromARGB(230, 0, 0, 0))
          )
        )
      ),
    );
  }
}