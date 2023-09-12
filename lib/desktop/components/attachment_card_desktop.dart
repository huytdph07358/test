import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/accept_channel_workspace.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/image_detail.dart';
import 'package:workcake/desktop/components/images_gallery.dart';
import 'package:workcake/desktop/components/message_card_desktop.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/upload_status.dart';

class AttachmentCardDesktop extends StatefulWidget {
  final attachments;
  final isChannel;
  final isChildMessage;
  final isThread;
  final id;
  final userId;
  final snippet;
  final blockCode;
  final conversationId;
  AttachmentCardDesktop({
    Key? key,
    this.attachments,
    this.isChannel,
    this.isChildMessage,
    this.id,
    this.userId,
    this.isThread,
    this.snippet,
    this.blockCode,
    this.conversationId,
  }) : super(key: key);

  @override
  _AttachmentCardDesktopState createState() => _AttachmentCardDesktopState();
}

class _AttachmentCardDesktopState extends State<AttachmentCardDesktop> {
  String snippet = "";
  late TapGestureRecognizer _onTapTextSpan;

  @override
  void initState() {
    _onTapTextSpan = TapGestureRecognizer();
    super.initState();
  }

  @override
  void dispose() {
    _onTapTextSpan.dispose();
    super.dispose();
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
            recognizer: _onTapTextSpan..onTap = () async{
              Utils.openUrl(e);
            }
          );
        else return TextSpan(text: "$e ", style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff102A43)));
      }).toList()
    );
  }

  handleOrderToPos(key, orderId, shopId, messageId) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    String url = "${Utils.apiUrl}business/handle_order_to_pos?token=$token";

    try {
      var response  =  await Dio().post(url, data: {
        "messageId": messageId,
        "id": orderId,
        "shopId": shopId,
        "leveraPay": {"status": key}
      });
      var resData = response.data;

      if(resData["success"] == false) {}
    } catch (e) {
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  _createDirectMessageToSupportLeveraPay(String token) async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final data = {
      "users": ["0402cd81-7a28-48ce-bdf3-76335f7a138f"],
      "name": "Levera Pay Support"
    };
    await Provider.of<DirectMessage>(context, listen: false).createDirectMessage(token, data, context, userId);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final appInChannel = Provider.of<Channels>(context, listen: true).appInChannels;
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final token = Provider.of<Auth>(context, listen: false).token;
    final openThread = Provider.of<Messages>(context, listen: true).openThread;
    final showChannelSetting = Provider.of<Channels>(context, listen: true).showChannelSetting;
    final showDirectSetting = Provider.of<DirectMessage>(context, listen: true).showDirectSetting;
    var indexDM = Provider.of<DirectMessage>(context, listen: true).data.indexWhere((element) => element.id == widget.conversationId);
    final dm = indexDM  == -1 ? Provider.of<DirectMessage>(context, listen: true).directMessageSelected : Provider.of<DirectMessage>(context, listen: true).data[indexDM];
    List newAttachments = List.from(widget.attachments).where((e) => e["mime_type"] == null || e["mime_type"] != "image").toList();
    List images = (widget.attachments ?? []).where((e) => e["mime_type"] == "image").toList();
    newAttachments.add({"type": "image", "data": images});
    final isOnThreads = Provider.of<Workspaces>(context, listen: true).isOnThreads;
    final user = Provider.of<User>(context, listen: false).currentUser;

    return Container(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
          newAttachments.map<Widget>((att) {
            switch (att["type"]) {
              case "order":
                return Container(
                  width: 400,
                  margin: EdgeInsets.only(top: 10),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Color(0xffE4E7EB),
                        width: 1,
                      ),
                    ),
                    color: Color(0xffF5F7FA),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Container(
                            height: 32, width: 32,
                            decoration: BoxDecoration(
                              color: Color(0xffF6FFED),
                              border: Border.all(color: Color(0xff27AE60)),
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Icon(CupertinoIcons.check_mark, color: Color(0xff27AE60), size: 16,)
                          ),
                          title: Text(
                            'ORDER CONFIRMATION (ID: ${att['data']['order_id']})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          // subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                        ),
                        ListTile(
                          leading: Text(""),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${att['data']['elements'].length} items/${NumberFormat.simpleCurrency(locale: 'vi').format(att["data"]["summary"]["total_cost"])}",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Ordered on: ${DateFormatter().renderTime(DateTime.parse(att["data"]["timestamp"]), type: 'kk:mm dd/MM')}",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Phone number: ${att["data"]["phone_number"]}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Paid with: ${att["data"]["payment_method"]}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Ship to: ${att["data"]["address"]}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {_showAlert(context, att["data"]);},
                                child: Text(
                                  'Chi tiết đơn hàng',
                                  style: TextStyle(fontSize: 14, color: Colors.blueAccent, decoration: TextDecoration.underline),
                                ),
                              ),
                              SizedBox(height: att['data']['levera_pay']?['status'] == 'pending' ? 10 : 0),
                              att['data']['levera_pay']?['status'] == 'pending' ? Divider() : SizedBox(),
                              SizedBox(height: att['data']['levera_pay']?['status'] == 'pending' ? 10 : 0),
                              att['data']['levera_pay']?['status'] == 'pending'
                                  ? Row(
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Áp dụng'),
                                        ),
                                        style: TextButton.styleFrom(
                                          // primary: Colors.white,
                                          backgroundColor: Color(0xff2A5298),
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () {
                                          handleOrderToPos("apply", att["data"]["order_id"], att["data"]["shop_id"], widget.id);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Bỏ qua'),
                                        ),
                                        style: TextButton.styleFrom(
                                          // primary: Colors.white,
                                          backgroundColor: Colors.red[500],
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () {
                                          handleOrderToPos("ignore", att["data"]["order_id"], att["data"]["shop_id"], widget.id);
                                        },
                                      ),
                                    ],
                                  ) : Container(),
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  TextButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(CupertinoIcons.ellipses_bubble, size: 16, color: Color(0xff616E7C)),
                                          SizedBox(width: 8),
                                          Text('Liên hệ hỗ trợ', style: TextStyle(color: Color(0xff616E7C), fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3),
                                          side: BorderSide(color: Color(0xff7B8794))
                                        )
                                      )
                                    ),
                                    onPressed: () {_createDirectMessageToSupportLeveraPay(token);},
                                  ),
                                  SizedBox(width: 5),
                                  TextButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(CupertinoIcons.star, size: 16, color: Color(0xff616E7C)),
                                          SizedBox(width: 5),
                                          Text('Tìm hiểu dịch vụ', style: TextStyle(color: Color(0xff616E7C), fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3),
                                          side: BorderSide(color: Color(0xff7B8794))
                                        )
                                      )
                                    ),
                                    onPressed: () {},
                                  ),
                                ]
                              ),
                              SizedBox(height: 10)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              case "message_start":
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 55),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFfff7e6),
                      borderRadius: BorderRadius.circular(8)
                    ),

                  child: Text(att["data"], style: TextStyle(color: Color(0xFFfa8c16)),)
                  ),
                ) ;
              case "device_info":
                var time  = att["data"]["request_time"] == null ? "_" :  DateTime.fromMicrosecondsSinceEpoch(att["data"]["request_time"]);
                return Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFFf5f5f5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Device id:", style: TextStyle(color: Color(0xff262626), fontSize: 10, fontWeight: FontWeight.bold),),
                          Text("${Utils.getString(att["data"]["device_id"], 20)}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Color(0xff262626),))
                        ]
                      ),
                      Container(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Request time:", style: TextStyle(color: Color(0xff262626), fontSize: 10, fontWeight: FontWeight.bold)),
                          att["data"]["request_time"] == null ? Container() : Text("$time",overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Color(0xff262626),))
                        ]
                      ),
                    ],
                  )
                );
              case "action_button":
                return Column(
                  children: att["data"].map<Widget>((ele){
                    return TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xFF1890ff)), padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20))),
                      onPressed: ()async {
                        String url  = "${Utils.apiUrl}users/logout_device?token=$token";
                        LazyBox box = Hive.lazyBox('pairkey');
                        try{
                          var res = await Dio().post(url, data: {
                            "current_device": await box.get("deviceId"),
                            "data": await Utils.encryptServer({"device_id": ele["data"]["device_id"], "message_id" : widget.id})
                          });
                          if(res.data["success"] == false) throw res.data["message"];
                        }catch(e){
                           sl.get<Auth>().showErrorDialog(e.toString());
                        }
                      },
                      // padding: EdgeInsets.all(10),
                      child: Text(ele["label"], style: TextStyle(color: Color(0xFFffffff)))
                    );
                  }).toList(),
                );
              case "mention":
                var value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText.rich(
                      TextSpan(
                        children: att["data"].map<TextSpan>((e){
                          if (e["type"] == "text") value = e["value"];
                          if (e["type"] == "text" && Utils.checkedTypeEmpty(e["value"])) return renderText(e["value"]);
                          if (e["name"] == "all" || e["type"] == "all") return TextSpan(text: "@All ",  style: TextStyle(color: isDark ? Color(0xFFFAAD14) : Color(0xff1890FF)));

                          if (widget.isChannel) {
                            if (Utils.checkedTypeEmpty(e["name"]))
                              return TextSpan(text: "@${e["name"]} ", style: TextStyle(color: isDark ? Color(0xFFFAAD14) : Color(0xff1890FF)));
                            else
                              return TextSpan(text: "");
                          } else {
                            var u = dm == null ? [] : dm.user.where((element) => element["user_id"] == e["value"]).toList();
                            if (u.length > 0)
                              return TextSpan(text: "@${u[0]["full_name"]} ", style: TextStyle(color: isDark ? Color(0xFFFAAD14) : Color(0xff1890FF)));
                            else
                              return TextSpan(text: "");
                          }
                        }).toList()
                      ),
                    ),
                    if (Utils.checkedTypeEmpty(value)) MessageCardDesktop(message: value, id: widget.id, onlyPreview: true)
                  ],
                );

              case "block_code":
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: att["data"].map<Widget>((e){
                    if (e["type"] == "block_code" && Utils.checkedTypeEmpty(e["value"].trim())) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isDark ? Color(0xFF1D2C3B) : Colors.grey[200],
                          border: Border.all(
                            color: isDark ? Color(0xff334E68) : Colors.grey[400]!,
                            width: 0.5
                          ),
                        ),
                        padding: EdgeInsets.all(6),
                        width: isOnThreads
                          ? widget.isChildMessage || widget.isThread ? 260 : deviceWidth - 420
                          : widget.isChildMessage || widget.isThread ? 260 :  deviceWidth - 420 - (showDirectSetting || showChannelSetting || openThread ? 330 : 0),
                        child: SelectableText(
                          e["value"],
                          style: TextStyle(
                          fontSize: 13, height: 1.5,
                          fontFamily: 'Fira Code',
                          color: isDark ? Color(0xfff3f3f3) : Color(0xff3D3D3D),
                        ),
                        ),
                      );
                    }
                    if (e["type"] == "text" && e["value"] != "") {
                      return Container(
                        child: SelectableText(
                          e["value"],
                          style: TextStyle(height: 1.5)
                        )
                      );
                    } else {
                      return Container();
                    }
                  }).toList()
                );

              case "BizBanking":
                var appName = "BizBanking";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF1890FF),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Text(
                            "B",
                            style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appName,
                                style : TextStyle(
                                  fontWeight:  FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Color(0xFFd8dcde) : Colors.grey[800]
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                att["data"]["command"],
                                style: TextStyle(
                                  color: Color(0xFFBFBFBF),
                                  fontSize: 10
                                ),
                                textAlign: TextAlign.left
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text(
                        att['data']['transfer']['success'] == null
                          ? "${att['data']['transfer']['date']}: ${att['data']['transfer']['id']}, ${att['data']['transfer']['note']}, ${att['data']['transfer']['amount']}, ${att['data']['transfer']['remain']}"
                          : att['data']['transfer']['message'],
                        style: TextStyle(
                          fontSize: 10
                        ),
                      ),
                    ),
                    Container(height: 8)
                  ],
                );

              case "bot":
                var appId  = att["bot"]["id"];
                var app =  appInChannel.where((element) {
                  return element["app_id"] == appId;
                }).toList();
                var appName  = " ";
                if (app.length > 0) appName = app[0]["app_name"];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF1890FF),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Text(
                            appName[0].toUpperCase(),
                            style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appName,
                                style : TextStyle(
                                  fontWeight:  FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Color(0xFFd8dcde) : Colors.grey[800]
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "/" + att["data"]["command"] + " ${att["data"]["text"]}",
                                style: TextStyle(
                                  color: Color(0xFFBFBFBF),
                                  fontSize: 10
                                ),
                                textAlign: TextAlign.left
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    att["data"]["result"] != null ?
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(att["data"]["result"]["body"], textAlign: TextAlign.left, style: TextStyle(fontSize: 10),),
                      )
                      : Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text("Processing", style: TextStyle(fontSize: 10),),
                      ),
                    Container(height: 8)
                  ],
                );

              case "befor_upload":
                return StreamBuilder(
                  stream: StreamUploadStatus.instance.status,
                  builder: (context, status) {
                    double statusUploadAtt = 0.0;
                    if (status.data != null) {
                      try {
                        statusUploadAtt = (status.data as Map)[att["att_id"]];
                      } catch (e) {
                        statusUploadAtt = 1.0;
                      }
                    }
                    return Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 5, top:  att["success"] == null || att["success"] ? 0 : 5),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF434343) : Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: Opacity(
                        opacity: att["success"] == null || att["success"] ? 1: 0.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text((att["success"] == null || att["success"] ? "Uploading" : "Upload fail") + " ${att["name"] ?? ""}"),
                            Text(statusUploadAtt == 1.0 ? "processing": "${(statusUploadAtt * 100.0).round()} %"),
                          ],
                        ),
                      )
                    );
                  }
                );
              case "invite":
                var channelId = att["data"]["channel_id"] ?? null;
                var workspaceId = att["data"]["workspace_id"] ?? null;
                var inviteUser = att["data"]["invite_user"] ?? null;
                var channelName = att["data"]["channel_name"] ?? null;
                var workspaceName = att["data"]["workspace_name"] ?? null;
                var members = att["data"]["members"] ?? null;
                var isAccepted = att["data"]["isAccepted"] ?? null;

                return InkWell(
                  onTap: () => isAccepted == null ? showDialog(
                    context: context,
                    builder: (context) => AcceptChannelWorkspace(
                      isChannel: channelId != null ? true : false,
                      otherUser: inviteUser,
                      inviteWorkspace: {"name": workspaceName ?? "null","workspace_id": workspaceId} ,
                      inviteChannel: {"name": channelName ?? "null","channel_id": channelId},
                      members: members,
                      id: widget.id,
                    ),
                  ) : (){},
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3)
                    ),
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: isAccepted == null ? MaterialStateProperty.all(Colors.blue) : MaterialStateProperty.all(Colors.grey[500])
                          ),
                          onPressed: isAccepted == null ? () {
                            if(channelId != null){
                              Provider.of<Channels>(context, listen: false).joinChannelByInvitation(token, workspaceId, channelId, user["email"], 1,inviteUser, widget.id).then((value){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(value),
                                    );
                                  },
                                );
                              });
                            } else {
                              Provider.of<Workspaces>(context, listen: false).joinWorkspaceByInvitation(token, workspaceId, user["email"], 1, inviteUser, widget.id).then((value) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(value),
                                    );
                                  },
                                );
                              });
                            }
                          } :(){},
                          child: isAccepted == null || isAccepted == false ? Text("Accept", style: TextStyle(color: Colors.black)) : Text("Accepted", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      SizedBox(width: 60),
                      Container(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: isAccepted == null ? MaterialStateProperty.all(Colors.red) : MaterialStateProperty.all(Colors.grey[500])
                          ),
                          onPressed: isAccepted == null ? () {
                            if(channelId != null){
                              Provider.of<Channels>(context, listen: false).declineInviteChannel(token, workspaceId, channelId, inviteUser, widget.id).then((value){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(value),
                                    );
                                  },
                                );
                              });
                            }
                            else {
                              Provider.of<Workspaces>(context, listen: false).declineInviteWorkspace(token, workspaceId, inviteUser, widget.id).then((value){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(value),
                                    );
                                  },
                                );
                              });
                            }
                          } : (){},
                          child: isAccepted == null || isAccepted == true ? Text("Discard",style: TextStyle(color: Colors.black)) : Text("Discarded", style: TextStyle(color: Colors.black))
                        ),
                      )
                    ],
                    )
                  ),
                );

              case "image":
                if (att["data"].length > 0) {
                  return ImagesGallery(isChildMessage: widget.isChildMessage, att: att, isThread: widget.isThread, id: widget.id, isConversation: !widget.isChannel);
                } else {
                  return Container();
                }

              default:
                switch (att["mime_type"]) {
                  case "image":
                    var tag  = Utils.getRandomString(30);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return ImageDetail(url: att["content_url"], id: widget.id, full: true, tag: tag);
                        }));
                      },
                      child: att["content_url"] == null
                        ? Text("Message unavailable", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w200))
                        : Hero(
                          tag: tag,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 400,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: CachedImage(
                              att["content_url"],
                              radius: 5,
                              fit: BoxFit.contain
                            )
                          ),
                        )
                    );

                  case "html":
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? Color(0xFF1D2C3B) : Colors.grey[200],
                        border: Border.all(
                          color: isDark ? Color(0xff334E68) : Colors.grey[400]!,
                          width: 0.5
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      width: isOnThreads
                        ? widget.isChildMessage || widget.isThread ? 260 : deviceWidth - 420
                        : widget.isChildMessage || widget.isThread ? 260 :  deviceWidth - 420 - (showDirectSetting || showChannelSetting || openThread ? 330 : 0),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => Utils.openUrl(att["content_url"]),
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                              text: widget.snippet,
                              style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 13, height: 1.5,
                                color: isDark ? Colors.white70 : Colors.grey[800]
                              ),
                              children: [
                                TextSpan(
                                  text: "\nSee more ...",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13, color: Colors.blueAccent)
                                )
                              ]
                            )
                          ),
                        )
                      )
                    );

                  case "block_code":
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? Color(0xFF1D2C3B) : Colors.grey[200],
                        border: Border.all(
                          color: isDark ? Color(0xff334E68) : Colors.grey[400]!,
                          width: 0.5
                        ),
                      ),
                      padding: EdgeInsets.all(6),
                      width: isOnThreads
                      ? widget.isChildMessage || widget.isThread ? 260 : deviceWidth - 420
                      : widget.isChildMessage || widget.isThread ? 260 :  deviceWidth - 420 - (showDirectSetting || showChannelSetting || openThread ? 330 : 0),
                      child: SelectableText(
                        widget.blockCode,
                        style: TextStyle(
                          fontSize: 13, height: 1.5,
                          fontFamily: 'Fira Code',
                          color: isDark ? Color(0xfff3f3f3) : Color(0xff3D3D3D),
                        ),
                      ),
                    );

                  default:
                    return Container(
                      margin: EdgeInsets.only(top: 3, bottom: 3),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContex)  {
                              return CustomDialogNew(
                                title: "Download attachment",
                                content: "Do you want  to download ${att["name"]}",
                                confirmText: "Download",
                                onConfirmClick: () {
                                  Provider.of<Work>(dialogContex, listen: false).addTaskDownload(att);
                                },
                                quickCancelButton: true,
                              );
                            }
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 4.0, right: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0XFF27AE60)
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Wrap(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0XFF27AE60)
                                ),
                                child: Icon(Icons.save_alt, size: 13.0, color: Colors.white)
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, left: 8.0),
                                child: Text(att["name"] ?? "", style: TextStyle(color: Color(0XFF27AE60))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                }
            }
          }
        ).toList(),
      )
    );
  }

  void _showAlert(BuildContext context, order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32)
        ),
        content: ShowInfomationOrder(
          order: order
        )
      )
    );
  }
}

class ShowInfomationOrder extends StatefulWidget {
  final order;
  const ShowInfomationOrder({ Key? key, this.order }) : super(key: key);

  @override
  _ShowInfomationOrderState createState() => _ShowInfomationOrderState();
}

class _ShowInfomationOrderState extends State<ShowInfomationOrder> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    print(order);

    return Container(
      width: 450,
      height: 550,
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xff52606D),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
            ),
            child: Center(
              child: Text(
                'ORDER CONFIRMATION (ID: ${order["order_id"]})',
                style: TextStyle(color: Colors.white, fontSize: 13)
              )
            )
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ordered on", style: TextStyle(fontSize: 13, color: Color(0xff52606D))),
                          SizedBox(height: 8),
                          Text(
                            DateFormatter().renderTime(DateTime.parse(order["timestamp"]), type: 'kk:mm dd/MM'),
                            style: TextStyle(
                              color: Color(0xff1F2933),
                              fontSize: 14
                            )
                          ),
                        ],
                      )
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Paid with on", style: TextStyle(fontSize: 13, color: Color(0xff52606D))),
                          SizedBox(height: 8),
                          Text(
                            order["payment_method"],
                            style: TextStyle(
                              color: Color(0xff1F2933),
                              fontSize: 14
                            )
                          ),
                        ],
                      )
                    ),
                  ]
                ),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone number", style: TextStyle(fontSize: 13, color: Color(0xff52606D))),
                          SizedBox(height: 8),
                          Text(
                            order["phone_number"],
                            style: TextStyle(
                              color: Color(0xff1F2933),
                              fontSize: 14
                            )
                          ),
                        ],
                      )
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ship to", style: TextStyle(fontSize: 13, color: Color(0xff52606D))),
                          SizedBox(height: 8),
                          Text(
                            order["address"],
                            style: TextStyle(
                              color: Color(0xff1F2933),
                              fontSize: 14
                            )
                          ),
                        ],
                      )
                    ),
                  ]
                ),
                SizedBox(height: 24),
                Align(alignment: Alignment.topLeft, child: Text('Items', style: TextStyle(fontSize: 14, color: Color(0xff52606D)))),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: Container(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: order["elements"].length,
                      itemBuilder: (BuildContext context, int idx) {
                        final quantity = order["elements"][idx]["quantity"];
                        final imageUrl = order["elements"][idx]["image_url"];
                        final title = order["elements"][idx]["title"];
                        final subtitle = order["elements"][idx]["subtitle"];
                        final price = NumberFormat.simpleCurrency(locale: 'vi').format(order["elements"][idx]["price"]);

                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                leading: imageUrl != ""
                                  ? Container(
                                    height: 40, width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: CachedImage(imageUrl, fit: BoxFit.contain))
                                  : Container(
                                    child: Icon(Icons.image),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    width: 40, height: 40
                                  ),
                                title: Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xff1F2933), fontSize: 14, fontWeight: FontWeight.w500),),
                                ),
                                subtitle: Text(
                                  subtitle != ""
                                      ? subtitle
                                      : "No variation data",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Color(0xff52606D), fontSize: 13)),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text("$quantity", style: TextStyle(fontSize: 14, color: Color(0xff52606D)))
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text(price, style: TextStyle(fontSize: 14, color: Color(0xff52606D)))
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(height: 1, thickness: 1),
                SizedBox(height: 16),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text("Total", style: TextStyle(fontSize: 14, color: Color(0xff1F2933), fontWeight: FontWeight.w500))
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "${order['elements'].length}",
                            style: TextStyle(fontSize: 14, color: Color(0xff1F2933), fontWeight: FontWeight.w500)
                          )
                        )
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "${NumberFormat.simpleCurrency(locale: 'vi').format(order['summary']['total_cost'])}",
                            style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500)
                          )
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}