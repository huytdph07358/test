import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/dropdown_overlay.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class WorkspaceSettingsRole extends StatefulWidget {
  final placeholder;
  final prefix;
  final controller;
  final decoration;
  
  const WorkspaceSettingsRole
  ({ Key? key, 

  this.placeholder = "", 
  this.prefix, 
  this.controller, 
  this.decoration 

  }) : super(key: key);

  @override
  _WorkspaceSettingsRoleState createState() => _WorkspaceSettingsRoleState();
}

class _WorkspaceSettingsRoleState extends State<WorkspaceSettingsRole> {
  FocusNode focusNode = FocusNode();
  // final TextEditingController _searchQuery = new TextEditingController();
  ScrollController controller = new ScrollController();
  TextEditingController _passwordController = TextEditingController();
  Timer? _debounce;
  String? filter;
  int action = 0;
  String? selectedId;
  bool loading = false;

  void dispose(){
    controller.dispose();
    _debounce?.cancel();
    _passwordController.dispose();
    // _searchQuery.dispose();
    super.dispose();
  }

  Widget renderRoles(roleMembers, String title, int roleId) {
    var onlList = [];
    var offList = [];
    roleMembers.forEach((member) {
      if (member['is_online']) {
        onlList.add(member);
      } else {
        offList.add(member);
      }
    });
    List sortList = List.from(onlList)..addAll(offList);

    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    return Container(
      child: Column(
        children: [
          Container(
            color: isDark ? Color(0xff4C4C4C) : Color(0xffF8F8F8),
            padding: EdgeInsets.only(top: 12, bottom: 12, left: 20),
            child: Row(
              children: [
                // Container(
                //   width: 3,
                //   height: 18,
                //   color: Constants.checkColorRole(roleId, isDark),
                //   margin: EdgeInsets.only(right: 8),
                // ),
                Text(title, style: TextStyle(color: Utils.checkColorRole(roleId, isDark), fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              controller: controller,
              itemCount: sortList.length,
              itemBuilder: (BuildContext context, int index) {
                final member = sortList[index];
                return Container(
                  padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: ((action != 0) && selectedId == member['id']) ? 6 : 12),
                  color: ((action != 0) && selectedId == member['id']) ? Color(0xff5E5E5E).withOpacity(0.8) : Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CachedImage(
                                      member['avatar_url'],
                                      width: 30,
                                      height: 30,
                                      isAvatar: true,
                                      radius: 50,
                                      name: member['full_name']
                                    ),
                                    Positioned(
                                      bottom: -2, right: -2,
                                      child: Container(
                                        height: 12, width: 12,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(width: 2, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED)),
                                          color: member['is_online'] ? Color(0xff73d13d) : Color(0xffbfbfbf)
                                        ),
                                      )
                                    )
                                  ],
                                ),
                                SizedBox(width: 12),
                                Container(
                                  child: Text(
                                    member['full_name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: isDark ? Colors.white : Color(0xff1d1c1d), fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: currentMember['role_id'] <= member['role_id'] && (currentMember['role_id'] <= 2 || currentMember['user_id'] == member['id'])
                                  ? DropActionSetting(
                                    member: member,
                                    onPressed: (value, uid) {
                                      setState(() { action = value; selectedId = uid; });
                                    }
                                  )
                                  : HoverItem(
                                    showTooltip: true,
                                    tooltip: Container(
                                      color: isDark ? Color(0xFF1c1c1c): Colors.white,
                                      child: Text(
                                        currentMember['role_id'] > member['role_id']
                                          ? "Cant Actions For You"
                                          : "Your Role Cannot Action"
                                      ),
                                    ), 
                                    colorHover: null,
                                    child: Icon(CupertinoIcons.ellipsis, size: 16, color: isDark ? Colors.white24 : Color(0x1d1c1d21))
                                  ),
                            ),
                          ),
                        ]
                      ),
                      if ((action != 0) && selectedId == member['id']) Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 6),
                        child: Divider(color: Color(0xff4C4C4C), height: 0.5),
                      ),
                      if ((action == 1 || action == 2) && selectedId == member['id']) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            action == 1
                              ? "Delete Member"
                              : "Leave Workspace"
                          ),
                          Row(children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  action = 0;
                                  selectedId = null;
                                });
                              },
                              child: Container(
                                width: 80,
                                margin: EdgeInsets.symmetric(vertical: 12),
                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffEDEDED)
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(2))
                                ),
                                child: Text("cancel", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () async {
                                setState(() { loading = true; });
                                if (action == 1) {
                                  await Provider.of<Workspaces>(context, listen: false).deleteChannelMember(auth.token, currentWorkspace['id'], currentChannel["id"], [member['id']], type: "other")
                                    .then((value) => setState(() { loading = false; }));
                                } else {
                                }
                              },
                              child: Container(
                                width: action == 1 ? 80 : 160,
                                margin: EdgeInsets.symmetric(vertical: 12),
                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: Color(0xffEB5757),
                                  border: Border.all(
                                    color: Color(0xffEB5757)
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(2))
                                ),
                                child: loading
                                  ? SpinKitFadingCircle(
                                    color: isDark ? Colors.white60 : Color(0xff096DD9),
                                    size: 19,
                                  )
                                  : Text(
                                    action == 1
                                      ? S.current.delete
                                      : S.current.leaveWorkspace,
                                    style: TextStyle(color: Colors.white)
                                  ),
                              ),
                            )
                          ],)
                        ],
                      ),
                      if ((action == 3) && selectedId == member['id']) LayoutBuilder(
                        builder: (context, contraints) => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(S.current.transferTo),
                                SizedBox(width: 5),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      height: 32, width: contraints.maxWidth * 1/3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            child: Text(
                                              S.current.selectMember,
                                              style: TextStyle(
                                                color: Color(0xffF0F4F8),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.arrow_drop_down, color: Colors.white, size: 20)
                                        ]
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 34,
                              margin: EdgeInsets.only(top: 4),
                              width: contraints.maxWidth,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: TextFormField(
                                onChanged: (value) {
                                  this.setState(() {});
                                },
                                obscureText: true,
                                controller: _passwordController,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w300),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  hintText: "Enter Pass To Transfer",
                                  hintStyle: TextStyle(color: Color(0xff9AA5B1), fontWeight: FontWeight.w300, fontSize: 14.0),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    action = 0;
                                    selectedId = null;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xffEDEDED)
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(2))
                                  ),
                                  child: Text(S.current.cancel, style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
                                  decoration: BoxDecoration(
                                    color: Utils.getPrimaryColor(),
                                    border: Border.all(
                                      color: Utils.getPrimaryColor()
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(2))
                                  ),
                                  child: loading
                                    ? SpinKitFadingCircle(
                                      color: isDark ? Colors.white60 : Color(0xff096DD9),
                                      size: 19,
                                    )
                                    : Text(
                                      S.current.transfer,
                                      style: TextStyle(color: Colors.white)
                                    ),
                                  ),
                                )
                            ],)
                          ],
                        ),
                      )
                    ],
                  )
                );
              },
            ),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final wsMembers = Provider.of<Workspaces>(context, listen: true).members;
    var members = wsMembers.where((ele) => ele["account_type"] == 'user').toList();
    if (Utils.checkedTypeEmpty(filter)) {
      members = members.where((ele) =>
          ele["full_name"].toString().toLowerCase().contains(filter!) || ele["email"].toString().toLowerCase().contains(filter!)
        ).toList();
    }
    final ownerMember = members.where((ele) => ele['role_id'] == 1).toList();
    final adminMember = members.where((ele) => ele['role_id'] == 2).toList();
    final editorMember = members.where((ele) => ele['role_id'] == 3).toList();
    final fullMember = members.where((ele) => ele['role_id'] == 4).toList();

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
          ),
          child: Column(
            children: [
              Container(
                height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          highlightColor: Colors.transparent,
                          onTap: () => { 
                            Navigator.of(context).pop()
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18,horizontal: 18),
                              child: Text(
                                S.current.workspaceDetails,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )
                              ),
                            ),
                          ),
                        ),
                        Container(width: 50,)
                      ],
                    ),
                  ),
                ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        focusNode: focusNode,
                        autofocus: false,
                        prefix:Container(
                        child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                          padding: EdgeInsets.only(left: 15)
                        ),
                        placeholder: S.current.searchMember,
                        placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), fontSize: 15, fontFamily: "Roboto"),
                        style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontFamily: "Roboto"),
                        padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                        clearButtonMode: OverlayVisibilityMode.editing,
                        controller: widget.controller,
                        decoration: widget.decoration ?? BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3)
                        ),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500), () {
                                setState(() {
                                  filter = value.toLowerCase().trim();
                                });
                            });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      renderRoles(ownerMember, S.current.owner.toUpperCase(), 1),
                      SizedBox(height: 2,),
                      renderRoles(adminMember, S.current.admins.toUpperCase(), 2),
                      SizedBox(height: 2,),
                      renderRoles(editorMember, S.current.editors.toUpperCase(), 3),
                      SizedBox(height: 2,),
                      renderRoles(fullMember, S.current.members.toUpperCase(), 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropActionSetting extends StatefulWidget {
  final member;
  final Function onPressed;
  DropActionSetting({ Key? key, this.member, required this.onPressed }) : super(key: key);

  @override
  _DropActionSettingState createState() => _DropActionSettingState();
}

class _DropActionSettingState extends State<DropActionSetting> {

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;

    return DropdownOverlay(
      menuOffset: 15,
      isAnimated: true,
      menuDirection: MenuDirection.end,
      dropdownWindow: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xff5E5E5E) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isDark ? Color(0xff5E5E5E) : Palette.borderSideColorLight)
            ),
            child: currentMember['user_id'] == member['id']
              ? Container(
                constraints: BoxConstraints(
                  minWidth: 320
                ),
                child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(16))
                  ),
                  child: Row(
                    children: [
                      Text(
                        currentMember['role_id'] != 1 ? S.current.leaveWorkspace : S.current.transferOwner,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065), fontWeight: FontWeight.w400)
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (currentMember['role_id'] != 1) {
                      widget.onPressed(2, member['id']);
                    } else {
                      widget.onPressed(3, member['id']);
                    }
                  },
                ),
              )
              : Container(
                child: Column(
                  children: [
                    currentMember['role_id'] <= 2 && currentMember['role_id'] <= member['role_id'] ? Container(
                      constraints: BoxConstraints(
                        minWidth: 320
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18, horizontal: 16))
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              color: Color(0xff73D13D),
                              margin: EdgeInsets.only(right: 8),
                            ),
                            Text(S.current.setAdmin, style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065), fontWeight: FontWeight.w400)),
                          ],
                        ),
                        onPressed: () async {
                          await Provider.of<Workspaces>(context, listen: false).changeRoleWs(auth.token, member['id'], 2);
                          Navigator.of(context).pop();
                        },
                      ),
                    ) : Container(),
                    currentMember['role_id'] <= 3 && currentMember['role_id'] <= member['role_id'] ? Container(
                      constraints: BoxConstraints(
                        minWidth: 320
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18, horizontal: 16))
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              color: Color(0xff36CFC9),
                              margin: EdgeInsets.only(right: 8),
                            ),
                            Text(S.current.setEditor, style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065), fontWeight: FontWeight.w400)),
                          ],
                        ),
                        onPressed: () async {
                          await Provider.of<Workspaces>(context, listen: false).changeRoleWs(auth.token, member['id'], 3);
                          Navigator.of(context).pop();
                        },
                      ),
                    ) : Container(),
                    currentMember['role_id'] <= 3 && currentMember['role_id'] <= member['role_id'] ? Container(
                      constraints: BoxConstraints(
                        minWidth: 320
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18, horizontal: 16))
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D),
                              margin: EdgeInsets.only(right: 8),
                            ),
                            Text(S.current.members, style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065), fontWeight: FontWeight.w400)),
                          ],
                        ),
                        onPressed: () async {
                          await Provider.of<Workspaces>(context, listen: false).changeRoleWs(auth.token, member['id'], 4);
                          Navigator.of(context).pop();
                        },
                      ),
                    ) : Container(),
                    currentMember['role_id'] <= 3 && currentMember['role_id'] <= member['role_id'] ? Divider(height: 0) : SizedBox(),
                    currentMember['role_id'] <= 3 && currentMember['role_id'] <= member['role_id'] ? Container(
                      constraints: BoxConstraints(
                        minWidth: 320
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 16))
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              color: Colors.red,
                              margin: EdgeInsets.only(right: 8),
                            ),
                            Text(S.current.deleteMembers, style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065), fontWeight: FontWeight.w400)),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onPressed(1, member['id']);
                        },
                      ),
                    ) : Container(),
                    currentMember['role_id'] <= 3 && currentMember['role_id'] <= member['role_id'] ? Divider(height: 0) : SizedBox(),
                  ],
                ),
              ),
          );
        },
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 80,
          alignment: Alignment.center,
          child: Icon(CupertinoIcons.ellipsis, size: 16),
        ),
      ),
    );
  }
}