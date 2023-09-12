import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/route_animation.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/channel/channel_member_bottom.dart';
import 'package:workcake/components/channel/list_member.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import '../invite_member.dart';

class ChannelMember extends StatefulWidget {
  final isDelete;
  final channelId;
  ChannelMember({Key? key, this.isDelete, this.channelId}) : super(key: key);

  @override
  _ChannelMemberState createState() => _ChannelMemberState();
}

class _ChannelMemberState extends State<ChannelMember> {
  final TextEditingController _searchQuery = new TextEditingController();
  FocusNode _focusNode = FocusNode();
  List members = [];

  @override
  void initState() { 
    super.initState();
    final channelMember = Provider.of<Channels>(context, listen: false).getChannelMember(widget.channelId);
    members = channelMember;
  }

  onSearchMember(query, channelMember) async {
    if(query == "") {
      setState(() {
        members = channelMember;
      });
    }
    else{
      setState(() {
        members = channelMember.where((ele) => 
        Utils.unSignVietnamese(ele["full_name"]).contains(Utils.unSignVietnamese(query)) ? true : false
      ).toList();
      });
    }
  }

   
  @override
  Widget build(BuildContext context) {
    var _debounce;
    final auth = Provider.of<Auth>(context);
    final isDelete = widget.isDelete;
    final isDark = auth.theme == ThemeType.DARK;
    final channelMember = Provider.of<Channels>(context, listen: true).getChannelMember(widget.channelId,);

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        right: false,
        bottom: false,
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              width: 30,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                S.current.members,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                )
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 16),
                              width: 30,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true).push(createRoute(InviteMember(type: 'toChannel')));
                                },
                                child: Icon(PhosphorIcons.userPlus, size: 20,),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10,bottom: 10),
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: CupertinoTextField(
                            controller: _searchQuery,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false) _debounce.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                onSearchMember(value, channelMember);
                              });
                            },
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            prefix: Container(
                              padding: EdgeInsets.only(left: 12),
                              child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                            ),
                            padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                            autofocus: false,
                            placeholder: S.current.searchMember,
                            placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                            style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(child: Expanded(child: ListMember(isDelete: isDelete, type: "channel", members: members))),
              ],
            ),
          ),
          bottomNavigationBar: ChannelMemberBottom(isDelete: isDelete)
        ),
      ),
    );
  }
}
