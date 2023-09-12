import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/add_app.dart';
import 'package:workcake/components/apps.dart';
import 'package:workcake/components/channel/invite_channel.dart';
import 'package:workcake/components/channel/list_channels.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/thread/thread_workpsace.dart';
import '../../generated/l10n.dart';

class RightServerDetails extends StatefulWidget {
  final changePageView;

  RightServerDetails({
    Key? key,
    this.changePageView
  }) : super(key: key);
  @override
  _RightServerDetailsState createState() => _RightServerDetailsState();
}

class _RightServerDetailsState extends State<RightServerDetails> {
  bool open = false;
  final listActive = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final channels = currentWorkspace["id"] != null
      ? Provider.of<Channels>(context, listen: true).data.where((e) => e["workspace_id"] == currentWorkspace["id"] && !Utils.checkedTypeEmpty(e["is_archived"])).toList()
      : [];
    final noBlurChannels = channels.where((c) => c["status_notify"] == "NORMAL" || c["status_notify"] == "SILENT" || c["status_notify"] == "MENTION").toList();
    final blurChannels = channels.where((c) => c["status_notify"] == "OFF").toList();
    final newChannels = noBlurChannels + blurChannels;
    final pinnedChannel = newChannels.where((e) => e["pinned"]).toList();
    final unpinChannel = newChannels.where((e) => !e["pinned"]).toList();
    final currentUser = Provider.of<Workspaces>(context, listen: true).currentMember;
    final listActive = listAllApp.where((e) => (currentWorkspace["app_ids"] ?? []).contains(e["id"])).toList();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (pinnedChannel.length > 0) Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: isDark ? Color(0xff3D3D3D) : Color(0xffDBDBD)
                        )
                      )
                    ),
                    child: ListChannel(title: S.current.pinned, channels: pinnedChannel, changePageView: widget.changePageView)
                  ),
                  ListChannel(title: S.current.channels, channels: unpinChannel, changePageView: widget.changePageView),
                  ExpandableNotifier(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
                      child: InkWell(
                        child: ScrollOnExpand(
                          child: Column(
                            children: [
                              ExpandablePanel(
                                theme: ExpandableThemeData(
                                  iconRotationAngle: 0,
                                  iconPlacement: ExpandablePanelIconPlacement.left ,
                                  expandIcon: PhosphorIcons.caretRight,
                                  collapseIcon: PhosphorIcons.caretDown,
                                  iconSize: 16,
                                  iconColor: isDark ? Color(0xffEDEDED) : Color(0XFF3d3d3d),
                                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                                  tapBodyToCollapse: true,
                                ),
                                header: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("APP", style: TextStyle(
                                          fontSize: 15.5,
                                          color: isDark ? Colors.grey[500] : Color(0xff5E5E5E),
                                          fontWeight: FontWeight.w600
                                        )),
                                        SizedBox(width: 4,),
                                        listActive.length > 0 ? Text(
                                          "(${listActive.length})",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: isDark ? Colors.grey[500] : Color(0xff5E5E5E),
                                          )
                                        ): SizedBox()
                                      ],
                                    ),
                                    Container(
                                      height: 32,
                                      child: ((currentUser["role_id"] ?? 0) <= 2) ?InkWell(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 16, right: 13, bottom: 10, top: 8),
                                          child: Icon(
                                            PhosphorIcons.plusBold,
                                            size: 17,
                                            color: isDark ? Color(0xffEDEDED) : Color(0XFF3d3d3d)
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddApp()));
                                        }
                                      ) : SizedBox(),
                                    )
                                  ],
                                ),
                                collapsed: Container(),
                                expanded: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    children: listActive.map((e) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Apps(app: e)));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 9),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 20),
                                              Container(
                                                color: Colors.white,
                                                child: Image.asset(
                                                  e["avatar_app"].toString(),
                                                  width: 20,
                                                  height: 20,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(e["name"].toString(), style: TextStyle(
                                                fontSize: 15.5,
                                                color: isDark ? Colors.grey[500] : Color(0xff5E5E5E),
                                                fontWeight: FontWeight.w600
                                              ))
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                builder: (context, collapsed, expanded) => Expandable(collapsed: collapsed, expanded: expanded),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

showInviteChannel(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return Container(
        child: InviteChannel()
      );
    }
  );
}

class IconThreadWorkspace extends StatefulWidget {
  final workspaceId;
  const IconThreadWorkspace({ Key? key, required this.workspaceId }) : super(key: key);

  @override
  _IconThreadWorkspaceState createState() => _IconThreadWorkspaceState();
}

class _IconThreadWorkspaceState extends State<IconThreadWorkspace> {
  checkUnreadThread() {
    final workspaceId = Provider.of<Workspaces>(context, listen: true).currentWorkspace["id"];
    final dataThreads = Provider.of<ThreadUserProvider>(context, listen: true).threadsWorkspace;
    final index = dataThreads.indexWhere((e) => "${e.workspaceId}" == "$workspaceId");
    num count = 0;
    bool unread = false;

    if (index != -1) {
      final threadsWorkspace = dataThreads[index].data;

      for (var i = 0; i < threadsWorkspace.length; i++) {
        count += threadsWorkspace[i].mentionCount;

        if (threadsWorkspace[i].unread) {
          unread = true;
        }
      }
    }

    return {
      "unread": unread,
      "count": count
    };
  }
  @override
  Widget build(BuildContext context) {
    final unreadThread = checkUnreadThread()["unread"];
    final mentionCount = checkUnreadThread()["count"];
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return  Container(
      child: InkWell(
        onTap: (){
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
            return ThreadWorkspace(workspaceId: widget.workspaceId);
          }));
        },
        child: Container(
          child: Stack(
            children: [
              Center(
                child: isDark ? SvgPicture.asset("assets/icons/thread_light.svg", color: Colors.white,) : SvgPicture.asset("assets/icons/thread_light.svg",)
              ),
              (unreadThread || mentionCount > 0) ? Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.only(right: 8),
                  decoration:  BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  width: 8, height:  8, ),
              ) : Container()
            ],
          ),
        )
      ),
    );
  }
}