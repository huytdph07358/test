import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/models/models.dart';

import '../generated/l10n.dart';

class BottomSheetWorkspace extends StatefulWidget {
  BottomSheetWorkspace({key, this.action}) : super(key: key);

  final action;

  @override
  _BottomSheetWorkspaceState createState() => _BottomSheetWorkspaceState();
}

class _BottomSheetWorkspaceState extends State<BottomSheetWorkspace> {
  String serverName = "";
  List images = [];
  bool disableSendButton = true;
  String contentUrl = "";
  bool isLoading = false;
  var textCode;
  var errorMessage = "";

  void loadAssets() async {
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context, maxAssets: 1);
    List results = await Utils.handleFileData(resultList);
    results = results.where((e) => e.isNotEmpty).toList();
    
    if (!mounted) return;
    if (results.length > 0) {
      setState(() {
        isLoading = true;
      });
      final token = Provider.of<Auth>(context, listen: false).token;
      var uploadFile = await Provider.of<Work>(context, listen: false).getUploadData(results[0]);
      var response = await Provider.of<Work>(context, listen: false).uploadImage(token, 0, uploadFile, "image", (v){});
      if (response['success']) {
        setState(() {
          isLoading = false;
        });
        if (response['mime_type'] == 'image') {
            contentUrl = response['content_url'];
        } else {
          showErrorLoadImage('Can\'t load file '+ response['mime_type']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorLoadImage('Can\'t load image.');
      }
    }
  }

  joinWorkspaceByCode() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    if(Utils.checkedTypeEmpty(textCode)) {
      try {
        var responseMessage = await Provider.of<Workspaces>(context, listen: false).joinWorkByCode(token, textCode, currentUser);
          if(responseMessage == true){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialogNew(
                  title: "Success", 
                  content: "Join workspace was successful"
                );
              }
            );
          }
          else{
            if(responseMessage["message"] == "Không còn workspace trong hệ thống"){
              setState(() {
                errorMessage = "Workspace does not exist";
              });
            }
            else if(responseMessage["message"] == "Email đã có trong workspace") {
              setState(() {
                errorMessage = "Email already exists in workspace";
              });
            }
          }
      } catch (e) {
        print(e);
        setState(() {
          errorMessage = "Syntax code was wrong, try again !";
        });
      }
    }
    else{
      setState(() {
        errorMessage = "Input cannot be empty";
      });
    }
  }

  Future<void> showErrorLoadImage(String errorData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogNew(
          title: "ERR!!", 
          content: "$errorData"
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final token = auth.token;
    double deviceHeight = MediaQuery.of(context).size.height;
    final isDark = auth.theme == ThemeType.DARK;

    createWorkspace(serverName, urlAvatar) async {
      await Provider.of<Workspaces>(context, listen: false).createWorkspace(context, token, serverName, urlAvatar);
      // Navigator.pushNamed(context, 'dashboard-screen');
      Navigator.pop(context);
    }

    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff3D3D3D) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0)
          )
        ),
        height: deviceHeight*0.82,
        child: widget.action == "Join workspace"
        //Bottom sheet Join Workspace
        ? Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)))
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(S.current.joinWorkspace, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), height: 1.57))
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).descJoinWs, 
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).inviteWsCode,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)
                      ),
                    )
                  ]
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoTextField(
                  autofocus: false,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  padding: EdgeInsets.all(10),
                  clearButtonMode: OverlayVisibilityMode.always,
                  onChanged: (value){
                    textCode = value;
                  },
                ),
              ),
              errorMessage == "" 
                ? Container(height: 19)
                : Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          errorMessage,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.red,
                            fontStyle: FontStyle.italic
                          ),
                        )
                      ]
                    ),
                  ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Text(
                    S.of(context).example.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     SizedBox(width: 20),
              //     Text(
              //       "Invites should look like",
              //       style: TextStyle(
              //         fontWeight: FontWeight.w400,
              //         fontSize: 12,
              //         color: Colors.grey
              //       ),
              //     ),
              //     SizedBox(width: 4),
              //     Text("https://pancakechat.vn/TK76iu,", style: TextStyle(fontSize: 12))
              //   ],
              // ),
              // Container(
              //   margin: EdgeInsets.only(top: 2, left: 20),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Container(
              //         margin: EdgeInsets.only(right: 4),
              //         child: Text(
              //           "/TK76iu,",
              //           style: TextStyle(fontSize: 12)
              //         )
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(right: 4),
              //         child: Text("or",
              //           style: TextStyle(
              //             color: Colors.grey, fontSize: 12
              //           )
              //         )
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(right: 4),
              //         child: Text(
              //           "https://pancakechat.vn/cool-people.",
              //           style: TextStyle(fontSize: 12)
              //         )
              //       ),
              //     ]
              //   ),
              // ),
              Container(
                margin: EdgeInsets.only(top: 6, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "${S.of(context).inviteCodeWs}: ",
                            style: TextStyle(
                              color: Colors.grey, fontSize: 12
                            )
                          )
                        ),
                        Container(
                          child: Text(
                            "AAAA-56-123, AAAA-56-123,",
                            style: TextStyle(fontSize: 12)
                          )
                        )
                      ]
                    ),
                    SizedBox(height: 3),
                    Container(
                      child: Text(
                        "AAAA-56-123",
                        style: TextStyle(fontSize: 12)
                      )
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 32),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 36,
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Utils.getPrimaryColor())
                  ),
                  onPressed: () {
                    joinWorkspaceByCode();
                  },
                  child: Text(
                    S.current.joinWorkspace,
                    style: TextStyle(color: Color(0xFFffffff))
                  )
                ),
              )
            ],
          ),
        ) 

        //Bottom sheet create Workspace
        : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)))
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(S.current.createAWorkspace, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), height: 1.57))
            ),
            Container(
              margin: EdgeInsets.only(top: 24),
              child: InkWell(
                onTap: loadAssets,
                focusColor: Colors.transparent,
                child: contentUrl.isEmpty ? !isLoading ? 
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff2E2E2E) : Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: CircularBorder(
                          width: 1.2, size: 100,
                          color: Color(0xffA6A6A6),
                          icon: Icon(PhosphorIcons.camera, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), size: 26),
                          title: Text(S.current.upload.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.7, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(0xff1890FF),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Icon(PhosphorIcons.plus, size: 19, color: Colors.white)
                        ),
                        right: 0)
                    ]
                  ) : Padding(padding: const EdgeInsets.symmetric(vertical: 42), child: CircularProgressIndicator()
                ) : CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(contentUrl),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 4),
              alignment: Alignment.centerLeft,
              child: Text(S.current.workspaceName, style: TextStyle(height: 1.5, fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
            ),
            Container(
              height: 40,
              margin: EdgeInsets.only(top: 4, left: 16, right: 16),
              child: CupertinoTextField(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isDark ? Color(0xff2E2E2E) : Color(0xffFAFAFA),
                  border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                ),
                placeholder: S.current.addName,
                placeholderStyle: TextStyle(color: Color(0xffA6A6A6), fontFamily: "Roboto", fontSize: 15),
                autofocus: false,
                style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontFamily: "Roboto", fontSize: 15),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                clearButtonMode: OverlayVisibilityMode.editing,
                onChanged: (value) {
                  this.setState(() {
                    serverName = value;
                  });
                }
              ),
            ), Container(
              margin: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text(S.of(context).noteCreateWs, style: TextStyle(fontSize: 13, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), height: 1.67)),
                  Text(S.of(context).communityGuide, style: TextStyle(fontSize: 13, color: Color(0xff1890FF), fontWeight: FontWeight.w700, height: 1.67))
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 24, left: 16, right: 16),
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  if (serverName != "") {
                    createWorkspace(serverName, contentUrl); 
                  }
                },
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color : Color(0xff1890FF),
                    borderRadius: BorderRadius.circular(2),                                         
                  ),
                  child: Text(S.current.createWorkspace, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CircularBorder extends StatelessWidget {
  final Color color;
  final double size;
  final double width;
  final icon;
  final title;
  const CircularBorder({key, this.color = Colors.blue, this.size = 70, this.width = 7.0, this.icon, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon,title],
          ),
          Container(
            child: CustomPaint(
              size: Size(size, size),
              foregroundPainter: new MyPainter(
                completeColor: color,
                width: width
              ),
              painter: new MyPainter(
                completeColor: color,
                width: width
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor =  Colors.transparent;
  final completeColor;
  final width;

  MyPainter({
    this.completeColor, this.width
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    var percent = (size.width *0.000125) / 2;

    double arcAngle = 2 * pi * percent;
    for (var i = 0; i < 50; i++) {
      var init = (-pi /1.5)*(i/16);
      canvas.drawArc(new Rect.fromCircle(center: center, radius: radius),init, arcAngle, false, complete);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}