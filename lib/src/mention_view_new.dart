import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/src/attribute.dart';

import '../models/models.dart';

class FlutterMentions extends StatefulWidget {
  FlutterMentions({
    required this.mentions,
    required Key key,
    required this.isDark,
    this.suggestionListHeight = 300.0,
    this.onSearchChanged,
    this.leading = const [],
    this.trailing = const [],
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autofocus = false,
    this.expands = false,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.none,
    this.onChanged,
    this.enabled,
    this.cursorColor,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.scrollPhysics,
    this.scrollController,
    this.hideSuggestionList = false,
    this.onSuggestionVisibleChanged,
    this.controller,
    this.id,
    this.islastEdited = false,
    this.isForwardMessage,
    this.initValue
  }) : super(key: key);

  final String? initValue;

  final bool? isForwardMessage;

  final bool islastEdited;

  final TextEditingController? controller;

  final bool isDark;

  final String? id;

  final bool hideSuggestionList;

  final Function(bool)? onSuggestionVisibleChanged;

  final List<Mention> mentions;

  final List<Widget> leading;

  final List<Widget> trailing;

  final double suggestionListHeight;

  final void Function(String trigger, String value)? onSearchChanged;

  final InputDecoration decoration;

  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle? style;

  final StrutStyle? strutStyle;

  final TextAlign textAlign;

  final TextDirection? textDirection;

  final bool autofocus;

  final bool expands;

  final bool readOnly;

  final bool? showCursor;

  final int? maxLength;

  final MaxLengthEnforcement maxLengthEnforcement;

  final ValueChanged<String>? onChanged;

  final bool? enabled;

  final Color? cursorColor;

  final bool enableInteractiveSelection;

  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback? onTap;

  final ScrollPhysics? scrollPhysics;

  final ScrollController? scrollController;

  @override
  FlutterMentionsState createState() => FlutterMentionsState();
}

class FlutterMentionsState extends State<FlutterMentions> {
  GlobalKey<QuillEditorState> key = GlobalKey<QuillEditorState>();
  QuillController controller = QuillController.basic();
  ScrollController scrollController = ScrollController();
  ValueNotifier<bool> showSuggestions = ValueNotifier(false);
  LengthMap? _selectedMention;
  String _pattern = '';
  FocusNode focusNode = FocusNode();
  bool triggerMention = false;
  var _textMarkUp = "";

  EditorState? get editorState => key.currentState?.editableTextKey.currentState;
  Document get document => controller.document;
  TextEditingValue get editingValue => controller.plainTextEditingValue;

  Map dataFiltered = {
    "data": [],
    "str": ""
  };

  String getStringFromParse(List parses){
    return Utils.getStringFromParse(parses);
  }

  String getMarkUpFromParse(List parses){
    return parses.map((e) {
      if (e["type"] == "text") return e["value"];
      var trigger = e["trigger"];
      final _list = widget.mentions.firstWhere((element) => trigger.contains(element.trigger));
      return _list.markupBuilder(_list.trigger, e["value"], e["name"], e["type"]);
    }).toList().join("");
  }

  // tra ve so phan tu giong nhau tu ben trai
  int getLeftIndex(String left, String right){
    int count = -1;
    int leftLength = left.length;
    int rightLength = right.length;
    // uu tien lay chuoi ngan hon
    String sourceToStart = leftLength < rightLength ? left: right;
    // uu tien lay chuoi daI hon
    String target  = leftLength < rightLength ? right: left;

    for(int i = 0; i < sourceToStart.length; i++){
      if (sourceToStart[i] == target[i]) count = i;
      else break;
    }
    return count + 1;
  }

  //  tra ve so phan tu giong nhau ke tu ben phai
  int getRightIndex(String left, String right){
    int leftCount = getLeftIndex(left, right);
    String newLeft = left.replaceRange(0, leftCount, "");
    String newRight = right.replaceRange(0, leftCount, "");
    return getLeftIndex(newLeft.split("").reversed.join(""), newRight.split("").reversed.join(""));
  }

  String leftNewString(List dataParse, int count){
    var index = 0;
    var results = [];
    for (int i = 0; i < dataParse.length; i++ ){
      String strDataParse = dataParse[i]["type"] == "text" ? dataParse[i]["value"] : "${dataParse[i]["trigger"]}${dataParse[i]["name"]}";
      if ((index + (strDataParse.length)) <= count){
        results += [dataParse[i]];
        index = index + (strDataParse.length);
      } else {
        results += [{
          "type": "text",
          "value": strDataParse.substring(0, count - index)
        }];
        break;
      }
    }
    return getMarkUpFromParse(results);
  }

  String rightNewString(List dataParse, int count){
    if (count == 0) return "";
    var results = [];
    var initCount = 0;
    for (var i = dataParse.length -1; i >= 0; i --){
      String strDataParse = dataParse[i]["type"] == "text" ? dataParse[i]["value"] : "${dataParse[i]["trigger"]}${dataParse[i]["name"]}";
      if (initCount == count) break;
      if ((initCount + strDataParse.length) <= count){
        results = [] + [dataParse[i]] + results;
        initCount = initCount + strDataParse.length;
      } else {
        results = [] + [{
          "type": "text",
          "value": strDataParse.substring(strDataParse.length - count + initCount, strDataParse.length)
        }] + results;
        break;
      }
    }
    return getMarkUpFromParse(results);
  }

  checkMentions(String markUpText){
    return Provider.of<Messages>(context, listen: false).checkMentions(markUpText, trim: false);
  }

  int checkIsInOldMention(List dataParse, int count){
    if (count < 0) return -1;
    var offset = 0;
    for(int i =0 ; i < dataParse.length ; i++){
      String strDataParse = dataParse[i]["type"] == "text" ? dataParse[i]["value"] : "${dataParse[i]["trigger"]}${dataParse[i]["name"]}";
      if (offset <= count && count <= (offset + (strDataParse.length)) && dataParse[i]["type"] != "text") return i;
      else offset += strDataParse.length;
    }
    return -1;
  }

  int leftLastStartTrigger(String text, String trigger){
    List rcv = text.split("").toList();
    int indexTrigger = rcv.lastIndexWhere((element) => element == trigger);
    return indexTrigger;
  }

  void addMention(Map<String, dynamic> value, [Mention? list]) {
    final selectedMention = _selectedMention!;
    var t = _selectedMention;
    setState(() {
      _selectedMention = null;
    });

    final _list = widget.mentions.firstWhere((element) => selectedMention.str!.contains(element.trigger));
    if (t == null) return;
    var text = editingValue.text;
    int indexStart = leftLastStartTrigger(text.substring(0, controller.selection.extentOffset), _list.trigger);
    int length =  controller.selection.extentOffset  - indexStart;
    String data =  "${_list.trigger}${value['display']}";
    if (checkIsInMention()){
      controller.replaceText(indexStart, getMentionIn()!.value.toString().length, data + " ", TextSelection.collapsed(offset: controller.selection.extentOffset + data.length));
    } else {
      controller.replaceText(indexStart, length, data + " ", TextSelection.collapsed(offset: controller.selection.extentOffset + data.length));
    }

    controller.formatText(indexStart, data.length, MentionAttribute( _list.markupBuilder(_list.trigger, value["id"], value["display"], value["type"])));
    controller.formatText(indexStart + data.length, 1, Attribute.clone(MentionAttribute( _list.markupBuilder(_list.trigger, value["id"], value["display"], value["type"])), null));
    controller.updateSelection(TextSelection.collapsed(offset: controller.selection.extentOffset + data.length), ChangeSource.LOCAL);

    return;
  }

  checkReMarkUpText(String newString){
    var parse = checkMentions(_textMarkUp);
    if (parse["success"] == false){
      _textMarkUp = newString;
    } else {
      var dataParses  = parse["data"];
      // lay lai text cu
      var oldStr = getStringFromParse(dataParses);
      var newStr = editingValue.text;
      // print("\n oldStr: ,${oldStr},${oldStr.length} \n newStr: ,$newStr,${newStr.length} \n parse: $parse");
      if (oldStr == newStr) {}
      else {
        // tim phan tu dau dien tu trai qua phai khac nhau cua oldStr va newStr
        var leftCount = getLeftIndex(oldStr, newStr);
        var rightCount = getRightIndex(oldStr, newStr);

        // khoi tao lai chuoi trai
        var leftStr = leftNewString(dataParses, leftCount);

        //  khoi tao chuoi phai
        var rightStr = rightNewString(dataParses, rightCount);

        // khoi tao chuoi giua
        var innerStr = newStr.substring(leftCount, newStr.length - rightCount);

        _textMarkUp = leftStr + innerStr + rightStr;
      }
    }
  }

  checkCanShowInElement(text, cursorPos){
    // check @@@
    try {
      String newText = "  " + text + "  ";
      int newCursorPos = (cursorPos ?? 0) + 2;
      var left = newText.substring(newCursorPos - 1, newCursorPos);
      var right = newText.substring(newCursorPos, newCursorPos + 1);
      RegExp reg = RegExp(r'(?=[@|#])');
      var nearRegexLeftIndex = newText.substring(0, newCursorPos).lastIndexOf(reg);
      return !(
        (reg.hasMatch(right) && reg.hasMatch(left))
        || (nearRegexLeftIndex == -1 ? false : reg.hasMatch(newText.substring(nearRegexLeftIndex - 1, nearRegexLeftIndex)))
      );
    } catch (e) {
      return false;
    }
  }

  void suggestionListerner() {
    Map? current = getOperationOfOffset();
    if (current == null) return setState(() {
      _selectedMention =  null;
    });
    int start  = controller.selection.start;

    int startCurrent = current["start_offset"];
    
    Operation op = current["operation"];

    String texta = op.value.toString();

    final cursorPos = start - startCurrent;

    if (cursorPos >= 0) {
      var _pos = 0;

      final lengthMap = <LengthMap>[];
      // final String text = convertStringRegex(controller.value.text);
      final String text = texta.replaceAllMapped(RegExp(r'(?=[@|#]{2,})'), (map) {
        return  (map.group(0) ?? "").split("").map((e) => "_").join();
      });
      // split on each word and generate a list with start & end position of each word.
      text.split(RegExp(r'(?=[@|#])')).forEach((element) {
        lengthMap.add(LengthMap(str: element, start: _pos, end: _pos + element.length));
        _pos = _pos + element.length;
      });

      var val = lengthMap.indexWhere((element) {
        String? content;
        _pattern = widget.mentions.map((e) => e.trigger).join('|');

        try {
          if (element.start! <= cursorPos && cursorPos <= (element.end ?? 0)) content = texta.substring(element.start!, cursorPos);
        } catch (e) { }

        return content == null  ? false : content.toLowerCase().contains(RegExp(_pattern));
      });
      if (!checkCanShowInElement(text, cursorPos)){
         val = -1;
      }
      showSuggestions.value = val != -1;

      if (widget.onSuggestionVisibleChanged != null) {
        widget.onSuggestionVisibleChanged!(val != -1);
      }

      LengthMap? t;
      bool hasShow = true;
      checkReMarkUpText(editingValue.text);
      try {
        // end là vị trí con trỏ hiện tại
        t = LengthMap(end: cursorPos, start: lengthMap[val].start, str: texta.substring(lengthMap[val].start!, cursorPos));
        if (checkIsInMention()) hasShow = false;
      } catch (e) { }

      setState(() {
        _selectedMention = hasShow ? t : null;
      });
    }
  }

  convertStringRegex(String l) {
    var s = "";
    var length = l.length + 2;
    for(var i =0; i< length; i++){
      if (i == 0 || i == length -1) continue;
      var index  = i-1;
      if (l[index] != "@" || l[index] != "#"){
        s+=l[index];
        continue;
      } else {
        if ((index - 1 >= 0 ? (l[index -1] == " " || l[index -1] == "\n") : true) && (index +1 < l.length ? (l[index +1] != "@" || l[index +1] != "#") : true))
          s+=l[index];
        else s+= "_";
      }
    }

    return s;
  }

  // ktra xem co ton tai ``` truoc con tro chout hay ko
  bool checkStartCodeBlock(String text) {
    return text.trim().endsWith('```');
  }

  bool checkEndCodeBlock(){
    // ktra xem start dang la cuoi trong code_block ko
    int start  = controller.selection.start;
    final nodes =  document.root.children;
    int a = 0;
    for(final i in nodes) {
      bool isCodeBlockOfNode = i.style.keys.toList().contains("code-block");
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
      }
      // neu isCodeBlockOfNode, thi luon co \n o cuoi doan nhung ko dc hien thi => -1
      if ((a -1) == (start) && isCodeBlockOfNode) {
        return true;
      }
    }
    return false;
  }

  bool checkEndInLineCode(){
    try {
      int start = controller.selection.start;
      if (start == 0) return false;
      // kiểm tra xem ký tự trước có là "`"
      String lastStrStart = editingValue.text.substring(start -1, start);
      if ("`" != lastStrStart) return false;
      // lấy phần tử chưa con tror hiện tại
      final nodes =  document.root.children;
      int a = 0;
      for(final i in nodes) {
        if (a > start) return false;
        bool isCodeBlockOfNode = i.style.keys.toList().contains("code-block");
        List deltaOfNode = i.toDelta().toList();
        for(Operation t in deltaOfNode){
          // tong so phan tu cho den het phan tu dang duyet
          a += t.data.toString().length;
          // phan tu hien tai khi `start` <= `tong so phan tu cho den het phan tu dang duyet`, va phan tu do ko phai la code_block
          if (start <= a && !isCodeBlockOfNode){
            // tim xem co ton tai vi tri cua "`" bat dau ko
            int indexEndOfValueLeft = t.value.length - (a - start) - 1;
            if (indexEndOfValueLeft <= -1) return false;
            String valueLeft = t.value.substring(0, indexEndOfValueLeft);
            int indexStartInLineCode = valueLeft.split("").lastIndexWhere((ele) => ele == "`");

            if (indexStartInLineCode == -1) return false;
            // lay ra chuoi raw trong 2 dau "`" va
            String raw = t.value.substring(indexStartInLineCode, t.value.length - (a - start)).toString().replaceAll("`", "");
            // trong truong hop raw cung co dau " " o dau hoac cuoi => can loai bo
            int numberSpaceNeedTrimInRaw = raw.length - raw.trim().length;
            raw = raw.trim();
            // new raw == "" khi do cac dau "`" lien tiep nhau => return false;
            if (raw != ""){
              int startGlobal = a - t.data.toString().length + indexStartInLineCode;
              // phai dung raw.length + 2 de laij bo 2 dau "`", sau do thay the = raw + "  " de ket thuc inline va buoc sang style moi
              controller.replaceText(startGlobal, raw.length + numberSpaceNeedTrimInRaw + 2, raw + "  ", TextSelection.collapsed(offset: start - numberSpaceNeedTrimInRaw - 1));
              // format lai doan text sau khi da replace
              controller.formatText(startGlobal, raw.length , Attribute.inlineCode);
              // ket thuc inline va chuyen sanf type moi
              controller.formatText(startGlobal + raw.length, 1, Attribute.clone(Attribute.inlineCode, null));

              return true;
            }
          }
        }
      }
      return false;      
    } catch (e, t) { 
      print("__+_+_+_$e, $t");
      return false;}

  }
  
  bool checkInCodeBlock(){
    int start  = controller.selection.start;
    final nodes =  document.root.children;
    int a = 0;
    for(final i in nodes) {
      if (a > start) return false;
      bool isCodeBlockOfNode = i.style.keys.toList().contains("code-block");
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
      }
      // neu isCodeBlockOfNode, thi luon co \n o cuoi doan nhung ko dc hien thi => -1
      if (isCodeBlockOfNode) {
        return start <= a;
      }
    }
    return false;
  }

  bool checkIsInLineCode(){
    int start = controller.selection.start;
    final nodes =  document.root.children;
    int a = 0;
    for(final i in nodes) {
      if (a > start) return false;
      bool isCodeBlockOfNode = i.style.keys.toList().contains("code-block");
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
        // chi check khi start <= tong so phan tu da duuyet, va node do khong phai code_block va phai co attributes["code"] = true
        if (start <= a){
          return !isCodeBlockOfNode && (t.attributes ?? {})["code"] != null;
        }
      }
    }
    return false;
  }

  bool checkIsInMention(){
    int start = controller.selection.start;
    final nodes = document.root.children;
    int a = 0;
    for(final i in nodes) {
      if (a > start) return false;
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
        // chi check khi start <= tong so phan tu da duuyet, va node do khong phai code_block va phai co attributes["code"] = true
        if (start <= a){
          return (t.attributes ?? {})["mention"] != null;
        }
      }
    }
    return false;
  }

  Map? getOperationOfOffset(){
    int start = controller.selection.start;
    final nodes = document.root.children;
    int a = 0;
    for(final i in nodes) {
      if (a > start) return null;
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
        // chi check khi start <= tong so phan tu da duuyet, va node do khong phai code_block va phai co attributes["code"] = true
        if (start <= a){
          return {
            "start_offset": a - value.toString().length,
            "operation": t
          };
        }
      }
    }
    return null;
  }

  Operation? getMentionIn(){
    int start = controller.selection.start;
    final nodes = document.root.children;
    int a = 0;
    for(final i in nodes) {
      if (a > start) return null;
      List deltaOfNode = i.toDelta().toList();
      for(var t in deltaOfNode){
        var value = (t as Operation).value;
        a += value.toString().length;
        // chi check khi start <= tong so phan tu da duuyet, va node do khong phai code_block va phai co attributes["code"] = true
        if (start <= a){
          if ((t.attributes ?? {})["mention"] != null) {
            return t;
          }
          return null;
        }
      }
    }
    return null;
  }

  void inputListeners() {
    if (widget.onChanged != null) {
      widget.onChanged!(editingValue.text);
    }

    int start = controller.selection.start;

    if (checkIsInMention()) {
      Map? dataCur = getOperationOfOffset();
      if (dataCur == null) return;
      // lay data mention trong quill
      Operation men = dataCur["operation"];
      // lay doan text sau trigger
      String displayOfMen = men.value.toString().substring(1);
      // lay chuoi danh dau mention
      String valueOfMen = (men.attributes ?? {})["mention"] ?? "";
      // lay vi tri bat dau mention
      int indexStart = leftLastStartTrigger(editingValue.text.substring(0, controller.selection.extentOffset), men.value.toString()[0]);
      // ktra xem displayOfMen co match voi valueOfMen

      final List<String> splitText = valueOfMen.split('^^^^^');
      final String userOfMen = splitText[1].trim();

      if(userOfMen != displayOfMen.trim()) {
          controller.formatText(dataCur["start_offset"], start - (dataCur["start_offset"] as int), Attribute.clone(MentionAttribute(""), null) );
        // format lai Text
        controller.formatText(indexStart, men.value.toString().length, Attribute.clone(MentionAttribute(""), null));
      }
    }

    if (widget.onSearchChanged != null && _selectedMention?.str != null) {
      final str = _selectedMention!.str!.toLowerCase();

      widget.onSearchChanged!(str[0], str.substring(1));
      final valueSearch = _selectedMention?.str?.toLowerCase().substring(1);
      var result = checkMention(valueSearch);

      setState(() {
        triggerMention = result;
      });
    } else if(triggerMention) {
      setState(() {
        triggerMention = false;
      });
    }
  }

  //Listen keyevent to autofocus main reply

  checkMention(value) {
    var text = !Utils.checkedTypeEmpty(value) ? "" : value;
    RegExp exp = new RegExp(r"@");
    var matchs = exp.allMatches(text).toList();
    if (matchs.length == 0 ) return true;
    else return false;
  }

  @override
  void initState() {
    // setup a listener to figure out which suggestions to show based on the trigger
    controller.addListener(suggestionListerner);

    controller.addListener(inputListeners);

    RawKeyboard.instance.addListener(handleKey);

    super.initState();

    if (widget.initValue != null) {
      controller.clear();
      controller.document.insert(0, widget.initValue);
      controller.updateSelection(TextSelection.collapsed(offset: widget.initValue!.length), ChangeSource.LOCAL);
    }
  }

  void handleKey(RawKeyEvent event) {
    if(event is RawKeyDownEvent && [LogicalKeyboardKey.delete, LogicalKeyboardKey.backspace].contains(event.logicalKey)) {
      bool isSelectAll = editingValue.selection.baseOffset == 0 && editingValue.selection.extentOffset == editingValue.text.length - 1;
      if(isSelectAll) {
        controller.document = Document();
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(suggestionListerner);
    controller.removeListener(inputListeners);
    RawKeyboard.instance.removeListener(handleKey);
    controller.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  checkMentionIssue(data) {
    if (data.length > 0 && data[0]["full_name"] != null) {
      return false;
    } else {
      return true;
    }
  }

  int levelMentionRegex(String text) {
    final _vietnamese = 'aâăAÂĂeêEÊoôơOÔƠuưUƯyY';
    final _vietnameseRegex = <RegExp>[
      RegExp(r'à|á|ạ|ả|ã'),
      RegExp(r'ầ|ấ|ậ|ẩ|ẫ'),
      RegExp(r'ằ|ắ|ặ|ẳ|ẵ'),
      RegExp(r'À|Á|Ạ|Ả|Ã'),
      RegExp(r'Ẫ|Ầ|Ấ|Ậ|Ẩ'),
      RegExp(r'Ằ|Ắ|Ặ|Ẳ|Ẵ'),
      RegExp(r'è|é|ẹ|ẻ|ẽ'),
      RegExp(r'ề|ế|ệ|ể|ễ'),
      RegExp(r'È|É|Ẹ|Ẻ|Ẽ'),
      RegExp(r'Ề|Ế|Ệ|Ể|Ễ'),
      RegExp(r'ò|ó|ọ|ỏ|õ'),
      RegExp(r'ồ|ố|ộ|ổ|ỗ'),
      RegExp(r'ờ|ớ|ợ|ở|ỡ'),
      RegExp(r'Ò|Ó|Ọ|Ỏ|Õ'),
      RegExp(r'Ồ|Ố|Ộ|Ổ|Ỗ'),
      RegExp(r'Ờ|Ớ|Ợ|Ở|Ỡ'),
      RegExp(r'ù|ú|ụ|ủ|ũ'),
      RegExp(r'ừ|ứ|ự|ử|ữ'),
      RegExp(r'Ù|Ú|Ụ|Ủ|Ũ'),
      RegExp(r'Ừ|Ứ|Ự|Ử|Ữ'),
      RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
      RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
    ];

    var result = text;
    for (var i = 0; i < _vietnamese.length; ++i) {
      result = result.replaceAll(_vietnameseRegex[i], _vietnamese[i]);
    }

    int level = 0;

    if (Utils.unSignVietnamese(text) == text ) {
      level = 1;
    } else {
      if(text == result ) {
        level = 2;
      } else {
        level = 3;
      }
    }

    return level;
  }

  List filterOption ({bool filterRequire = false}) {
    try {
      if (!filterRequire){
        if (_selectedMention == null) return [];
        if (dataFiltered["str"] == _selectedMention!.str) return dataFiltered["data"];
      }

      final list = _selectedMention != null
          ? widget.mentions.firstWhere((element) => _selectedMention!.str!.contains(element.trigger))
          : widget.mentions[0];

      final data = _selectedMention != null ? list.data.where((e) {
        String fullName = Utils.unSignVietnamese(e["full_name"] ?? e["display"] ?? "");
        String userName = Utils.unSignVietnamese(e['username'] ?? '');
        final str = _selectedMention!.str!
          .replaceAll(RegExp(_pattern), '');

        bool check = fullName.contains(Utils.unSignVietnamese(str)) || userName.contains(Utils.unSignVietnamese(str));
        return check;
      }).toList() : [];

      if (_selectedMention == null  || _selectedMention!.str!.length == 1) return data;
      var fuse = Fuzzy(data, options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: "display",
            getter: (item){
              if (item == null) return "";
              return (Utils.unSignVietnamese((item as Map)["display"]));
            },
            weight: 1
          )
        ]
      ));
      dataFiltered = {
        "str": _selectedMention!.str,
        "data":  fuse.search(_selectedMention == null ? "" : Utils.unSignVietnamese(_selectedMention!.str ?? "")).map((ele) => ele.item).toList()
      };

      String text = _selectedMention!.str != null ? _selectedMention!.str!.substring(1) : '';
      int level = levelMentionRegex(text);

      dataFiltered["data"] = searchMention(data, text, level);

      return dataFiltered["data"];
    } catch (e) {
      return [];
    }
  }

  List searchMention(List data, String text, int level) {
    List dataSearch = [];

    if (level == 1) {
      dataSearch = data;
    } else if (level == 2) {
      dataSearch = data.where((ele) {
        final bool check =  Utils.convertCharacter(ele["display"]).contains(Utils.convertCharacter(text));

        return check;
      }).toList();
    } else if (level == 3) {
      dataSearch = data.where((ele) {
        final bool check =  ele["display"].toLowerCase().contains(text.toLowerCase());

        return check;
      }).toList();
    }

    if(dataSearch.length == 0 && level > 0) {
      dataSearch = searchMention(data, text, level - 1);
    }

    if(dataSearch.length > 1) {
      dataSearch.sort((a, b) {
        return a['display'].length.compareTo(b['display'].length);
      });
    }

    return dataSearch;
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on the selection
    final data = filterOption();
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    bool isMentionIssue = checkMentionIssue(data);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: PortalEntry(
        portalAnchor: Alignment.bottomCenter,
        childAnchor: Alignment.topCenter,
        portal: ValueListenableBuilder(
          valueListenable: showSuggestions,
          builder: (BuildContext context, bool show, Widget? child) {
            return show && !widget.hideSuggestionList
                ? OptionList(
                    isMentionIssue: isMentionIssue,
                    isDark: widget.isDark,
                    suggestionListHeight: Utils.checkedTypeEmpty(widget.isForwardMessage)
                      ? widget.suggestionListHeight / 2.3
                      : widget.suggestionListHeight,
                    data: data,
                    onTap: (value) {
                      addMention(value);
                      showSuggestions.value = false;
                    },
                  )
                : Container();
          },
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...widget.leading,
            // Expanded(
            //   child: MouseRegion(
            //     cursor: SystemMouseCursors.text,
            //     child: QuillEditor(
            //       key: key,
            //       keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
            //       cursorHeight: Platform.isAndroid ? 25 : 15,
            //       controller: controller,
            //       scrollController: scrollController,
            //       placeholder: widget.decoration.hintText,
            //       focusNode: focusNode,
            //       scrollable: true,
            //       autoFocus: widget.autofocus,
            //       showCursor: widget.showCursor,
            //       cursorColor: widget.cursorColor,
            //       readOnly: widget.readOnly,
            //       enableSelectionToolbar: true,
            //       customStyleBuilder: (attr) {
            //         if (attr.key == 'mention') {
            //           return TextStyle(color: widget.isDark ? Color(0xFFFAAD14) : Color(0xff1890FF));
            //         }
            //         return const TextStyle();
            //       },
            //       expands: false,
            //       padding: EdgeInsets.all(10),
            //       minHeight: 42,
            //       maxHeight: 234,
            //       customStyles: DefaultStyles(
            //         placeHolder: DefaultTextBlockStyle(
            //           DefaultTextStyle.of(context).style.merge(widget.decoration.hintStyle),
            //           const Tuple2(0, 0),
            //           const Tuple2(0, 0),
            //           null
            //         ),
            //         link: TextStyle(
            //           color: widget.isDark ? Color(0xFFFAAD14) : Color(0xff1890FF),
            //           decoration: TextDecoration.underline
            //         )
            //       ),
            //     ),
            //   ),
            // ),
            ...widget.trailing,
          ],
        ),
      ),
    );
  }
}
