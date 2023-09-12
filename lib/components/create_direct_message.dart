import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/service_locator.dart';

import '../generated/l10n.dart';
import 'isar/message_conversation/service.dart';

class CreateDirectMessage extends StatefulWidget {

  final defaultList;
    CreateDirectMessage({
    Key? key,
    this.defaultList
  }): super(key: key);

  @override
  _CreateDirectMessageState createState() => _CreateDirectMessageState();
}

class _CreateDirectMessageState extends State<CreateDirectMessage> {
  var resultSearch = [];
  var seaching = false;
  var listUserDM = [];
  var creating = false;
  var nameFM = "";
  var listFirend = [];
  var _debounce;
  PanelController panelController = PanelController();
  @override
  void initState(){
    super.initState();
    listFirend =  Provider.of<User>(context, listen: false).friendList;
    resultSearch =  listFirend;
    if (widget.defaultList != null){
      listUserDM = [] + widget.defaultList;
    }
  }

  search(value, token) async {
    if (!Utils.checkedTypeEmpty(value)) return setState(() {
      resultSearch = listFirend;
    });
    String url = "${Utils.apiUrl}users/search_user_in_workspace?token=$token&keyword=$value";
    setState(() {
      seaching = true;
    });
    try {
      var response = await Dio().get(url);
      var dataRes = response.data;
      if (dataRes["success"]) {
        setState(() {
          resultSearch = dataRes["users"];
          seaching = false;
        });
      } else {
        setState(() {
          seaching = false;
        });
        throw HttpException(dataRes["message"]);
      }
    } catch (e) {
      setState(() {
        seaching = false;
      });
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  handleUserToDM(user, seleted) {
    setState(() {
      if (seleted){
        listUserDM.removeWhere((item) => item["id"] == user["id"]);
      }
      else {
        listUserDM += [user];
      }
    });
  }

  createDirectMessage(String token) async {
    // final url = "${Utils.apiUrl}direct_messages/create?token=$token";
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    var listUserId = (listUserDM + [currentUser]).map((e) {
      return {
        "user_id": e["id"],
        "full_name": e["full_name"],
        "avatar_url": e["avatar_url"]
      };
    }).toList();

    Map<String, Map<String, dynamic>> indexs = {};
    for (var i = 0; i < listUserId.length; i++) {
      indexs[listUserId[i]["user_id"]] = listUserId[i];
    }
    listUserId = indexs.values.toList();
    DirectModel  dm = DirectModel(
      MessageConversationServices.shaString(listUserId.map((e) => e["user_id"]).toList()), 
      listUserId, 
      nameFM, 
      true, 
      0, 
      {}, 
      false,
      0,
      {},
      Provider.of<DirectMessage>(context, listen: false).getNameDM(listUserId, currentUser["id"] ?? currentUser["user_id"], nameFM),
      null, DateTime.now().toString()
    );

    if (listUserId.length <= 2){
      if (await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(token, dm.id)){
        Auth auth = Provider.of<Auth>(context, listen: false);
        await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(dm.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
      }
    }
    Provider.of<DirectMessage>(context, listen: false).setSelectedDM(dm, "", isCreate: true);
    Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => Message(
      dataDirectMessage: dm,
      id: dm.id,
      name: dm.displayName,
      avatarUrl: "",
      isNavigator: true,
      panelController: panelController
      // changePageView: changePageView
    )));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final token = auth.token;
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final isDark = auth.theme == ThemeType.DARK;
    Color colorText = isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D);
    BorderSide borderStyle = BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9));

    resultSearch.removeWhere((element){return element["id"] == userId;});

    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Container(
          // width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Text(
                          S.current.newMessage,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )
                        ),
                      ),
                      Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: Platform.isIOS ?  MediaQuery.of(context).size.height - 180 : MediaQuery.of(context).size.height - 150,
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(S.current.conversationName, style: TextStyle(fontWeight: FontWeight.w500, color: colorText, fontSize: 15, height: 1.67))
                    ),
                    Container(
                    height: 40,
                    child: CupertinoTextField(
                      // controller: channelName,
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(2),
                        border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                      ),
                      autofocus: false,
                      placeholder: listUserDM.length > 0 ? listUserDM.map((e) => e["full_name"]).join(", ") : "Enter conversation name",
                      placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontFamily: "Roboto", fontSize: 15),
                      style: TextStyle(color: colorText, fontFamily: "Roboto", fontSize: 15),
                      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      onChanged: (value) {
                        nameFM = value;
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Text(S.current.members, style: TextStyle(fontWeight: FontWeight.w500, color: colorText, fontSize: 15, height: 1.67))
                  ),
                  SizedBox(height: 4,),
                  Container(
                    height: 40,
                    child: CupertinoTextField(
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(2),
                        border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                      ),
                      placeholder: S.current.searchMember,
                      placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontFamily: "Roboto", fontSize: 15),
                      style: TextStyle(color: colorText, fontFamily: "Roboto", fontSize: 15),
                      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      // focusNode: node,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          search(value, token);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 12,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    // height: 32,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: listUserDM.map((u) => Container(
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {handleUserToDM(u, true);},
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Column(
                                    children: [
                                      CachedAvatar(
                                        u["avatar_url"],
                                        height: 50,
                                        width: 50,
                                        name: u["full_name"]
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        width: 50,
                                        child: Text(u["full_name"],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15, color: colorText, height: 1.5),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white
                                    ),
                                    width: 20,
                                    height: 20,
                                    child: Icon(PhosphorIcons.x, size: 12, color: Colors.black),
                                  )
                                )
                              ],
                            ),
                          ),
                        )).toList(),
                      ) 
                    )),
                    // SizedBox(height: 24,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: resultSearch.length,
                      itemBuilder: (context, index) {
                        var selected = listUserDM.where((e) {
                            return e["id"] == resultSearch[index]["id"];
                          }).length >
                          0;
                        if (selected) return Container(
                           decoration: BoxDecoration(
                             border: Border(
                                top: index == 0 ? borderStyle : BorderSide.none,
                             )
                           )
                        );
                        return InkWell(
                          onTap: () {
                            handleUserToDM(resultSearch[index], selected);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              // borderRadius: resultSearch.length == 1 ? BorderRadius.all(Radius.circular(2)) : index == 0 ? BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)) : index == resultSearch.length - 1 ? BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)) : null,
                              border: Border(
                                top: index == 0 ? borderStyle : BorderSide.none,
                                right: borderStyle,
                                left: borderStyle,
                                bottom: borderStyle
                              )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    CachedAvatar(
                                    resultSearch[index]["avatar_url"],
                                    radius: 12,
                                    height: 25,
                                    width: 25,
                                    name: resultSearch[index]["full_name"]
                                  ),
                                    Container(
                                      width: 10,
                                    ),
                                    Container(
                                      child: Text(resultSearch[index]["full_name"],
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                                selected ? Container(
                                child: Icon(PhosphorIcons.checkCircleFill, size: 19, color: Color(0xff1890FF),)
                              ) : SizedBox()
                              ]
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16,),
                  // CREATE DIRECT MESSAGE
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 30),
                  //   margin: EdgeInsets.only(top: 12, bottom: 30),
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 40,
                  //   child: TextButton(
                  //     style: ButtonStyle(
                  //       backgroundColor: MaterialStateProperty.all(
                  //         isDark ? Color(0xff19DFCB) : Color(0xff2A5298)
                  //       )
                  //     ),
                  //     onPressed: () {
                  //       if (!creating){
                  //         createDirectMessage(token);
                  //       }
                  //     },
                  //     // color: Utils.getPrimaryColor(),
                  //     child:  Row(
                  //       children: [
                  //         Expanded( child: Container(),),
                  //         creating
                  //             ? Container(
                  //                 width: 50,
                  //                 alignment: Alignment.center,
                  //                 child: Lottie.network("https://assets4.lottiefiles.com/datafiles/riuf5c21sUZ05w6/data.json"),
                  //               )
                  //             : Container(),
                  //         Text("Create", style: TextStyle(color: Colors.white)),
                  //         Expanded( child: Container(),),
                  //       ],
                  //     )

                  // ))
                ]),
              ),
              Container(
                height: Platform.isIOS ? 67 : 58,
                padding: EdgeInsets.only(left: 16, right: 16, bottom: Platform.isIOS ? 25 : 16),
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                      if (!creating){
                        createDirectMessage(token);
                      }
                    },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Color(0xff1890ff) ,
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(S.current.create, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,))
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
