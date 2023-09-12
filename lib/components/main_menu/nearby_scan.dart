import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/profile/user_profile.dart';
import 'package:workcake/models/models.dart';

class NearbyScan extends StatefulWidget{
    @override
  _NearbyScan createState() => _NearbyScan();
}

class _NearbyScan extends State<NearbyScan>{
  List dataNearbyScan = [];
  
  @override
  void initState() {
    super.initState();
    var auth = Provider.of<Auth>(context, listen: false);
    auth.channel.on("data_nearby_scan", (data, _r, _j){
      if (this.mounted){
        var result  = [];
        for(var i = 0; i < data["data"].length; i++){
          if (dataNearbyScan.indexWhere((element) => element["user_id"] == data["data"][i]["user_id"]) == -1){
            var size  =  MediaQuery.of(context).size.width;
            var sizeShow = 50;
            var colRow = (size / sizeShow).round();
            if (colRow % 2 == 0){
              colRow = colRow +1;
              sizeShow = (size / colRow).round();
            }
            var total = colRow * colRow;
            var index = Random().nextInt(total);
            var listNotIndex = [];
            var xyCenter = ((colRow -1 ) / 2).round();
            var indexCenter = colRow * xyCenter + xyCenter;
            listNotIndex = [
              indexCenter, indexCenter - 1, indexCenter + 1, indexCenter - colRow, indexCenter + colRow,
              indexCenter - 1 + colRow, indexCenter - 1 -  colRow,
              indexCenter + 1 + colRow, indexCenter + 1 -  colRow,
            ];
            while(
              ((dataNearbyScan.indexWhere((element) => element["index"] == index) != -1) && dataNearbyScan.length + 9 < total)
              || (listNotIndex.indexWhere((element) => element == index) != -1)
            ){
              index  = Random().nextInt(total);
            }
            result += [Utils.mergeMaps([data["data"][i], {"isRequest": false, "pX": ((index % colRow ) * sizeShow ).toDouble(), "pY": (((index / colRow).round()) * sizeShow ).toDouble()}])];
          }
        }
        setState(() {
          dataNearbyScan += result;
        });
      }
    });

    Timer.run(()async{
      try {
        Location location = new Location();
        bool _serviceEnabled;
        PermissionStatus _permissionGranted;
        LocationData _locationData;
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {
            return;
          }
        }
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted != PermissionStatus.granted) {
            return; 
          }
        }

        var auth = Provider.of<Auth>(context, listen: false);
        while(true && this.mounted){
          _locationData = await location.getLocation();
          auth.channel.push(event: "set_location", payload: {
            "x": _locationData.latitude,
            "y": _locationData.longitude
          });
          await Future.delayed(Duration(seconds: 9));
        }
      } on Exception catch (e) {
        print("Err $e");
      }
    });
  }

  renderStatus(user){
    // has friend
    if (user["is_confirm"] && user["is_request"]) return "Friend";
    // is Request
    if (user["is_request"] && !user["is_confirm"]) return "Request";
    // is confirm
    if (!user["is_request"] && user["is_confirm"]) return "Response";
    return "Add";
  }

  @override
  Widget build(BuildContext context){
    // lay 5 nguioi dau danh sanh de hien thi tren giao dien con laij hien thio list
    var width  =  MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var size = width > height ? height : width;
    var auth = Provider.of<Auth>(context, listen: false);
    var sizeImage  = 24.0;
    final isDark = auth.theme == ThemeType.DARK;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: size, width: size,
                child: Stack(
                  children:[
                    Container(
                      height: size, width: size,
                      child: Lottie.network("https://assets8.lottiefiles.com/temp/lf20_PeIV5A.json")
                    ),
                    Stack(
                      children: dataNearbyScan.map((e){
                        return Positioned(
                          top: e["user_id"] == auth.userId ? size / 2 - 30 :  e["pY"] ,
                          left: e["user_id"] == auth.userId ? size / 2 - 32  :  e["pX"],
                          child: GestureDetector(
                            onTap: e["user_id"] == auth.userId ? null : () => showRequestModal(context, e),
                            child: Container(
                              width: sizeImage + 42 , height: sizeImage + 32,
                              child: Column(
                                children: [
                                  Container(
                                    height: 24, width: 24,
                                    child: CachedImage(e["avatar_url"], radius: 20, height: e["user_id"] == auth.userId ? 32 : 24, width: e["user_id"] == auth.userId ? 32 : 24, ),
                                  ),
                                  SizedBox(height: 8,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark && e["user_id"] != auth.userId ? Color(0xff2E2E2E) : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: isDark || e["user_id"] == auth.userId  ? null : Border.all(color: Color(0xffC9C9C9))
                                    ),
                                    child: Text(Utils.getString(e["name"], 12), style: TextStyle(color: e["user_id"] == auth.userId || !isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED), fontSize: e["user_id"] == auth.userId ? 12 : 11), overflow: TextOverflow.ellipsis,)
                                  ),
                                ],
                              ),
                            )
                          )
                        );
                      }).toList(),
                    )

                  ] 
                ),
              ),
              Column(
                children: dataNearbyScan.map((e){
                  if (e["user_id"] == auth.userId) return Container();
                  String status  =  renderStatus(e);
                  return GestureDetector(
                    onTap: () => showRequestModal(context, e),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                      margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isDark ? Color(0xff2e2e2e) :  Color(0xffF3F3F3)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 24, width: 24, margin: EdgeInsets.only(right: 8),
                                child: CachedImage(e["avatar_url"], radius: 12, width: 24, height: 24,) ,
                              ),
                              Text(e["name"], style: TextStyle(color: isDark ? Color(0xffededed) : Color(0xff3D3D3D), fontSize: 15),),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async{
                              if (status  == "Add" || status  == "Response" )  {
                                setState(() {
                                  var index = dataNearbyScan.indexWhere((element) => element["user_id"] == e["user_id"]);
                                  dataNearbyScan[index]["isRequest"] = true;
                                });
                                await Provider.of<User>(context, listen: false).addFriendRequest(e["user_id"], auth.token);
                              }
                            },
                            child: e["isRequest"] ? Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffDBDBDB),
                                borderRadius: BorderRadius.circular(2)
                              ),
                              child: Text("Sent request", style: TextStyle(fontSize: 13, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)),),

                            ) : status == "Friend" ? Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF))
                              ),
                              child: Text("Friend", style: TextStyle(fontSize: 13, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF)),),
                            ) : Container(
                              decoration: BoxDecoration(
                                color: Color(0xff1890FF),
                                borderRadius: BorderRadius.circular(2)
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Text(status, style:  TextStyle(color: Color(0xFFffffff), fontSize: 13)
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                  );

                }).toList(),
              )
            ]
          ),
        ),
      )
    );
  }
}

showRequestModal(context, user) async{
  final auth = Provider.of<Auth>(context, listen: false);
  await Provider.of<User>(context, listen: false).getUser(auth.token, user["user_id"]);
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
        ),
        child: SingleChildScrollView(
          child: UserProfile(),
        ),
      );
    },

  );
}


