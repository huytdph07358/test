import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/main_menu/task_download.dart';
import 'package:workcake/models/models.dart';

class File extends StatefulWidget{

  @override
  _File  createState() => _File();
}

class _File extends State<File>{

  
  List fileItems = [];

  @override
  void initState(){
    super.initState();
    Timer.run(()async{
    var appDocDirectory;
    
    if (Platform.isAndroid) appDocDirectory = await getExternalStorageDirectory();
    if (Platform.isIOS) appDocDirectory = await getApplicationDocumentsDirectory();
    var path  = appDocDirectory.path;
      fileItems =await processFiles(Directory(path).listSync());   
      setState(() {
      });
    });
  }
  

   processFiles(uriFiles) async{
    List result  = [];
    for(var i = 0; i < uriFiles.length; i++){
      var name  =  uriFiles[i].path.split("/").last;
      var type =  name.split(".").last;
      if (type  == null || type == "") continue;
      if (type  == "png" || type == "jpg" || type == "jpeg") type = "image";
      // check the path has existed
      var existed  =  fileItems.indexWhere((element) => element["path"] == uriFiles[i].path);
      if (existed != -1) continue;
      // image = "png, jpg, jpeg"
       result  += [{
        "name": name,
        "mime_type": type,
        "path": uriFiles[i].path,
      }];
    }
    return result;
  }

  @override
  Widget build(BuildContext context){
    final isMobile  =  Platform.isAndroid || Platform.isIOS || false;
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    if (Platform.isAndroid || Platform.isIOS)
      return Scaffold(
        appBar: AppBar(
          title: Text(""),
          leading: Container(
            child: IconButton(
              onPressed:  () {Navigator.pop(context);},
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
        body: Container(
        // width: 300,
        padding: EdgeInsets.only(right: 16, left: 16),
        height: MediaQuery.of(context).size.height,

        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:  Text("File downloading", style: TextStyle(fontSize: 20,)),
                )
              ),
              TaskDownload(showDownload:  true,),

              Container(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:  Text("File downloaded", style: TextStyle(fontSize: 20,)),
                )
              ),
              Column(
                children:fileItems.map((e){
                  if (e["mime_type"] == "hive" || e["mime_type"] == "lock") return Container();
                  return  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding:  EdgeInsets.all(8),
                      decoration: isMobile ? null : BoxDecoration(
                        color: Color(0xFF8c8c8c),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      width: isMobile? null : 260,
                      child:  Text(e["name"], style: TextStyle(),
                      )  
                    ),
                  );
                }).toList(),
              )
              
            ],
          ),
        )
      ),
    );
    return Container(
      // width: 300,
      padding: EdgeInsets.only(right: 16, left: 16),
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color:  isDark ? Color(0xff323F4B) : Color(0xffffffff)
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 30,),
            Container(
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child:  Text("File Manager", style: TextStyle(fontSize: 20,)),
              )
            ),
             Container(
               margin: EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerLeft,
                  child: Text("File downloading", style: TextStyle(),
                ),
              ),
            ),
            TaskDownload(showDownload:  true,),

            Container(
              margin: EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerLeft,
                  child: Text("File downloaded", style: TextStyle(),
                ),
              ),
            ),
            Column(
              children:fileItems.map((e){
                return GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding:  EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF8c8c8c),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    width: 260,
                    child:  Text(e["name"], style: TextStyle(color: Color(0xFFffffff)),
                  )),
                );
              }).toList(),
            )
            
          ],
        ),
      )
    );
  }
}




