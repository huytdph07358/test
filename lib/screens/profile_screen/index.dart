import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/profile/saved_message.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/logs/logs.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/screens/profile_screen/setting.dart';
import '../../components/channel/change_language.dart';
import '../../components/isar/message_conversation/service.dart';
import '../../components/main_menu/qr_code_user.dart';
import '../friends_screen/index.dart';
import 'change_password.dart';
import 'edit_profile.dart';
import 'notification_sound.dart';


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool androidAutoDownload = false;
  PanelController panelController = PanelController();
  File? image;
  var imgName;
  void initState() {
    super.initState();
    Timer.run(() async {
      var box = Hive.lazyBox('pairKey');
      androidAutoDownload = (await box.get("android_auto_download")) ?? false;
      final auth = Provider.of<Auth>(context, listen: false);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    });
  }

languages(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          width: 240,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: ChangeLanguage()
        ),
      );
    }
  );
}
_updateAvatar() async {
  try {
    var res = await uploadAvatar(context);
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final auth = Provider.of<Auth>(context, listen: false);
    if(res != null) {
      if(res["success"] == true){
        if (res["content_url"] != currentUser["avatar_url"]) {
          currentUser["avatar_url"] = res["content_url"];
        }
        var response = await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, currentUser);
        if (response["success"] && mounted) {
          await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
          Provider.of<Auth>(context, listen: false).locale = currentUser['locale'];
         }
        } 
      }
    } catch (e, t) {
    print(t);
  }
}

uploadAvatar(context) async {
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false ).currentWorkspace;
  final auth = Provider.of<Auth>(context, listen: false);
  if (image != null) {
    final workspaceId = currentWorkspace["id"];
    final uploadFile = {
      "filename": imgName,
      "path": base64Encode(await  image!.readAsBytes()),
      "height": 120,
      "width": 120,
    };
    var res = await Provider.of<User>(context, listen: false).uploadAvatar(auth.token, workspaceId, uploadFile, "image");
    return res;
  }
}

Future pickImage() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(image == null) return;

    final file = await ImageCropper().cropImage(
      sourcePath: image.path, 
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: "Edit"
      )
    );
    if(file == null) return;
    
    setState(() {
      this.image = file;
      imgName = image.name;
    });
   await _updateAvatar();

  } on PlatformException catch (e) {
    print('Failed to pick image: $e');
  }
}
  

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(top: 5, bottom: 30),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 16, top: 16),
                              child: Center(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context, MaterialPageRoute(builder: (context) =>  PersonalInformation())
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        margin: EdgeInsets.symmetric(horizontal: 11, vertical: 0),
                                        padding: EdgeInsets.symmetric(vertical: 24,horizontal: 18),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // uploadAvatar();
                                                    pickImage();
                                                  },
                                                  child: Stack(
                                                    children: <Widget>[
                                                      image != null 
                                                        ? ClipOval(
                                                          child: Image.file(image!, width: 90 , height: 90,fit: BoxFit.cover,)
                                                        )
                                                        : CachedAvatar(currentUser["avatar_url"], name: currentUser["full_name"], width: 90, height: 90, fontSize: 30),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: Color(0xff5E5E5E),
                                                            borderRadius: BorderRadius.circular(18),
                                                          ),
                                                          width: 32,
                                                          height: 32,
                                                          child: Icon(PhosphorIcons.camera, color: isDark ? Color(0xffF9F9F9).withOpacity(0.94) : Color(0xffFFFFFF), size: 22,)
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 20,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      currentUser["full_name"] ?? "",
                                                      style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, color: isDark ? Color(0xffEDEDED) : Color(0xff000000))
                                                    ),
                                                    SizedBox(height: 10,),
                                                    InkWell(
                                                      onTap: () {
                                                        Clipboard.setData(new ClipboardData(text: "${currentUser["username"]}#${currentUser["custom_id"]}"));
                                                        Fluttertoast.showToast(
                                                          msg: "copied",
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.TOP,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.grey,
                                                          textColor: Colors.white,
                                                          fontSize: 16.0
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "${Utils.checkedTypeEmpty(currentUser["username"]) ? currentUser["username"] : currentUser["full_name"]}#${currentUser["custom_id"]}",
                                                            style: TextStyle(fontSize: 16, color: isDark ? Color(0xffC9C9C9) : Color(0xff000000).withOpacity(0.65)),
                                                          ),
                                                          SizedBox(width: 4),
                                                          Icon(PhosphorIcons.copySimple, size: 16, color: Color(0xff1890FF) ,), 
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Platform.isIOS && DateTime.now().microsecondsSinceEpoch < 1649140463791000 ? Container() : InkWell(
                                    splashFactory: InkRipple.splashFactory,
                                    onTap: () {
                                      showAddFriendsView(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(PhosphorIcons.userPlus, size: 18,),
                                              SizedBox(width: 8),
                                              Text(S.current.addFriend, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                            ],
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                    height: 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context, MaterialPageRoute(builder: (context) =>  Friends())
                                      );
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIcons.users, size: 18),
                                                SizedBox(width: 10),
                                                Text(S.current.friends, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16,),

                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                                        return SavedMessages();
                                      }));
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(CupertinoIcons.bookmark, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 18),
                                              SizedBox(width: 8),
                                              Text(S.current.savedMessages, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                            ],
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                        ],
                                      )
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                    height: 1,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Map user = {
                                        "user_id": "9e702ec5-7a22-42ed-a289-3c8c55692523",
                                        "full_name": "Pancake Chat Support",
                                        "is_online": true
                                      };
                                      final currentUser = Provider.of<User>(context, listen: false).currentUser;
                                      var convId = user["conversation_id"];
                                      if (convId == null){
                                        convId = MessageConversationServices.shaString([currentUser["id"], user["user_id"] ?? user["id"]]);
                                      }

                                      bool hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(Provider.of<Auth>(context, listen: false).token, convId);
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
                                          "", false, 0, {}, false, 0, {}, user["full_name"] ?? user["name"], null, DateTime.now().toString()
                                        );
                                      }
                                      Provider.of<DirectMessage>(context, listen: false).setSelectedDM(dm, "");
                                      Provider.of<Workspaces>(context, listen: false).setTab(0);
                                      if (hasConv) {
                                        Provider.of<DirectMessage>(context, listen: false).resetOneConversation(dm.id);
                                        await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(dm.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
                                        Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(dm.id, true, auth.token, auth.userId);                                  
                                      }
                                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                                        return Message(
                                          dataDirectMessage: dm,
                                          id: dm.id,
                                          name: "",
                                          avatarUrl: "",
                                          isNavigator: true,
                                          panelController: panelController
                                        );
                                      }));

                                    },
                                    child: Container(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(PhosphorIcons.question, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                              SizedBox(width: 8),
                                              Text(S.current.contactSupport, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                            ],
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                        ],
                                      )
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                    height: 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => NotificationAndSouund())
                                      );
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIcons.bellSimple, size: 18),
                                                SizedBox(width: 8),
                                                Text(S.current.notificationSound, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16,),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Container(
                                    height: 48,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: InkWell(
                                      onTap: () async {
                                        if (!await Utils.localAuth()) return;
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQr()));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(CupertinoIcons.qrcode_viewfinder, size: 18, color: isDark ? Colors.white : Color(0xff5E5E5E),),
                                              SizedBox(width: 8),
                                              Text(S.current.loginWithQRCode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                            ],
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                    height: 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Setting())
                                      );
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIcons.gearSix, size: 18),
                                                SizedBox(width: 8),
                                                Text(S.current.settings, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16,),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                onTap: () async {
                                  Provider.of<Channels>(context, listen: false).deleteDevicesToken(auth.token);
                                  Provider.of<Channels>(context, listen: false).deleteApnsToken(auth.token);
                                  Provider.of<Auth>(context, listen: false).logout();
                                  await Provider.of<Workspaces>(context, listen: false).resetData();
                                  await Provider.of<DirectMessage>(context, listen: false).resetData();
                                  await Provider.of<Channels>(context, listen: false).resetData();
                                },
                                child: Container(
                                  height: 48,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Icon(PhosphorIcons.signOut, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                            SizedBox(width: 8),
                                            Text(S.current.logout, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                            ),
                            // !(auth.connectionState["connectionState"] ?? false) ? Container(
                            //   margin: EdgeInsets.only(top: 30),
                            //   child: Text(jsonEncode(auth.connectionState)),
                            // ): Container()
                          ],
                        ),
                      )
                    ),
                  ),
                ),
              ],
            ),
          )
          // : SplashScreen(),
        ),
      ),
    );
  }
}
class PersonalInformation extends StatefulWidget {
  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  bool androidAutoDownload = false;
  PanelController panelController = PanelController();
  void initState() {
    super.initState();
    Timer.run(() async {
      var box = Hive.lazyBox('pairKey');
      androidAutoDownload = (await box.get("android_auto_download")) ?? false;
      final auth = Provider.of<Auth>(context, listen: false);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    });
  }
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    String dateString = Utils.checkedTypeEmpty(currentUser["date_of_birth"])
      ? DateFormatter().renderTime(DateTime.parse(currentUser["date_of_birth"]), type: "dd/MM/yyyy")
      : S.current.notSet;

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Container(
            color: isDark ? Color(0xff2E2E2E) : Colors.white,
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
                      border: Border(
                        bottom: BorderSide(width: 1, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED))
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.arrow_back)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            S.current.profile,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, bottom: 10),
                  child: Text(S.current.name, style: TextStyle(fontSize: 15, color: Color(0xff949494)),),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                            context, MaterialPageRoute(builder: (context) => EditProfile(editName: true,))
                          );
                        },
                        child: Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.userSquare, size: 18),
                                    SizedBox(width: 8),
                                    Text(S.current.displayName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Text(currentUser["full_name"], style: TextStyle(fontSize: 16, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)))
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                        height: 1,
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                            context, MaterialPageRoute(builder: (context) => EditProfile(editName: true,))
                          );
                        },
                        child: Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.user, size: 18),
                                    SizedBox(width: 8),
                                    Text(S.current.userName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Text("${currentUser["username"]}#${currentUser["custom_id"]}", style: TextStyle(fontSize: 16, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)))
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, bottom: 10),
                  child: Text(S.current.basicInfo, style: TextStyle(fontSize: 15, color: Color(0xff949494)),),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => EditProfile(editBasic: true))
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            print("noti_string_on_create\n +++++++++++++++++++++++++++++ \n${await Work.platform.invokeMethod("noti_string_on_create")} \n +++++++++++++++++++++++++++++\n\n\n");
                            print("initialLink\n+++++++++++++++++++++++++++++ \n${await Work.platform.invokeMethod("initialLink")}  \n ++++++++++++++++++++++++++++");
                            Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Logs())
                            );
                          },
                          child: Container(
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.genderIntersex, size: 18),
                                      SizedBox(width: 8),
                                      Text(S.current.gender, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Text('${currentUser["gender"] != null ? currentUser["gender"] : S.current.notSet}', style: TextStyle(fontSize: 16, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)))
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                          height: 1,
                        ),
                        GestureDetector(
                          onLongPress: (){
                            Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Logs(isNoti: true))
                            );
                          },
                          child: Container(
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.calendar, size: 18),
                                      SizedBox(width: 8),
                                      Text(S.current.dateOfBirth, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Text(dateString, style: TextStyle(fontSize: 16, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)))
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, bottom: 10),
                  child: Text(S.current.contactInfo, style: TextStyle(fontSize: 15, color: Color(0xff949494)),),
                ),
                InkWell(
                  onTap: () async {
                    currentUser["is_verified_email"] == true ? Container() : Navigator.push(
                      context, MaterialPageRoute(builder: (context) => EditProfile())
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.envelopeSimple, size: 18),
                                    SizedBox(width: 8),
                                    Text("Mail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                    SizedBox(width: 8),
                                    if(currentUser["is_verified_email"] == true) Icon(PhosphorIcons.circleWavyCheckFill, size: 16, color: Color(0xff27AE60))
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(new ClipboardData(text: currentUser["email"] ?? ""));
                                  Fluttertoast.showToast(
                                    msg: "copied",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                  );
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Utils.checkedTypeEmpty(currentUser["email"]) ? Icon(PhosphorIcons.copySimple, size: 16) : SizedBox(),
                                      SizedBox(width: 4),
                                      Container(
                                        child: Text(currentUser["email"] ?? S.current.notSet, 
                                          style: TextStyle(
                                          fontSize: 16, 
                                          color: Utils.checkedTypeEmpty(currentUser["email"]) ? isDark ? Color(0xff828282) : Color(0xffA6A6A6) : isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)), 
                                          overflow: TextOverflow.ellipsis, 
                                          textAlign: TextAlign.left),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                          height: 1,
                        ),
                        InkWell(
                          onTap: () async {
                           currentUser["is_verified_phone_number"] == true ? Container() : Navigator.push(
                              context, MaterialPageRoute(builder: (context) => EditProfile())
                            );
                          },
                          child: Container(
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.phoneCall, size: 18),
                                      SizedBox(width: 8),
                                      Text(S.current.phoneNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                      SizedBox(width: 8),
                                      if(currentUser["is_verified_phone_number"] == true) Icon(PhosphorIcons.circleWavyCheckFill, size: 16, color: Color(0xff27AE60))
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: currentUser["phone_number"] != "" ? () {
                                    Clipboard.setData(new ClipboardData(text: currentUser["phone_number"]));
                                    Fluttertoast.showToast(
                                      msg: "copied",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                    );
                                  } : null,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        if(currentUser["phone_number"] != "") Icon(PhosphorIcons.copySimple, size: 16),
                                        SizedBox(width: 4),
                                        Text('${currentUser["phone_number"] != "" ? currentUser["phone_number"] : S.current.notSet}', 
                                          style: TextStyle(
                                            fontSize: 16, 
                                            color: currentUser["phone_number"] != "" ? isDark ? Color(0xff828282) : Color(0xffA6A6A6) : isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChangePassword())
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                    color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.key, size: 18),
                              SizedBox(width: 8),
                              Text(S.current.changePassword, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}