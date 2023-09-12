import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class SearchUser extends StatefulWidget {
  final placeholder;
  final onChanged;
  final double radius;
  final prefix;
  final controller;
  final autoFocus;
  final focusNode;
  final decoration;
  SearchUser({Key? 
    key,this.placeholder = "",
    this.onChanged,
    this.controller,
    this.radius = 5,
    this.prefix = true,
    this.autoFocus = false,
    this.focusNode,
    this.decoration}) : super(key: key);

  @override
  _SearchUser createState() => _SearchUser();
}

class _SearchUser extends State<SearchUser>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  var resultSearch = [];
  var seaching = false;
  var handleUser;
  var _debounce;
  FocusNode node = FocusNode();

  @override
  void initState() {
    _controller.addListener(_scrollListener);
    super.initState();
    search("", Provider.of<Auth>(context, listen: false).token);
  }

  _scrollListener() {
    FocusScope.of(context).unfocus();
  }

  search(value, token) async {
    String url =
        "${Utils.apiUrl}users/search_user_in_workspace?token=$token&keyword=$value";
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

  invite(user, token, idDM) async {
    var userId = user["id"];
    var dataConversation = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(idDM);
    if (dataConversation == null) return;
    var status = dataConversation.statusConversation;
    if (status == "creating" ) return;
    if (status == "init")return Provider.of<DirectMessage>(context, listen: false).inviteMemberWhenConversationInDummy(user, idDM);
    LazyBox box = Hive.lazyBox("pairKey");
    String url = "${Utils.apiUrl}direct_messages/$idDM/invite?token=$token&device_id=${await box.get("deviceId")}";
    setState(() {
      handleUser = userId;
    });
    try {
      var response = await Dio().post(url, data: {
        "data": await Utils.encryptServer({"invite_id": userId})
      });
      var dataRes = response.data;
      if (dataRes["success"]) {
        var currentDM = Provider.of<DirectMessage>(context, listen: false).getModelConversation(idDM);
        if (currentDM == null) return;
        currentDM.user = dataRes["data"]["user"];
        var boxDirect = Hive.box('direct');
        boxDirect.put(currentDM.id, currentDM);

        Provider.of<DirectMessage>(context, listen: false).setSelectedDM(currentDM, token);
      }
      setState(() {
        handleUser = null;
      });
    } catch (e) {
      setState(() {
        handleUser = null;
      });
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    double deviceHeight = MediaQuery.of(context).size.height;
    DirectModel dm = Provider.of<DirectMessage>(context, listen: true).directMessageSelected;
    resultSearch.removeWhere((element) {
      return element["id"] == userId;
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: deviceHeight * .83,
        decoration: BoxDecoration(
          color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15),),
        ),
        child: Column(children: <Widget>[
                    Container(
            margin: EdgeInsets.only( top: 5),
            padding: EdgeInsets.only(left: 18,right: 18,bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Color(0xff5E5E5E) : Color(0xffEDEDED),
                  width: 1.0,
                ),
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add member",style: TextStyle(fontSize: 14,color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D),fontWeight: FontWeight.w500),),
                      InkWell(
                      onTap: () {
                          Navigator.of(context).pop();
                        },
                      child: Text("Done",style: TextStyle(fontSize: 14,color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),fontWeight: FontWeight.w500),)),
                    ],
                  ),
                ),

                SizedBox(height: 5,),
                CupertinoTextField(
                  focusNode: node,
                  autofocus: true,
                  prefix: widget.prefix ? Container(
                    child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                    padding: EdgeInsets.only(left: 15)
                  ) : Container(),
                  placeholder: "Search member",
                  placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), fontSize: 15, fontFamily: "Roboto"),
                  style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontFamily: "Roboto"),
                  padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: widget.controller,
                  decoration: widget.decoration ?? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffF3F3F3)
                  ),
                  onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    search(value, token);
                  });
                  },
                )
              ],
            )
          ),
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                height: seaching ? 100 : 0,
                child: Lottie.network("https://assets6.lottiefiles.com/datafiles/tvGrhGYaLS0VjreZ1oqQpeFYPn4xPO625FsUAsp8/simple loading/simple.json")
              ),
              Container(
                height: deviceHeight * .85 - 160,
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                      BorderSide(color: Colors.black12, width: 0.5)
                    )
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: ListView.builder(
                      // scrollDirection: Axis.horizontal,
                      itemCount: resultSearch.length,
                      itemBuilder: (context, index) {
                        var selected = dm.user.where((e) {return e["user_id"] == resultSearch[index]["id"]  && e["status"] == "in_conversation"; }).length > 0;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    CachedImage(
                                      resultSearch[index]["avatar_url"],
                                      radius: 30,
                                      isRound: true,
                                      name: resultSearch[index]["full_name"]
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resultSearch[index]["full_name"],
                                          style: TextStyle(
                                            color: isDark ? Colors.white : const Color(0xFF1F2933),
                                            fontWeight: FontWeight.w500
                                          ),
                                          overflow: TextOverflow.ellipsis
                                        ),
                                        if(Utils.checkedTypeEmpty(resultSearch[index] ['username'])) Container(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Text(
                                            resultSearch[index]['username'],
                                            style: TextStyle(fontSize: 11, color: Color(0xFF6a6e74)),
                                            overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                      ],
                                    )

                                  ]
                                ),
                                GestureDetector(
                                  onTap: () {
                                    !selected && invite(resultSearch[index], token, dm.id);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? selected ? Color(0xff2E2E2E):Color(0xff3D3D3D): selected ? Color(0xffF3F3F3):Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(color: isDark ? selected ? Color(0xff5E5E5E) : Color(0xffEDEDED) : selected ? Color(0xffB7B7B7) : Color(0xff5E5E5E),),
                                    ),
                                    child: Row(
                                      children: [
                                        handleUser == resultSearch[index]["id"] ? Container(
                                          height: 20,
                                          alignment: Alignment.center,
                                          child: Lottie.network("https://assets4.lottiefiles.com/datafiles/riuf5c21sUZ05w6/data.json")
                                        ) : Text(selected ? "Invited" : "Add",style: TextStyle(fontSize: 14,
                                        color: isDark ? selected ? Color(0xff5E5E5E) : Color(0xffEDEDED) : selected ? Color(0xffB7B7B7) : Color(0xff5E5E5E),
                                        ),)
                                      ],
                                    )
                                  ),
                                )
                              ]
                            ),
                          );
                      }
                    )
                  )
                )
              ]
            )
          ]
        )
      )
    );
  }
}

class AnimationProcessing extends StatefulWidget {
  final active;
  AnimationProcessing({Key? key, @required this.active}) : super(key: key);
  @override
  _AnimationProcessing createState() => _AnimationProcessing();
}

class _AnimationProcessing extends State<AnimationProcessing> {
  double _width = 0;

  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _width,
      height: 10,
      duration: Duration(seconds: 1),
      child: Container(
        height: widget.active ? 20 : 0,
        child: Lottie.network("https://assets6.lottiefiles.com/datafiles/riuf5c21sUZ05w6/data.json"),
      ),
    );
  }
}
