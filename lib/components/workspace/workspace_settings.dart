import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/route_animation.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/create_channels.dart';
import 'package:workcake/components/invite_member.dart';
import 'package:workcake/components/workspace/workspace_members.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class WorkspaceSettings extends StatefulWidget {
  WorkspaceSettings({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => WorkspaceSettingsState();
}

class WorkspaceSettingsState extends State<WorkspaceSettings> {
  File? image;
  var imgName;

  @override
  void initState() {
    super.initState();
    final workspaceMembers = Provider.of<Workspaces>(context, listen: false).members;

    //Trường hợp vào app bị lỗi mạng k getInfoWorkspace được nên mình get lại lúc init
    //Cái members này không thể rỗng được vì tối thiểu phải có mình nên check member để get lại
    if (workspaceMembers.length == 0) {
      final token = Provider.of<Auth>(context, listen: false).token;
      final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
      Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, currentWorkspace["id"], context);
    }
  }

  //Pick image from gallery -> upload avt
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final file = await ImageCropper().cropImage(sourcePath: image.path, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
      if(file == null) return;
      
      setState(() {
        this.image = file;
        imgName = image.name;
      });
      uploadAvatarWorkspace(context);
    } on PlatformException catch (e) {
        print('Failed to pick image: $e');
    }
  }

  showDialogChangeName(context) {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final auth = Provider.of<Auth>(context, listen: false);
    String nickname = currentMember["nickname"] ?? currentUser["full_name"];
    String title = S.current.changeNickname;

    onChangeNickname(value) async {
      if (value != "") {
        Map member = new Map.from(currentMember);
        member["nickname"] = value;
        await Provider.of<Workspaces>(context, listen: false).changeWorkspaceMemberInfo(auth.token, currentWorkspace["id"], member);
        Navigator.of(context, rootNavigator: true).pop("Discard");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(title: title, textDisplay: nickname, onSaveString: onChangeNickname);
      }
    );
  }

  uploadAvatarWorkspace(context) async {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false ).currentWorkspace;
    final auth = Provider.of<Auth>(context, listen: false);
    if (image != null) {
      final workspaceId = currentWorkspace["id"];
      final uploadFile = {
        "filename": imgName,
        "path": base64Encode(await image!.readAsBytes()),
        "height": 120,
        "width": 120,
      };

      await Provider.of<Workspaces>(context, listen: false).uploadAvatar(auth.token, workspaceId, uploadFile, "image");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final workspaceMembers = Provider.of<Workspaces>(context, listen: true).members;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final onlineUser = workspaceMembers.where((e) => e["is_online"] == true).length;
    final currentUser = Provider.of<Workspaces>(context, listen: true).currentMember;

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
                              child: RichText(
                                text: TextSpan(
                                  text: S.current.workspaceDetails,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  )
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          ),
                        ),
                        Container(width: 50,)
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Material(
                      color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom:BorderSide(width: 6, color:isDark? Color(0xFF3D3D3D):Color(0xFFEDEDED)),
                              )
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(height: 18),
                                (currentUser["role_id"] ?? 0) > 2
                                  ? CachedAvatar(currentWorkspace["avatar_url"], width: 110, name: currentWorkspace["name"], height: 110)
                                  : TextButton(
                                      onPressed: () {
                                        pickImage();
                                      },
                                      child: StackAvatar(currentWorkspace: currentWorkspace),
                                    ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: currentWorkspace["name"],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:isDark ? Color(0xFFDBDBDB) : Color(0xFF3D3D3D)
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Material(
                                            color: Color(0xFF27AE60),
                                            child: SizedBox(width: 10, height: 10)),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5, right: 20),
                                          child: Text("$onlineUser ${S.current.online}",
                                            style: TextStyle(fontSize: 13)
                                          )
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 6),
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Material(
                                            color: Color(0xFFA6A6A6),
                                            child: SizedBox(width: 10, height: 10)
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "${workspaceMembers.length} ${S.current.members}",
                                            style: TextStyle(fontSize: 13)
                                          )
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25)
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     border: Border(bottom:BorderSide(width: 0.75, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),
                          //     )
                          //   ),
                          //   padding: EdgeInsets.symmetric(horizontal: 14,vertical: 12),
                          //   child: Row(
                          //      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //      children: [
                          //        Text(S.current.settings,style: TextStyle(color: isDark? Color(0XFFA6A6A6): Color(0xFF828282),height: 1.57,fontSize: 14,fontWeight: FontWeight.w700)),
                          //    ])),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     border: Border(bottom:BorderSide(width: 6, color:isDark?Color(0xFF3D3D3D): Color(0xFFEDEDED)),)
                          //   ),
                          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Icon(PhosphorIcons.smiley,size: 18,),
                          //           SizedBox(width: 10,),
                          //           Text("Emojis",style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D), height: 1.57, fontSize: 15,
                          //           fontWeight: FontWeight.w400)),
                          //           ],
                          //         ),
                          //         Icon(PhosphorIcons.caretRight,size: 18,
                          //         ),
                          //       ]
                          //     )
                          // ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),)
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.current.settings.toUpperCase(),style: TextStyle(color: isDark? Color(0xFFA6A6A6): Color(0xFF828282),fontSize: 14,height: 1.57,fontWeight: FontWeight.w700)),
                              ]
                            )
                          ),
                          if ((currentUser["role_id"] ?? 0) < 2) InkWell(
                            onTap: () {
                              showCustomDialog(context, S.current.editWorkspaceName);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),
                              )
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Row(
                                children: [
                                  Icon(PhosphorIcons.briefcase,size: 18,),
                                  SizedBox(width: 10,),
                                  Text(S.current.workspaceName,style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D), height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                  Icon(PhosphorIcons.pencilLine,size: 18,),
                                ]
                              )
                            ),
                          ),         
                          InkWell(
                            onTap: () {
                              Navigator.push(
                              context,
                                MaterialPageRoute(builder: (context) => WorkspaceSettingsRole()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),)
                              ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.users,size: 18,),
                                      SizedBox(width: 10,),
                                      Text(S.current.members,style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                  Icon(PhosphorIcons.caretRight,size: 18),
                                ]
                              )
                            ),
                          ),
                           if((currentUser["role_id"] ?? 0) <= 3 || currentUser['user_id'] == currentWorkspace['owner_id']) InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(createRoute(InviteMember(type: 'toWorkspace')));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),
                                )
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.userPlus,size: 18.5,),
                                      SizedBox(width: 10,),
                                      Text(S.current.invite,style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D), height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                  Icon( PhosphorIcons.caretRight,size: 18,),
                                ]
                              )
                            ),
                          ),
                          InkWell(
                            onTap: () => showDialogChangeName(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              height: 45,
                              decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)))),
                              child: Row(
                                children: [
                                  Icon(
                                    PhosphorIcons.pencilLine,
                                    color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),
                                    size: 18,
                                  ),
                                  SizedBox(width: 10,),
                                  Text(S.current.changeNickname, style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),height: 1.3, fontSize: 16,fontWeight: FontWeight.w400)), 
                                ],
                              ),
                            ),
                          ),
                          if((currentUser["role_id"] ?? 0) <= 3) InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateChannel()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),
                              )
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Icon(PhosphorIcons.plusCircle, size: 18),
                                    ),
                                    SizedBox(width: 10,),
                                    Text(S.current.createChannel,style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D), height: 1.37, fontSize: 16,fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ]
                              )
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showCustomDialogJoinToChannel(context, S.current.joinChannel);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),
                              )
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(PhosphorIcons.linkSimple, size: 18),
                                    SizedBox(width: 10,),
                                    Text(S.current.joinChannel,style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D), height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ]
                              )
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showConfirmDialog(context, false);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 13),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/icons/LeaveChannel.svg', width: 18, color: Palette.errorColor),
                                  SizedBox(width: 10,),
                                                                    Text(S.current.leaveWorkspace,style: TextStyle(color: Palette.errorColor, height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                ]
                              )
                            ),
                          ),
                          if(currentUser["user_id"] == currentWorkspace["owner_id"]) InkWell(
                            onTap: () {
                              showConfirmDialog(context, true);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom:BorderSide(width: 0.3, color:isDark? Color(0xFF5E5E5E):Color(0xFFC9C9C9)),)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 13),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.trashSimple, size: 18, color: Palette.errorColor),
                                  SizedBox(width: 10,),
                                  Text(S.current.deleteWorkspace,style: TextStyle(color: Palette.errorColor, height: 1.57, fontSize: 16,fontWeight: FontWeight.w400)),
                                ]
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
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
class StackAvatar extends StatelessWidget {
  final currentWorkspace;
  const StackAvatar({Key? key, @required this.currentWorkspace}): super(key: key);
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      child: Stack(children: [
        Container(
          width: 120,
          height: 120,
          padding: EdgeInsets.all(5),
          child: currentWorkspace["avatar_url"] != "" && currentWorkspace["avatar_url"] != null
            ? CachedImage(currentWorkspace["avatar_url"],
            radius: 75, width: 75, height: 92)
            : CircleAvatar(
              backgroundColor: Utils.getPrimaryColor(),
              radius: 32,
              child: Text(currentWorkspace["name"].substring(0, 1).toUpperCase(),style: TextStyle(
                fontWeight: FontWeight.bold,fontSize: 30.0,color: Color(0xffffffff)),
                ),
              ),
            ),
            currentWorkspace["avatar_url"] != null && currentWorkspace["avatar_url"] != ""
            ? Positioned(
              bottom: 3,
              right: 10,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isDark ? Color(0xFF2E2E2E) : Colors.white,
                ),
                child: Icon(PhosphorIcons.camera,size: 18,color: isDark ? Colors.grey[300] : Colors.grey[600]),
              ))
            : Positioned(
              right: 0,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isDark ? Color(0xFF2E2E2E) : Colors.white,
                ),
                child: Icon(PhosphorIcons.camera,size: 18,color: isDark ? Colors.grey[300] : Colors.grey[600]),
              ))
      ]),
    );
  }
}
showConfirmDialog(context, bool isDelete) {
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  final auth = Provider.of<Auth>(context, listen: false);

  onConfirm() async {
    if(isDelete) {
      await Provider.of<Workspaces>(context, listen: false).deleteWorkspace(auth.token, currentWorkspace["id"], context);
    } else {
      Provider.of<Workspaces>(context, listen: false).leaveWorkspace(auth.token, currentWorkspace["id"], auth.userId);
    }

    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogNew(
        title: "${isDelete ? S.current.deleteWorkspace : S.current.leaveWorkspace}", 
        content: isDelete ? S.current.descDeleteWorkspace : S.current.descLeaveWorkspace,
        confirmText: "${isDelete ? S.current.deleteWorkspace : S.current.leaveWorkspace}",
        onConfirmClick: onConfirm,
        quickCancelButton: true,
      );
    }
  );
}


showCustomDialog(context, titleDialog) {
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  final auth = Provider.of<Auth>(context, listen: false);
  String string = titleDialog == "Join to Channel" ? "" : currentWorkspace["name"];
  String title = titleDialog;
  final token = Provider.of<Auth>(context, listen: false).token;
  final currentUser = Provider.of<User>(context, listen: false).currentUser;
  onChangeWorkspaceName(value) async {
    if (value != "") {
      Map workspace = new Map.from(currentWorkspace);
      workspace["name"] = value;
      await Provider.of<Workspaces>(context, listen: false).changeWorkspaceInfo(auth.token, currentWorkspace["id"], workspace);
      Navigator.of(context, rootNavigator: true).pop("Discard");
    }
  }
  joinToChannel(value) async {
    if(value != "") {
      try {
        await Provider.of<Channels>(context, listen: false).joinChannelByCode(token, value, currentUser);
        // Navigator.of(context, rootNavigator: true).pop("Discard");
      } catch (e) {
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return CustomDialogNew(
              title: "Err!!", 
              content: "Syntax invite code wrong",
              confirmText: "Try again",
            );
          }
        );
        print("nhập sai syntax $e");
      }
       
    }
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: title,
        textDisplay: string,
        onSaveString: titleDialog == "Join to Channel" ? joinToChannel : onChangeWorkspaceName,);
    }
  );
}

showCustomDialogJoinToChannel(context, titleDialog) {
  String string = "";
  String title = titleDialog;
  final token = Provider.of<Auth>(context, listen: false).token;
  final currentUser = Provider.of<User>(context, listen: false).currentUser;
  joinToChannel(value) async {
    if(value != "") {
      try {
        await Provider.of<Channels>(context, listen: false).joinChannelByCode(token, value, currentUser);
        // Navigator.of(context, rootNavigator: true).pop("Discard");
      } catch (e) {
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return CustomDialogNew(
              title: "Err!!", 
              content: "Syntax invite code wrong",
              confirmText: "Try again",
            );
          }
        );
        print("nhập sai syntax $e");
      }
       
    }
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: title,
        textDisplay: string,
        onSaveString: joinToChannel
      );
    }
  );
}