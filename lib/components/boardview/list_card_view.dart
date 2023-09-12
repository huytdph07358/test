import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/boardview/list_unarchive_card.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';
import 'BoardListObject.dart';
import 'CardItem.dart';
import 'board_item.dart';
import 'board_list.dart';
import 'boardview.dart';
import 'boardview_controller.dart';
import 'card_detail.dart';
import 'component/filter_card.dart';
import 'create_card.dart';

class ListCardView extends StatefulWidget {
  ListCardView({
    Key? key,
    this.board
  }) : super(key: key);

  final board;

  @override
  _ListCardViewState createState() => _ListCardViewState();
}

class _ListCardViewState extends State<ListCardView> {
  BoardViewController boardViewController = new BoardViewController();
  List<BoardListObject> listData = [];
  TextEditingController textController = TextEditingController();
  TextEditingController renameCardController = TextEditingController();
  TextEditingController searchArchiveController = TextEditingController();
  Timer? debounce;
  var cardToRename;
  Map filters = {'noMember': false, 'members': [], 'labels': [], 'priority': null, 'text': "", 'dueDate': {}};
  String filterType = 'exact';
  String showArchive = '';

  createNewCard(cardItem, title) {
    final token = Provider.of<Auth>(context, listen: false).token;
    if (title.trim() == "") return;
    Provider.of<Boards>(context, listen: false).createNewCard(token, cardItem.workspaceId, cardItem.channelId, cardItem.boardId, cardItem.listCardId, title);
  }

   getListData() {
    List<BoardListObject> listData = [];
    final data = Provider.of<Boards>(context, listen: false).data;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;
    final index = data.indexWhere((e) => e["id"] == selectedBoard["id"]);
    final listCards = index == -1 ? [] : data[index]["list_cards"];

    listCards.sort((a, b) => (selectedBoard["order"] ?? []).indexWhere((e) => e == a["id"]) > (selectedBoard["order"] ?? []).indexWhere((e) => e == b["id"]) ? 1 : -1);

    if (index == -1) return listData;

    for (var i = 0; i < listCards.length; i++) {
      BoardListObject board = BoardListObject(
        id: listCards[i]["id"],
        title: listCards[i]["title"],
        workspaceId: listCards[i]["workspace_id"],
        channelId: listCards[i]["channel_id"],
        boardId: listCards[i]["board_id"],
        cards: getListCard(listCards[i], i, false),
        isArchived: listCards[i]["is_archived"]
      );
      listData.add(board);
    }

    return listData;
  }

  getListCard(listCards, listIndex, isArchived) {
    List<CardItem> cards = [];

    if (listCards["sort_by"] == "newest") {
      listCards["cards"].sort((a, b) => DateTime.parse(a["inserted_at"]).compareTo(DateTime.parse(b["inserted_at"])));
    } else if (listCards["sort_by"] == "oldest") {
      listCards["cards"].sort((a, b) => -DateTime.parse(a["inserted_at"]).compareTo(DateTime.parse(b["inserted_at"])));
    } else {
      listCards["cards"].sort((a, b) => listCards["order"].indexOf(a["id"]) > listCards["order"].indexOf(b["id"]) ? 1 : -1);
    }

    for (var i = 0; i < listCards["cards"].length; i++) {
      var e = i < listCards["cards"].length ? listCards["cards"][i] : {};
      CardItem card = CardItem.cardFrom({
        "id": e["id"],
        "title": e["title"],
        "description": e["description"],
        "listIndex": listIndex, 
        "itemIndex": i,
        "workspaceId": listCards["workspace_id"],
        "channelId": listCards["channel_id"],
        "boardId": listCards["board_id"],
        "listCardId": listCards["id"],
        "members": e["assignees"],
        "labels": e["labels"],
        "checklists" : e["checklists"],
        "attachments" : e["attachments"],
        "commentsCount" : e["comments_count"],
        "tasks": e["tasks"],
        "isArchived": e["is_archived"],
        "priority": e["priority"],
        "dueDate": e["due_date"]
      });

      if (onPassFilter(card)) {
        cards.add(card);
      }
    }

    return cards;
  }

   onArrangeCard(listIndex, itemIndex, oldListIndex, oldItemIndex, CardItem item) {
    if (listIndex == oldListIndex && itemIndex == oldItemIndex) return;
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    final listCard = selectedBoard["list_cards"].where((e) => e["is_archived"] == false).toList();

    try {
      final card = listCard[oldListIndex]["cards"][oldItemIndex];
      listCard[oldListIndex]["cards"].removeAt(oldItemIndex);
      listCard[listIndex]["cards"].insert(itemIndex, card);
      card["old_list_cards_id"] = listCard[oldListIndex]["id"];
      card["list_cards_id"] = listCard[listIndex]["id"];

      if (listIndex != oldListIndex) {
        updateOrder(listCard[listIndex], card);
        updateOrder(listCard[oldListIndex], card);
      } else {
        if (itemIndex != oldItemIndex) {
          updateOrder(listCard[listIndex], card);
        }
      }
    } catch (e) {
      print("onArrangeCard ${e.toString()}");
    }
  }

  updateOrder(listCard, card) {
    List listOrder = [];
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    final token = Provider.of<Auth>(context, listen: false).token;
    final cards = listCard["cards"];
    for (var i = 0; i < cards.length; i++) {
      listOrder.add(cards[i]["id"]);
    }
    var updateListCard = {
      "id": listCard["id"],
      "order": listOrder
    };

    Provider.of<Boards>(context, listen: false).arrangeCard(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], listCard["id"], updateListCard, card);
  }

  onArrangeCardList(listIndex, oldListIndex) {
    if (listIndex != oldListIndex) {
      try {
        final token = Provider.of<Auth>(context, listen: false).token;
        final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
        final listCard = selectedBoard["list_cards"].where((e) => e["is_archived"] == false).toList();
        var list = listCard[oldListIndex];
        listCard.removeAt(oldListIndex);
        listCard.insert(listIndex, list);
        List listOrder = [];

        for (var i = 0; i < listCard.length; i++) {
          listOrder.add(listCard[i]["id"]);
        }

        Provider.of<Boards>(context, listen: false).arrangeCardList(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], listOrder);
      } catch (e) {
        print("onArrangeCardList ${e.toString()}");
      }
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

  findUser(id) {
    final members = Provider.of<Workspaces>(context, listen: false).members;
    final indexMember = members.indexWhere((e) => e["id"] == id);

    if (indexMember != -1) {
      return members[indexMember];
    } else {
      return {};
    }
  }

  selectCardToRename(card) {
    this.setState(() {
      cardToRename = card != null ? card.id : null;
    });

    if (card != null) {
      renameCardController.text = card.title;
    }
  }

  Widget buildCardItem(CardItem cardItem) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return  BoardItem(
      // onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState? state) {},
      onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex, int? oldItemIndex, BoardItemState? state) {
        var item = listData[oldListIndex!].cards![oldItemIndex!];
        listData[oldListIndex].cards!.removeAt(oldItemIndex);
        listData[listIndex!].cards!.insert(itemIndex!, item);
        onArrangeCard(listIndex, itemIndex, oldListIndex, oldItemIndex, item);
      },
      onTapItem: (int? listIndex, int? itemIndex, BoardItemState? state) async {
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
      item: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff4C4C4C) : Color(0xf3f3f3f3),
          borderRadius: BorderRadius.circular(4)
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        margin: EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cardItem.priority != null && cardItem.priority != 5) Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: getPriority(cardItem.priority)
                ),
                Container(
                  width: 144,
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    cardItem.title,overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ]
            ),
            ShowMoreCard(context: context, card: cardItem, selectCardToRename: selectCardToRename)
          ],
        )
      )
    );
  }

  showModalCreateCard(context, listCardId) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return CreateCard(listCardId: listCardId);
      }
    );
  }  

  Widget _createCardList(BoardListObject listCard) {
    List<BoardItem> cards = [];
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    for (int i = 0; i < listCard.cards!.length; i++) {
      cards.insert(i, buildCardItem(listCard.cards![i]) as BoardItem);
    }
    return BoardList(
      onStartDragList: (int? listIndex) {

      },
      onTapList: (int? listIndex) async {

      },
      onDropList: (int? listIndex, int? oldListIndex) {
        var list = listData[oldListIndex!];
        listData.removeAt(oldListIndex);
        listData.insert(listIndex!, list);
        onArrangeCardList(listIndex, oldListIndex);
      },
      backgroundColor: Color.fromARGB(255, 235, 236, 240),
      header: [
        Expanded(
          child: Container(
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
            padding: EdgeInsets.only(top: 6, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  listCard.title!,
                  style: TextStyle(fontSize: 14, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))
                ),
                InkWell(
                  onTap: () {
                    showModalCreateCard(context, listCard.id);
                  },
                  child: Icon(PhosphorIcons.plus, size: 19, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))
                ),
              ]
            )
          )
        )
      ],
      items: cards,
    );
  }

  onCreateNewList() {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
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
            color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
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
                    Text(S.current.newList),
                    InkWell(
                      onTap: () { 
                        if (textController.text.trim() != "") {
                          final token = Provider.of<Auth>(context, listen: false).token;
                          Provider.of<Boards>(context, listen: false).createNewCardList(token, widget.board["workspace_id"], widget.board["channel_id"], widget.board["id"], textController.text.trim());
                        }
                        textController.clear();
                        Navigator.pop(context); 
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
                  autofocus: true,
                  controller: textController,
                  padding: EdgeInsets.only(left: 12),
                  placeholder: S.current.nameList,
                  placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontSize: 14),
                  style: TextStyle(color: Color(0xffDBDBDB), fontSize: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff5E5E5E)),
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffDBDBDB)
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

  onChangeFilter(key, value) {
    switch (key) {
      case "text":
        filters["text"] = value.toLowerCase();
        break;

      case "noMember":
        filters["noMember"] = !filters["noMember"];
        filters['members'] = [];
        break;

      case "member":
        final index = filters['members'].indexWhere((e) => e == value);
        if (index == -1) {
          filters['members'].add(value);
          filters["noMember"] = false;
        } else {
          filters['members'].removeAt(index);
        }
        break;

      case "label":
        final index = filters['labels'].indexWhere((e) => e == value);
        if (index == -1) {
          filters['labels'].add(value);
        } else {
          filters['labels'].removeAt(index);
        }
        break;

      case "priority":
        filters["priority"] = filters["priority"] == value ? null : value;
        break;

      case "dueDate":
        filters["dueDate"] = value;
        break;

      default:
        break;
      }

    this.setState(() {});
  }

  onPassFilter(CardItem card) {
    bool passAllFilter = true;
    bool passText = false;
    bool passNoMember = false;
    bool passMember = false;
    bool passLabel = false;
    bool passPriority = false;
    bool passDueDate = false;

    filters.forEach((key, value) {
      switch (key) {
        case "text":
          if (value.trim() != "") {
            if(!Utils.unSignVietnamese(card.title.toLowerCase()).contains(value)
              && !card.title.toLowerCase().contains(value)
              && !card.description.toLowerCase().contains(value)
              && !Utils.unSignVietnamese(card.description.toLowerCase()).contains(value)) {
              passAllFilter = false;
            } else {
              passText = true;
            }
          }
          break;

        case "noMember":
          if (value) {
            if (card.members.length > 0) {
              passAllFilter = false;
            } else {
              passNoMember = true;
            }
          }
          break;

        case "members":
          for (var i = 0; i < value.length; i++) {
            if (card.members.contains(value[i]) == false) {
              passAllFilter = false;
            } else {
              passMember = true;
            }
          }
          break;

        case "labels":
					for (var i = 0; i < value.length; i++) {
            if (card.labels.contains(value[i]) == false) {
              passAllFilter = false;
            } else {
              passLabel = true;
            }
          }
          break;

				case "priority":
					if (value != null) {
						if (value == 5) {
							if (card.priority != 5 && card.priority != null) {
								passAllFilter = false;
							} else {
                passPriority = true;
              }
						} else {
							if (card.priority != value) {
								passAllFilter = false;
							} else {
                passPriority = true;
              }
						}
					}
					break;
        
        case "dueDate":
          bool passNoDueDate = true;
          bool passOverdue = true;
          bool passAfter = true;
          bool passBefore = true;


          if (value["type"] == "noDueDate") {
            if (card.dueDate != null) {
              passAllFilter = false;
              passNoDueDate = false;
            }
          } else {
            if (value["type"] == "overdue") {
              if (card.dueDate == null) {
                passAllFilter = false;
                passOverdue = false;
              } else {
                if (DateTime.now().compareTo(card.dueDate!) == -1) {
                  passAllFilter = false;
                  passOverdue = false;
                }
              }
            }

            if (value["after"] != null) {
              if (card.dueDate == null) {
                passAllFilter = false;
              } else {
                if(card.dueDate!.compareTo(DateTime.parse(value["after"])) == -1) {
                  passAllFilter = false;
                  passAfter = false;
                }
              }
            }

            if (value["before"] != null) {
              if (card.dueDate == null) {
                passAllFilter = false;
              } else {
                if(card.dueDate!.compareTo(DateTime.parse(value["before"])) == 1) {
                  passAllFilter = false;
                  passBefore = false;
                }
              }
            }
            passDueDate = passAfter && passBefore && passNoDueDate && passOverdue;
          }
          break;

        default:
          break;
      }
    });

    if (filterType == "exact") {
  	  return passAllFilter;
    } else {
      return (passText || passPriority || passLabel || passMember || passNoMember || passDueDate);
    }
  }

  onChangeFilterType(type) {
    print(type);
    this.setState(() {
      filterType = type;
    });
  }

  showDialogFilter(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
           insetPadding: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            height: MediaQuery.of(context).size.height - 60,
            child: FilterCard(
              filters: filters, 
              onChangeFilter: onChangeFilter, 
              onChangeFilterType: onChangeFilterType, 
              filterType: filterType,
              resetFilters: resetFilters
            )
          )
        );
      }
    );
  }

  checkOnFilter() {
    if (filters["noMember"] == true || filters["members"].length > 0 || filters["labels"].length > 0 || filters["priority"] != null || filters["dueDate"].isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  resetFilters() {
    this.setState(() {
      filters["noMember"] = false;
      filters["members"] = [];
      filters["labels"] = [];
      filters["priority"] = null;
      filters["dueDate"] = {};
    });
  }


  // showListUnAchive() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     enableDrag: true,
  //     context: context,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //     builder: (BuildContext context) {
  //       return ListUnarchive();
  //     }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;
    final bool isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;

    List<BoardList> _lists = [];
    listData = getListData();

    for (int i = 0; i < listData.length; i++) {
      _lists.add(_createCardList(listData[i]) as BoardList);
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
        title: Text(selectedBoard["title"], style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), fontSize: 15)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), size: 19),
          onPressed: () => Navigator.of(context).pop()
        ), 
        actions: [
          Center(
            child: InkWell(
              onTap: () { 
                onCreateNewList();
              },
              child: Container(
                height: 60,
                width: 60, 
                child: Icon(PhosphorIcons.plus, size: 19, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))
              )
            )
          )
        ],
        bottom: PreferredSize(
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            height: 44,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
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
                            InkWell(
                              onTap: () {
                                showDialogFilter(context) ;
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 2), 
                                child: Icon(PhosphorIcons.funnel, size: 16, color: checkOnFilter() ? isDark ? Palette.calendulaGold : Colors.blueAccent : isDark ? Color(0xffDBDBDB):Color(0xff5E5E5E))
                              )
                            ),
                          ]
                        )
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff444444) : Color(0xffF3F3F3),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      onChanged: (value) {
                        if (debounce?.isActive ?? false) debounce?.cancel();
                        debounce = Timer(const Duration(milliseconds: 300), () {
                          onChangeFilter("text", value);
                        });
                      }
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ListUnarchiveCard(), fullscreenDialog: true)
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 60, 
                    child: Icon(PhosphorIcons.archive, size: 19, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))
                  )
                ),
              ],
            )
          ),
          preferredSize: Size.fromHeight(28)
        )
      ),
      body: Container(
        color: isDark ? Color(0xff3D3D3D) : Color(0xffC9C9C9),
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: deviceHeight,
              width: deviceWidth,
              child: BoardView(
                width: deviceWidth*.9,
                lists: _lists,
                boardViewController: boardViewController,
                dragDelay: 300
              )
            )
          ]
        )
      )
    );
  }
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
