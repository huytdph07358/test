import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Windows extends ChangeNotifier{
  Size _deviceInfo = new Size(0, 0);
  Size _resSidebarSize = new Size(230, 230);

  Size get deviceInfo => _deviceInfo;
  Size get resSidebarSize => _resSidebarSize;
  set deviceInfo(Size size){
    _deviceInfo = size;
    notifyListeners();
  }
  set resSidebarSize(Size size){
    _resSidebarSize = size;
    notifyListeners();
  }

  saveResSidebarToHive()async{
     var box = await Hive.openBox("windows");
     box.put("resWidth", _resSidebarSize.width);
     notifyListeners();
  }
  loadResSidebarToHive() async{
    var box = await Hive.openBox("windows");
    var _width = box.get("resWidth");
    _resSidebarSize = Size.fromWidth(_width ?? 230);
  }
}