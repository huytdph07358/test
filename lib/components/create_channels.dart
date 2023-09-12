import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class CreateChannel extends StatefulWidget {
  @override
  _CreateChannelState createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  bool isValuePrivate = false;
  var _debounce;
  List resultSearch = [];
  List listUserChannel = [];
  FocusNode node = new FocusNode();
  final TextEditingController _channelNameController = TextEditingController();


  @override
  void initState(){
    super.initState();
    Timer.run(()async {
      final auth = Provider.of<Auth>(context, listen: false);
      final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
      List result   = await Provider.of<Workspaces>(context, listen: false).searchMember("", auth.token, currentWorkspace["id"]);
      result.removeWhere((element) => element["id"] == auth.userId);
      setState(() {
        resultSearch = result;
      }); 
    });
    _channelNameController.addListener(listenValueName);
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  void listenValueName() {
    if (_channelNameController.text.contains(' ')) {
      List _splitCurrentSpace = _channelNameController.text.split(" ");
      int _currentCaretPosition = _splitCurrentSpace[0].length +1;  
      final formatName = _channelNameController.text.replaceAll(' ', '-');
      _channelNameController.value = TextEditingValue(
        text: formatName,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _currentCaretPosition),
        )
      );
    }
  }

  Future<void> _submitCreateChannel(token, workspaceId) async {
    try {
      var userIds  = listUserChannel.map((e) => e["id"]).toList();
      final auth = Provider.of<Auth>(context, listen: false);
      final providerMessage = Provider.of<Messages>(context, listen: false);
      await Provider.of<Channels>(context, listen: false).createChannel(token, workspaceId, _channelNameController.text, isValuePrivate, userIds, auth, providerMessage);
      await Provider.of<Channels>(context, listen: false).loadChannels(token, workspaceId);
      Navigator.pop(context);
    } on HttpException catch (error) {
      print("this is http exception $error");
    } catch (e) {
      print(e);
    }
  }


  handleUserToChannel(user, selected) {
    setState(() {
      var index  = listUserChannel.indexWhere((element) => element["id"] == user["id"]);
      if (index != -1){
        listUserChannel.removeAt(index);
      }
      else listUserChannel.add(user);
    });
  }

  _selectChannelType(value) {
    setState(() {
      isValuePrivate = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final token = auth.token;
    final currentWorkspace = Provider.of<Workspaces>(context).currentWorkspace;
    final isDark = auth.theme == ThemeType.DARK;
    Color colorText = isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D);
    BorderSide borderStyle = BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9));

    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
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
                        S.current.createChannel,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(S.current.channelName, style: TextStyle(fontWeight: FontWeight.w500, color: colorText, fontSize: 15, height: 1.67))
                  ),
                  Container(
                    height: 40,
                    child: CupertinoTextField(
                      controller: _channelNameController,
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(2),
                        border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                      ),
                      autofocus: false,
                      placeholder: S.current.addName,
                      placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontFamily: "Roboto", fontSize: 15),
                      style: TextStyle(color: colorText, fontFamily: "Roboto", fontSize: 15),
                      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                      clearButtonMode: OverlayVisibilityMode.editing,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Text(S.current.channelType, style: TextStyle(fontWeight: FontWeight.w500, color: colorText, fontSize: 15, height: 1.67))
                  ),
                  SizedBox(height: 4,),
                  Container(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _selectChannelType(false);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(2),
                                border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                              ),
                              padding: EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(S.current.regular, style: TextStyle(fontSize: 15, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                                  Container(
                                    child: Radio(
                                      activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                      value: false,
                                      groupValue: isValuePrivate, 
                                      onChanged: (value) {
                                        _selectChannelType(value);
                                      }),
                                  )
                                ],
                              )
                            ),
                          )
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _selectChannelType(true);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(2),
                                border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                              ),
                              padding: EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(S.current.privateChannel, style: TextStyle(fontSize: 15, color:  isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                                  Container(
                                    child: Radio(
                                      activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                      value: true, 
                                      groupValue: isValuePrivate, 
                                      onChanged: (value) {
                                        _selectChannelType(value);
                                      }
                                    ),
                                  )
                                ],
                              )
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Text(S.current.members, style: TextStyle(fontWeight: FontWeight.w500, color: colorText, fontSize: 15, height: 1.67))
                  ),
                  SizedBox(height: 4,),
                  // Container(
                  //   padding: EdgeInsets.only(top: 30, left: 15, bottom: 5),
                  //   child: Row(children: [
                  //     Text("MEMBERS" + ((listUserChannel.length > 0 )? "  (${listUserChannel.length })": "") , style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[700])),
                  //   ])
                  // ),
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
                      focusNode: node,
                      onChanged: (value){
                        if (_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), ()async {
                          List result = await Provider.of<Workspaces>(context, listen: false).searchMember(value, token, currentWorkspace["id"]);
                          result.removeWhere((element) => element["id"] == auth.userId);
                          setState(() {
                            resultSearch = result;
                          });
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: resultSearch.length,
                      itemBuilder: (context, index) {
                        var selected = listUserChannel.where((e) {return e["id"] == resultSearch[index]["id"]; }).length > 0;
                        return InkWell(
                          onTap: () {
                            handleUserToChannel(resultSearch[index], selected);
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
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      child: Text(resultSearch[index]["nickname"] ?? resultSearch[index]["full_name"],
                                      style: TextStyle(fontSize: 15, color: colorText, height: 1.5)),
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
                ],
              ),
            ),
            Container(
              height: Platform.isIOS ? 67 : 58,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: Platform.isIOS ? 25 : 16),
              color: isDark ? Color(0xff2E2E2E) : Colors.white,
              width: double.infinity,
              child: InkWell(
                onTap: _channelNameController.text == '' ? null : () {
                  _submitCreateChannel(token, currentWorkspace["id"]);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _channelNameController.text != '' ? Color(0xff1890ff) : Colors.grey,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.5),
                  child: Text(S.current.createChannel, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, height: 1.5))
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
