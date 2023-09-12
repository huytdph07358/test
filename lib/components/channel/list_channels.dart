import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/create_channels.dart';
import 'package:workcake/models/models.dart';


class ListChannel extends StatefulWidget {
  ListChannel({
    Key? key,
    @required this.title,
    @required this.channels,
    @required this.changePageView,
    this.id,
    this.currentUser
  }) : super(key: key);

  final title;
  final channels;
  final id;
  final currentUser;
  final changePageView;

  @override
  _ListChannelState createState() => _ListChannelState();
}

class _ListChannelState extends State<ListChannel> {
  bool open = true;

  @override
  void initState() {
    super.initState();
  }

  showCurrentChannel(currentChannel) {
    if (currentChannel != null) {
      final index = widget.channels.indexWhere((e) => e["id"] == currentChannel["id"]);

      if (!open && index != -1) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final currentUser = Provider.of<Workspaces>(context, listen: true).currentMember;
    
    return Column(
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              key: Key(widget.id.toString()),
              onTap: (){
                  this.setState(() {
                    open = !open;
                  });
              },
              child: Container(
                padding: EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    Icon(
                      open ? PhosphorIcons.caretDownBold : PhosphorIcons.caretRightBold,
                      color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D),
                      size: 15,
                    ),
                    SizedBox(width: 8,),
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[500] : Color(0xff5E5E5E),
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  ]
                ),
              ),
            ),
            Container(
              height: 32,
              child: ((currentUser["role_id"] ?? 0) <= 3) ? InkWell(
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  child: Icon(
                    PhosphorIcons.plusBold,
                    size: 18,
                    color: isDark ? Color(0xffEDEDED) : Color(0XFF3d3d3d)
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateChannel()));
                }
              ) : SizedBox(),
            )
          ]
        ),

        if (open) Column(
          children: widget.channels.map<Widget>((e){
            return ChannelItem(channel: e, changePageView: widget.changePageView);
          }).toList()
        ),

        if (showCurrentChannel(currentChannel)) Container(
          child: ChannelItem(channel: currentChannel, changePageView: widget.changePageView)
        )
      ]
    );
  }
}

class ChannelItem extends StatefulWidget {
  ChannelItem({
    key,
    @required this.changePageView,
    @required this.channel
  }) : super(key: key);

  final changePageView;
  final channel;

  @override
  _ChannelItemState createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> {
  @override
  Widget build(BuildContext context) {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final channel = widget.channel;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;

    return Material(
      color: isDark ? Color(0xff2E2E2E) : Colors.white,
      child: InkWell(
        onTap: () async {
          Provider.of<Channels>(context, listen: false).selectChannel(auth.token, currentWorkspace["id"], channel['id']);
          if (auth.channel != null) auth.channel.push(
            event: "join_channel",
            payload: {"channel_id": channel['id'], "workspace_id": currentWorkspace["id"], "ssid": NetworkInfo().getWifiName()}
          );
          Provider.of<Channels>(context, listen: false).onChangeLastChannel(currentWorkspace["id"], channel['id']);
          Provider.of<Messages>(context, listen: false).loadMessages(auth.token, currentWorkspace["id"], channel['id'], isReset: true);
          Provider.of<Channels>(context, listen: false).setCurrentChannel(channel['id']);
          Provider.of<Channels>(context, listen: false).loadCommandChannel(auth.token, currentWorkspace["id"], channel['id']);
          Provider.of<Channels>(context, listen: false).getChannelMemberInfo(auth.token, currentWorkspace["id"], channel['id'], currentUser["id"]);
          Work.platform.invokeMethod("onClick_channel_clear_notification", {
            "channel_id" : channel['id'].toString()
          });
          widget.changePageView(1);
        },
        child: Container(
          padding: EdgeInsets.only(left: 14, top: 8, bottom: 8),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: (channel["id"] == currentChannel["id"]) ? BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3)
          ) : BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (channel["id"] == currentChannel["id"]) || (((channel["seen"] == false && channel["status_notify"] != "OFF" && channel["status_notify"] != "MENTION")|| (channel["new_message_count"] != null && channel["new_message_count"] > 0 && channel["status_notify"] == "MENTION")))
                    ? channel['is_private']
                      ? isDark ? SvgPicture.asset("assets/images/icons/lockDark.svg") : SvgPicture.asset("assets/images/icons/lockLight.svg")
                      : isDark ? SvgPicture.asset("assets/images/icons/#Dark.svg") : SvgPicture.asset("assets/images/icons/#Light.svg")
                    : channel["status_notify"] == "OFF" 
                      ? channel['is_private']
                        ? isDark ? SvgPicture.asset("assets/images/icons/lockOffDark.svg") :SvgPicture.asset("assets/images/icons/lockOffLight.svg") 
                        : isDark ? SvgPicture.asset("assets/images/icons/#OffDark.svg") : SvgPicture.asset("assets/images/icons/#OffLight.svg")
                      : channel['is_private']
                        ? isDark ? SvgPicture.asset("assets/images/icons/lockDisableDark.svg") :SvgPicture.asset("assets/images/icons/lockDisableLight.svg") 
                        : isDark ? SvgPicture.asset("assets/images/icons/#DisableDark.svg") : SvgPicture.asset("assets/images/icons/#DisableLight.svg"),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 3),
                            child: Text(
                              channel['name'] ?? "",
                              style: TextStyle(
                                fontWeight: channel["seen"] == false
                                  ? channel["status_notify"] == "OFF" || (channel["status_notify"] == "MENTION" && (channel["new_message_count"] != null && channel["new_message_count"] == 0))
                                    ? FontWeight.w400
                                    : FontWeight.w700
                                  : FontWeight.w400,
                                fontSize: 16,
                                color: (channel["id"] == currentChannel["id"])
                                  ? isDark ? Colors.white.withOpacity(0.8) : Color(0xff2E2E2E)
                                  : (channel["seen"] == false && channel["status_notify"] != "OFF" && (channel["status_notify"] != "MENTION" || (channel["status_notify"] == "MENTION" && (channel["new_message_count"] != null && channel["new_message_count"] > 0))))
                                    ? isDark ? Color(0xfFEDEDED) : Color(0xff2E2E2E)
                                    : channel["status_notify"] == "NORMAL" || channel["status_notify"] == "SILENT" || (channel["status_notify"] == "MENTION")
                                      ? isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                                      : isDark ? Colors.grey[700] : Colors.grey
                              ),
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                          SizedBox(height: 4)
                        ]
                      )
                    )
                  ]
                ),
              ),
              Row(
                children: [
                  (channel["seen"] == false && channel["new_message_count"] != null && channel["new_message_count"] > 0) && channel["status_notify"] != "OFF"
                    ? Container(
                        margin: EdgeInsets.only(right: channel["status_notify"] == "OFF" ? 4 : 8),
                        padding: EdgeInsets.only(left: 9, right: 9),
                        height: 18,
                        decoration: BoxDecoration(
                          color: Color(0xffFF4D4F),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Center(
                          child: Text(
                            channel["new_message_count"].toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12, height: 1),
                          ),
                        ),
                      )
                    : Container(),
                  channel["status_notify"] == "OFF" ?
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Icon(
                        PhosphorIcons.bellSlash,
                        size: 19,
                        color: (channel["id"] == currentChannel["id"])
                          ? auth.theme == ThemeType.DARK ? Color(0xfFEDEDED) : Color(0xff5E5E5E)
                          : isDark ? Color(0xffA6A6A6) : Color(0xff828282)
                      ),
                    ) 
                    : Container()
                ],
              ),
            ]
          )
        )
      ),
    );
  }
}

showCreateChannel(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return CreateChannel();
    }
  );
}