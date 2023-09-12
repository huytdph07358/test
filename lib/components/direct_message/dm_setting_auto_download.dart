import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class SettingAutoDownloadDm extends StatefulWidget {
  const SettingAutoDownloadDm({Key? key}) : super(key: key);

  @override
  State<SettingAutoDownloadDm> createState() => _SettingAutoDownloadDmState();

  static Widget fontSettingAutoDownload(BuildContext context){
    final isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context){
            return SettingAutoDownloadDm();
          }
        ));
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
                  Icon(PhosphorIcons.downloadSimple, size: 18),
                  SizedBox(width: 8),
                  Text(S.current.StorageDirectDessage, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
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
        ),
      ),
    );
  }
}

class _SettingAutoDownloadDmState extends State<SettingAutoDownloadDm> {

  showSettings(String type){
    return showDialog(
      context: context,
      builder: (dailogContext){
        Map settingAutoDownloadDM = Provider.of<User>(dailogContext, listen: true).settingAutoDownloadDM;
        return AlertDialog(
          content: Wrap(
            children: [
              Text("${S.current.whenUsing} ${type == S.current.mobile ? S.current.mobileData : type}"),
              Column(
                children: ["image", "video", "other"].map<Widget>((item) {
                  return Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: settingAutoDownloadDM[type][item] ?? false,
                        onChanged: (bool? value) {
                          Provider.of<User>(context, listen: false).callApiSettingAutoDownloadDM({
                            type: {
                              ...settingAutoDownloadDM[type],
                              item: value
                            }
                          },  Provider.of<Auth>(dailogContext, listen: false).token);
                        },
                      ),
                      Text(item[0].toUpperCase() + item.substring(1, item.length))
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    Map settingAutoDownloadDM = Provider.of<User>(context, listen: true).settingAutoDownloadDM;

    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        child: Container(
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
                    border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB))) ,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                        ),
                      ),
                      Text(S.current.StorageDirectDessage, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17),),
                      Text("             ")
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(S.current.MediaAutoDownload, style: TextStyle(color: Color(0xFF8c8c8c), fontWeight: FontWeight.bold, fontSize: 14,),)),

              Column(
                children: ["wifi", "mobile"].map<Widget>((item) {
                  String joined = ["image", "video", "other"].where((element) => settingAutoDownloadDM[item][element]).join(", ");
                  joined = joined == "" ? "No selected" : joined;
                  joined = joined[0].toUpperCase() + joined.substring(1, joined.length);
                  return InkWell(
                    onTap: () {
                      showSettings(item);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 32, top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Text("${S.current.whenUsing} $item")),
                          Text(joined, style: TextStyle(color: Color(0xFF8c8c8c), fontSize: 12,)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );   
  }
}