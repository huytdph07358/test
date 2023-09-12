import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/message.dart';

class SearchBarNavigation2 extends StatefulWidget {
  const SearchBarNavigation2({ Key? key, required this.currentWorkspaceId }) : super(key: key);
  final currentWorkspaceId;
  @override
  _SearchBarNavigation2State createState() => _SearchBarNavigation2State();
}

class _SearchBarNavigation2State extends State<SearchBarNavigation2> {
  bool isSearchMessageView = false;
  final TextEditingController _searchQuery = new TextEditingController();
  var _debounce;

  List messages = [];
  List allContact = [];
  List allUser = [];
  List contacts = [];
  List channels = [];
  List listChannel = [];
  List workspaces = [];
  bool loading = false;
  String? searchType = "contact";
  int  lastLength = 0;
  bool isFetching = false;
  FocusNode _focusNode = FocusNode();
  bool searched = true;
  List listDirectModel = [];

  Box? localSearch;
  int selectItem = -1;
  List channelIds = [];
  Map? date;
  List userIds = [];

  // Chuyển trạng thái search
  changeSearchType(value) {
    if(value != searchType) {
      setState(() {
        searchType = value;
      });
      if(searched == false) {
        onSearchChanged(searchType);
      }
    }
  }

  onSearchChanged(searchType) {
    final token = Provider.of<Auth>(context, listen: false).token;
    if(_searchQuery.text.trim() == "") {
      setState(() {
        contacts = [];
        messages = [];
        workspaces = [];
        channels = [];
        loading = false;
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(searchType == "contact" ? Duration(milliseconds: 100) : Duration(milliseconds: 1000), () {
      if (!this.mounted) return;
      setState(() { 
        if(searchType != "contact") loading = true;
        searched = false;
      });
      search(_searchQuery.text, token, searchType);
    });
  }

  onSelectRecentSearch(Map recent) {
    _focusNode.unfocus();
    _searchQuery.text = recent["text"];
    onFieldSubmitted(_searchQuery.text);
  }

  Map getChannel(channelId, workspaceId){
    final channels = Provider.of<Channels>(context, listen: false).data;
    final index = channels.indexWhere((element) => element['id'] == channelId && element['workspace_id'] == workspaceId);
    if (index != -1) return channels[index];
    return {};
  }

  initLocalBox() async {
    localSearch = await Hive.openBox("localSearch");
  }

  //Lưu trữ local recentSearch
  saveLocalSearch(stringSearch, {where}) {
    final currentUserId = Provider.of<User>(context, listen: false).currentUser["id"];
    List listSearch = localSearch?.get(currentUserId, defaultValue: []);
    final index = listSearch.indexWhere((element) => element["text"].toString() == stringSearch);
    if(index != -1) {
      listSearch.removeAt(index);
    }
    else {
      if (listSearch.length > 10)
      for (int i = 0 ; i < listSearch.length; i ++) {
        if (i == listSearch.length - 1) {
          listSearch.removeAt(i);
        }
      }
    }
    listSearch.insert(0, {
      where["type"]: where['where'],
      'text': stringSearch
    });
    localSearch?.put(currentUserId, listSearch);
  }

  //Submit search query
  onFieldSubmitted(searchString, {type = ""}) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    saveLocalSearch(searchString, where: {'type': 'typing', 'where': ''});
    if(searchType == "contact") setState(() {
      searchType = "message";
    });
    if(isSearchMessageView == false) {
      setState(() {
        loading = true;
        isSearchMessageView = true;
      });
    }
    await search(_searchQuery.text, token, "all_message");
   
  }

  onFocusChange() {
    if(_focusNode.hasPrimaryFocus) {
      setState(() {
        isSearchMessageView = false;
      });
      onSearchChanged("contact");
    }
  }

  Future<void> search(value, token, searchType, {offset = 0, loadMore = false}) async {
    if(value == "" || value == null) {
      setState(() {
        loading = false;
      });
      return;
    } else {
      switch (searchType) {
        case "message":
          {
            searchMessage(token, value, offset, loadMore, channelIds: channelIds, date: date, userIds: userIds);
            break;
          }
        case "dMessage":
        {
          List data  = await MessageConversationServices.searchMessage(value, parseJson: true, limit: 40, offset: offset);
          setState(() {
            loadMore ? messages += data : messages = data;
            for(int i=0; i < data.length; i++) {
              Provider.of<DirectMessage>(context, listen: true).getInfoDirectMessage(token, messages[i]["conversation_id"]);
              DirectModel? dm = Provider.of<DirectMessage>(context, listen: true).getModelConversation(messages[i]["conversation_id"]);
              if(dm != null) {
                listDirectModel.add(dm);  
              } 
            }
            lastLength = data.length;
            loading = false;
          });
          break;
        }

        case "contact": 
        {

          List<dynamic> contactMerge = await searchContact(value);
          
          setState(() {
            contacts = contactMerge;
            loading = false;
          });
          break;
        }

        case "all_message":
        {
          await searchMessage(token, value, offset, loadMore, channelIds: channelIds, date: date, userIds: userIds);
          List data  = await MessageConversationServices.searchMessage(value, parseJson: true, limit: 40, offset: offset);
          setState(() {
            loadMore ? messages += data : messages = data;
            for(int i=0; i < data.length; i++) {
              Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(token, messages[i]["conversation_id"]);
              DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(messages[i]["conversation_id"]);
              if(dm != null) {
                listDirectModel.add(dm);  
              }
            }
            lastLength = data.length;
            loading = false;
          });
          
          break;
        }
        default:
          break;
      }
    }
    setState(() {
      searched = true;
    });
  }

  Future<List<dynamic>> searchContact(value) async{
    var membersWorkspaces = await getMembersWorkspace(value);
    var contactLocal = allContact.where((element) => Utils.unSignVietnamese(element["name"]).contains(Utils.unSignVietnamese(value))).toList();
    var idContactLocal = contactLocal.map((e) => e["user_id"]).toList();

    for(int i = 0; i < membersWorkspaces.length; i++) {
      var isExist = (idContactLocal).indexOf(membersWorkspaces[i]["id"]);
      
      if(isExist == -1) {
        contactLocal.add(membersWorkspaces[i]);
      }
    }
    return contactLocal;
  }

  getMembersWorkspace(value) async {
    final token = Provider.of<Auth>(context, listen: false).token;

    try {
      var url = Utils.apiUrl + "workspaces/search_users?token=$token&value=$value";
      var response = await Dio().get(url);
      return (response.data)["members"];
    } catch (e) {
      print(e);
      return [];
    }
  }

  searchMessage(token, value, offset, loadmore, {channelIds, userIds, date}) async {
    List _workspaces = [];
    List _messages = [];
    final workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
    String url = "${Utils.apiUrl}/workspaces/$workspaceId/search_message?token=$token";
    try {
      final List workspaceIds = Provider.of<Workspaces>(context, listen: false).data.map((e) => e['id']).toList();
      // final List channelIds = Provider.of<Channels>(context, listen: false).data.map((e) => e['id']).toList();
      var response = await Dio().post(url, data: json.encode({
        "term": value,
        "offset": offset,
        'workspace_ids': workspaceIds,
        "filter": {
          "user_ids": userIds,
          "channel_ids": channelIds,
          "date": date
        }
      }));
      var dataRes = response.data;
        if (dataRes["success"]) {
          loadmore ? workspaces += dataRes["result"] : workspaces = dataRes["result"];
        }
    } catch (e, tr) {
      print(e);
      print(tr);
    }
    // workspaces = _workspaces + _messages;
    bool needSort = _workspaces.isNotEmpty && _messages.isNotEmpty;
    if (needSort) {
      workspaces.sort((a, b) {
        var timeA = a["time_create"] != null
            ? a["time_create"] == ""
                ? "1900-01-01T00:00:00"
                : a["time_create"]
            : a["_source"]["inserted_at"] != null
                ? a["_source"]["inserted_at"] == ""
                    ? a["_source"]["inserted_at"]
                    : "1900-01-01T00:00:00"
                : "1900-01-01T00:00:00";
        var timeB = b["time_create"] != null
            ? b["time_create"] == ""
                ? "1900-01-01T00:00:00"
                : b["time_create"]
            : b["_source"]["inserted_at"] != null
                ? b["_source"]["inserted_at"] == ""
                    ? b["_source"]["inserted_at"]
                    : "1900-01-01T00:00:00"
                : "1900-01-01T00:00:00";
        return DateTime.parse(timeA).compareTo(DateTime.parse(timeB));
      });
    }
    setState(() {
      loading = false; 
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(onFocusChange);
    super.initState();    
    initLocalBox();
    var directmodels = Provider.of<DirectMessage>(context, listen: false).data;

    final currentUserId = Provider.of<User>(context, listen: false).currentUser["id"];
    List conversationInfo = directmodels.map((e) {
      var users = e.user.length > 1 ? e.user.where((item)  => item["user_id"] != currentUserId).toList() : e.user;

      return {
        "user_id": users[0]["user_id"],
        "conversation_id": users[0]["conversation_id"],
        "name":  e.displayName,
        "avatar_url": users[0]["avatar_url"],
        "is_online": users[0]["is_online"],
        "members": users.length
      };
    }).toList();

    List userInfo = directmodels.map((e) {
      var users = e.user.length == 2 ? e.user.where((item)  => item["user_id"] != currentUserId).toList() : e.user;

      return {
        "user_id": users[0]["user_id"],
        "conversation_id": users[0]["conversation_id"],
        "name": users[0]["full_name"],
        "avatar_url": users[0]["avatar_url"],
        "is_online": users[0]["is_online"]
      };
    }).toList();

    this.setState(() {
      allContact = conversationInfo;
      allUser = userInfo;
    });
    listChannel = Provider.of<Channels>(context, listen: false).data;

  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode.removeListener(onFocusChange);
    super.dispose();
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.currentWorkspaceId != widget.currentWorkspaceId) {
      _searchQuery.text = '';
      isSearchMessageView = false;
    }
  }

  setFetching(value) {
    this.setState(() {isFetching = value; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        child: Container(
           decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 16, bottom: 12),
                child: Text(S.current.search, style: TextStyle(fontSize: 17.5, height: 1.5, fontWeight: FontWeight.w700)),
              ),
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    width: width - (_focusNode.hasPrimaryFocus ? 98 : 32),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(25)
                    ),
                    child: CupertinoTextField(
                      autofocus: true,
                      controller: _searchQuery,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        searched = false;
                        onSearchChanged("contact");
                      },
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 14),
                      placeholder: S.current.SearchDiscussionsDirectories,
                      placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                      suffix: InkWell(
                        onTap: () {
                          if(_searchQuery.text != "") {
                            _searchQuery.text = "";
                            setState(() {
                              isSearchMessageView = false;
                            });
                          }
                        },
                        child: _searchQuery.text == "" ? Container() : Container(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(PhosphorIcons.x, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                        ),
                      ),
                      onSubmitted: (value) {
                        if(value == "") return;
                        onFieldSubmitted(value);
                      },
                    ),
                  ),
                  if(_focusNode.hasPrimaryFocus) Container(
                    width: 50,
                    margin: EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () {{
                        _focusNode.unfocus();
                      }},
                      child: Text("Cancel", overflow: TextOverflow.ellipsis),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      child: _searchQuery.text != ""
                      ? SearchContactView(contacts: contacts, loading: loading, searched: searched)
                      : RecentSearch(
                        onSelectRecentSearch: onSelectRecentSearch,
                        getChannel: getChannel,
                        localSearch: localSearch,
                        selectItem: selectItem,
                      ),
                    ),
                    if(isSearchMessageView == true) Positioned(
                      child: SearchMessagesView(
                        changeSearchType: changeSearchType, 
                        searchType: searchType, 
                        messages: messages, 
                        allContact: allContact, 
                        allUser: allUser, 
                        workspaces: workspaces, 
                        loading: loading,
                        isFetching: isFetching,
                        lastLength: lastLength,
                        message: messages,
                        search: search,
                        searchQuery: _searchQuery,
                        searched: searched,
                        listDirectModel: listDirectModel,
                        setFetching: setFetching,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}

// View RecentSearch
class RecentSearch extends StatefulWidget {
  const RecentSearch({ Key? key, this.localSearch, this.getChannel, this.selectItem, required this.onSelectRecentSearch }) : super(key: key);
  final localSearch;
  final getChannel;
  final onSelectRecentSearch;
  final selectItem;

  @override
  _RecentSearchState createState() => _RecentSearchState();
}

class _RecentSearchState extends State<RecentSearch> {
  getLocalSearch() {
    final currentUserId = Provider.of<User>(context, listen: false).currentUser["id"];
    if (widget.localSearch == null) return [];
    return widget.localSearch!.get(currentUserId) ?? [];
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
          child: Text("Recent Searches", style: TextStyle(color: Colors.grey)),
        ),
        SizedBox(height: 6),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...getLocalSearch().map((e) {
                    final text = e['text'];
                    final index = getLocalSearch().indexOf(e);
                    Widget recentItem() {
                      return Text(text.toString());
                    }
                    return Material(
                      color: index == widget.selectItem ? Colors.grey[500] : Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onSelectRecentSearch(e);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 16, top: 6, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  height: 30,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        child: Icon(CupertinoIcons.time, size: 18),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: DefaultTextStyle(
                                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black, overflow: TextOverflow.ellipsis) ,
                                          child: recentItem()
                                        ),
                                      )
                                    ]
                                  )
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                child: InkWell(
                                  onTap: () async {
                                    final localSearch = await Hive.openBox("localSearch");
                                    final currentUserId = Provider.of<User>(context, listen: false).currentUser["id"];
                                    List listSearch = localSearch.get(currentUserId, defaultValue: []);
                                    listSearch.removeAt(index);
                                    setState(() {
                                      localSearch.put(currentUserId, listSearch);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Icon(PhosphorIcons.x, size: 14)
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    );
                  })
                ],
              )
            ),
          ),
        )
      ],
    );
  }
}


//View Search Message
class SearchMessagesView extends StatefulWidget {
  final changeSearchType;
  final searchType;
  final messages;
  final allContact;
  final allUser;
  final workspaces;
  final loading;
  final lastLength;
  final isFetching;
  final searchQuery;
  final search;
  final message;
  final searched;
  final listDirectModel;
  final Function setFetching;
  SearchMessagesView({ 
    Key? key, 
    required this.changeSearchType, 
    required this.searchType, 
    required this.messages, 
    required this.allContact, 
    required this.allUser,
    required this.workspaces,
    required this.loading,
    required this.searchQuery,
    required this.isFetching,
    required this.lastLength,
    required this.search,
    required this.message,
    required this.searched,
    required this.listDirectModel,
    required this.setFetching
  }) : super(key: key);

  @override
  _SearchMessagesViewState createState() => _SearchMessagesViewState();
}

class _SearchMessagesViewState extends State<SearchMessagesView> {
  ScrollController _controller = ScrollController();
  PanelController panelController = PanelController();
  bool check = true;
  
   _scrollListener() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    var triggerFetchMoreSize = 0.9 * _controller.position.maxScrollExtent;
    if(_controller.position.pixels > triggerFetchMoreSize) {
      if(widget.searchType == "dMessage") {
        if(widget.lastLength >= 40 && widget.isFetching == false) {
          widget.setFetching(true);
          widget.search(widget.searchQuery.text.trim(), token, widget.searchType, offset: widget.messages.length, loadMore: true).then((_value) {
            widget.setFetching(false);
          });
        }
      }
      else if (widget.searchType == "message") {
        if(widget.isFetching == false && (widget.workspaces).length >= 50) {
          widget.setFetching(true);
          await widget.search(widget.searchQuery.text.trim(), token, widget.searchType, offset: widget.workspaces.length, loadMore: true);
        }
      }
      return ;
    }
  }

  onSelectDirectMessages(directId, {Map? message}) async {
    final auth = Provider.of<Auth>(context, listen: false);
    var hasConv = await  Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, directId);
    if (hasConv) {
      DirectModel? model = Provider.of<DirectMessage>(context, listen: false).getModelConversation(directId);
      if (model == null) return;
      if (message != null){
        if (!Utils.checkedTypeEmpty(message["parent_id"])){
          Provider.of<DirectMessage>(context, listen: false).processDataMessageToJump(message, auth.token, auth.userId);
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) {
                return Message(
                  dataDirectMessage: model,
                  id: model.id,
                  name: "",
                  avatarUrl: "",
                  isNavigator: true,
                  idMessageToJump: message["id"],
                  panelController: panelController
                );
              },
            )
          );
        } else {
          var messageOnIsar = await MessageConversationServices.getListMessageById(model, message["parent_id"], directId);
          final directMessageSelected =  Provider.of<DirectMessage>(context, listen: false).getModelConversation(directId);
          if (directMessageSelected == null) return;
          List users = directMessageSelected.user;
          final indexUser = users.indexWhere((e) => e["user_id"] == message["user_id"]);
          if (indexUser != -1 && messageOnIsar != null) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
              return ThreadView(
                isChannel: false ,
                idMessage: message["parent_id"],
                keyDB: message["parent_id"],
                idConversation: message["conversation_id"],
                channelId: "",
                idMessageToJump: message["id"],
              );
            }));
          }
        }

      }
      else {
        await Provider.of<DirectMessage>(context, listen: false).onChangeSelectedFriend(false);
        await auth.channel.push(event: "join_direct", payload: {"direct_id": directId});
        await Provider.of<DirectMessage>(context, listen: false).setSelectedDM(model, auth.token);
      }
    } else {
      // final listDataDirect = Provider.of<DirectMessage>(context, listen: false).data;
      // Provider.of<Workspaces>(context, listen: false).tab = 0;

      // if (listDataDirect.length > 0) {
      //   Provider.of<DirectMessage>(context, listen: false).setSelectedDM(listDataDirect[0], auth.token);
      //   auth.channel.push(event: "join_direct", payload: {"direct_id": listDataDirect[0].id});
      // }
    }

    // Navigator.of(context).pop();
  }
  TextSpan renderText(string) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    List list = string.trim().split(" ");

    return TextSpan(
      children: list.map<TextSpan>((e){
        Iterable<RegExpMatch> matches = exp.allMatches(e);
        if (matches.length > 0) return 
          TextSpan(
            text: "$e ", 
            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                Utils.openUrl(e);
              }
          );
        else return TextSpan(text: "$e ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87));
      }).toList()
    );
  }

  renderMessage(attachments) {
    return RichText(text: TextSpan(
      children: attachments.map<TextSpan>((item) {
        if (item["type"] == "text" && Utils.checkedTypeEmpty(item["value"])) {
          return renderText(item["value"]);
        } else if (item["type"] == "text") {
           return TextSpan(text: item["value"]);
        } else if (item["name"] == "all" || item["type"] == "all") {
          return TextSpan(text: "@All ",  style: TextStyle(color: Color(0xFFFAAD14)));
        } else if(item["type"] == "user") {
          int index = widget.allUser.indexWhere((element) => element["user_id"] == item["value"]);
          if(index != -1) {
            return TextSpan(text: "@${widget.allUser[index]["name"]}", style: TextStyle(color: Color(0xFFFAAD14)));
          }
          return TextSpan(text: "");
        } else {
          return TextSpan();
        }
      }).toList(),
      style: TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis)
    ));
  }

  onSelectMessage(message, isDirectMessage, isChannelMessage) {
    if(isDirectMessage) {
      onSelectDirectMessages(
        message["conversation_id"],
        message: message
      );
    }
    if(isChannelMessage) {
      onSelectChannelMessage({
        ...message["_source"],
        "avatarUrl": message["_source"]["avatar_url"] ?? "",
        "fullName": message["_source"]["full_name"] ?? "",
        "workspace_id": message["_source"]["workspace_id"],
        "channel_id": message["_source"]["channel_id"]
      });
    }
  }

  onSelectChannelMessage(Map message) async {
    if (!Utils.checkedTypeEmpty(message["channel_thread_id"])) {
      // dismissKeybroad();
      await Provider.of<Messages>(context, listen: false).handleProcessMessageToJump(message, context);
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) {
            return Conversation(
              id: message["channel_id"], 
              hideInput: true, 
              changePageView: (page) {}, 
              isNavigator: true,
              panelController: panelController
            );
          },
        )
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
        return ThreadView(
          isChannel: true ,
          idMessage: message["channel_thread_id"],
          keyDB: message["key"],
          channelId: message["channel_id"],
          idMessageToJump: message["id"]
        );
      }));
    }
  }

  String getAvatarUrl(List listUser, avtUrlGroup) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    String avatarUrl = "";
    try {
      if(listUser.length == 1) {
        avatarUrl = listUser[0]["avatar_url"];
      }
      else if(listUser.length == 2) {
        final otherUser = listUser.firstWhere((element) => element["user_id"] != currentUser["id"]);
        avatarUrl = otherUser["avatar_url"];
      }
      else {
        avatarUrl = avtUrlGroup;
      }
    } catch (e) {
      avatarUrl = "";
    }
    return avatarUrl;
  }
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    final workspaces = widget.workspaces;
    final directModel = widget.listDirectModel;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
            border: Border(
              bottom: BorderSide(width: 1, color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
              top: BorderSide(width: 1, color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB))
            )
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2, color: widget.searchType == "message" ? isDark ? Color(0xffFAAD14) : Color(0xff1890FF) : Colors.transparent),
                      )
                    ),
                    child: Text(
                      S.current.messages, 
                      style: TextStyle(
                        fontSize: 16, 
                        color: isDark ? (widget.searchType == "message" ? Color(0xffFAAD14) : Color(0xffA6A6A6)) : (widget.searchType == "message" ? Color(0xff1890FF) : Color(0xff828282))), 
                        textAlign: TextAlign.center
                      ),
                  ),
                  onTap: () {
                    widget.changeSearchType("message");
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2, color: widget.searchType == "dMessage" ? isDark ? Color(0xffFAAD14) : Color(0xff1890FF) : Colors.transparent),
                      )
                    ),
                    child: Text(
                      S.current.directMessages, 
                      style: TextStyle(
                        fontSize: 16, 
                        color: isDark ? (widget.searchType == "dMessage" ? Color(0xffFAAD14) : Color(0xffA6A6A6)) : (widget.searchType == "dMessage" ? Color(0xff1890FF) : Color(0xff828282))), 
                        textAlign: TextAlign.center
                      ),
                  ),
                  onTap: () {
                    widget.changeSearchType("dMessage");
                  },
                ),
              ),
            ],
          ),
        ),
        if(widget.searchType == "dMessage") Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 12),
            width: double.infinity,
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
            child: widget.loading == true ? SplashScreen() : widget.messages.length == 0
            ? NodataView(searchTypeText: "direct message",)
            : widget.loading == true ? SplashScreen() : Material(
              child: ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                controller: _controller,
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var indexContact = directModel.indexWhere((i) {
                    return i.user[0]["conversation_id"] == messages[index]["conversation_id"];
                  });
                  return indexContact != -1 ? Container(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          onSelectDirectMessages(messages[index]["conversation_id"], message: messages[index]);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                child: Stack(
                                  children: [
                                    directModel[indexContact].user.length <= 2 ? CachedAvatar(getAvatarUrl(directModel[indexContact].user, directModel[indexContact].avatarUrl), name: directModel[indexContact].displayName, width: 32, height: 32)
                                    : (directModel[indexContact].avatarUrl) != null ? CachedAvatar(getAvatarUrl(directModel[indexContact].user, directModel[indexContact].avatarUrl), name: directModel[indexContact].displayName, width: 32, height: 32) : SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(((index + 1) * pi * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Icon(
                                          Icons.group,
                                          size: 16,
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.0,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(directModel[indexContact].displayName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: isDark ? Colors.white : Color(0xff2E2E2E)), overflow: TextOverflow.ellipsis,),
                                    SizedBox(height: 4,),
                                    (messages[index]["attachments"].length > 0 && messages[index]["attachments"][0]["type"] == "mention") 
                                    ? renderMessage(messages[index]["attachments"][0]["data"])
                                    : Text(messages[index]["message"], style: TextStyle(fontSize: 13, color: isDark? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.85), fontWeight: FontWeight.w400,), overflow: TextOverflow.ellipsis)
                                  ],
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ) : SizedBox();
                },
              ),
            ),
          )
        ),
        if(widget.searchType == "message") Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 12),
            width: double.infinity,
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
            child: widget.loading == true ? SplashScreen() : widget.workspaces.length == 0 
            ? NodataView(searchTypeText: "channel message",) 
            : Material(
              child: ListView.builder(
                controller: _controller,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                shrinkWrap: true,
                itemCount: workspaces.length,
                itemBuilder: (context, index) {
                  final listChannel = Provider.of<Channels>(context, listen: false).data;
                  final lastReply = workspaces[index]["_source"]['inserted_at'];
                  final messageTime = DateFormat('kk:mm').format(DateTime.parse(lastReply).add(Duration(hours: 7)));
                  final messageLastTime = "${DateFormatter().renderTime(DateTime.parse(lastReply), type: "MMMd") + " at $messageTime"}";
                  final channel = listChannel.where((element) => element["id"] == workspaces[index]["_source"]["channel_id"]).toList().first;
                  return InkWell(
                    onTap: () {
                      onSelectMessage(workspaces[index], workspaces[index]["time_create"] != null, workspaces[index]["_source"] != null);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            child: Stack(
                              children: [
                                CachedAvatar(
                                  workspaces[index]["_source"]["avatar_url"],
                                  name: workspaces[index]["_source"]["full_name"],
                                  width: 28,
                                  height: 28
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.transparent 
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 8.0,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    channel["is_private"]
                                      ? SvgPicture.asset('assets/images/icons/Locked.svg', color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight)
                                      : SvgPicture.asset('assets/images/icons/iconNumber.svg', width: 13, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                    SizedBox(width: 4.0),
                                    Flexible(child: Text(channel["name"], style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13, color: isDark ? Colors.white : Color(0xFF1F2933), fontWeight: FontWeight.w600))),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        messageLastTime,
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 10.5, fontWeight: FontWeight.w400, color: isDark ? Palette.defaultTextDark.withOpacity(0.65) : Palette.defaultTextLight.withOpacity(0.65)
                                        )
                                      ),
                                    )
                                  ]
                                ),
                                (workspaces[index]["_source"]["attachments"] != null && workspaces[index]["_source"]["attachments"].length > 0 && workspaces[index]["_source"]["attachments"][0]["type"] == "mention") 
                                  ? renderMessage(workspaces[index]["_source"]["attachments"][0]["data"])
                                  : Text(workspaces[index]["_source"]["message_parse"], style: TextStyle(fontSize: 13, color: isDark? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.85), fontWeight: FontWeight.w400,), overflow: TextOverflow.ellipsis,)
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                  );
                },
              ),
            ),
          )
        )
      ],
    );
  }
}

//Search Contact View
class SearchContactView extends StatefulWidget {
  final contacts;
  final loading;
  final searched;
  const SearchContactView({ Key? key, required this.contacts, required this.loading, required this.searched}) : super(key: key);

  @override
  _SearchContactViewState createState() => _SearchContactViewState();
}

class _SearchContactViewState extends State<SearchContactView> {
  PanelController panelController = PanelController();

  goDirectMessage(user, context) async {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final auth = Provider.of<Auth>(context, listen: false);
    var convId = user["conversation_id"];

    if (convId == null){
      convId = MessageConversationServices.shaString([currentUser["id"], user["user_id"] ?? user["id"]]);
    }

    bool hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(Provider.of<Auth>(context, listen: false).token, convId, forceLoad: true);
    var dm;
    if (hasConv){
      dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(convId);
    } else {
      dm = DirectModel(
        convId, 
        [
          {"user_id": currentUser["id"],"full_name": currentUser["full_name"], "avatar_url": currentUser["avatar_url"], "is_online": true}, 
          {"user_id": user["user_id"] ?? user["id"], "avatar_url": user["avatar_url"],  "full_name": user["full_name"] ?? user["name"], "is_online": user["is_online"]}
        ], 
        "", 
        false, 
        0, 
        {}, 
        false,
        0,
        {},
        user["full_name"] ?? user["name"], null,
        DateTime.now().toString()
      );
    }
    if (dm == null) return;
    Provider.of<DirectMessage>(context, listen: false).setSelectedDM(dm, auth.token);
    if (hasConv) {
      Provider.of<DirectMessage>(context, listen: false).resetOneConversation(dm.id);
      await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(dm.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(dm.id, true, auth.token, auth.userId);
    }

    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) {
        return Message(
          dataDirectMessage: dm,
          id: dm.id,
          name: "",
          avatarUrl: "",
          isNavigator: true,
          panelController: panelController
        );
      },
    ));
  }


  @override
  Widget build(BuildContext context) {
    final contacts = widget.contacts;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Contact", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
        ),
        Expanded(
          child: Container(
            child: contacts.length == 0 && widget.searched == true
            ? NodataView(searchTypeText: "contact",) 
            : widget.loading == true ? SplashScreen() : ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Color(isDark ? 0xff3D3D3D : 0xffDBDBDB)),
                    )
                  ),
                  child: InkWell(
                    onTap: () {
                      goDirectMessage(contacts[index], context);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            child: Stack(
                              children: [
                                (contacts[index]["members"] != null && contacts[index]["members"] < 2) || contacts[index]["members"] == null 
                                  ? CachedAvatar(contacts[index]["avatar_url"], name: contacts[index]["name"] ?? contacts[index]["full_name"], width: 24, height: 24)
                                  : SizedBox( 
                                    width: 24,
                                    height: 24,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(((index + 1) * pi * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Icon(
                                        Icons.group,
                                        size: 14,
                                        color: Colors.white
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: (contacts[index]["members"] != null && contacts[index]["members"] < 2) || contacts[index]["member"] == null
                                        ? contacts[index]["is_online"]
                                          ? Colors.green : Colors.transparent
                                        : Colors.transparent
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 8.0,),
                          Expanded(child: Text(contacts[index]["name"] ?? contacts[index]["full_name"], style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}

class NodataView extends StatelessWidget {
  NodataView({ Key? key, required this.searchTypeText }) : super(key: key);
  final searchTypeText; 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No Data for $searchTypeText"),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    double height = MediaQuery.of(context).size.height;
    double newheight = height - padding.top - padding.bottom;
    return Container(
      child: shimmerEffect(context, number: (newheight.toInt() - 982) % 70),
    );
  }
}