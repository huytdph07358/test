part of flutter_mentions;

class FlutterMentionsIssue extends StatefulWidget {
  FlutterMentionsIssue({
    required this.mentions,
    required Key key,
    this.suggestionListHeight = 300.0,
    this.onMarkupChanged,
    this.onMentionAdd,
    this.onSearchChanged,
    this.leading = const [],
    this.trailing = const [],
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 22,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled,
    this.cursorWidth = 1.0,
    this.cursorHeight = 15,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.onTap,
    this.buildCounter,
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.appendSpaceOnAdd = true,
    this.hideSuggestionList = false,
    this.onSuggestionVisibleChanged,
    this.controller,
    this.id,
    this.islastEdited = false,
    this.isIssues,
    this.isForwardMessage,
    this.isDark,
    this.parseMention,
    this.afterFirstFrame,
  }) : super(key: key);

  final bool? isIssues;

  final bool? isForwardMessage;

  final Function? afterFirstFrame;

  final bool islastEdited;

  final TextEditingController? controller;

  final bool? isDark;

  final String? id;

  final bool hideSuggestionList;

  final Function(bool)? onSuggestionVisibleChanged;

  final List<Mention> mentions;

  final List<Widget> leading;

  final List<Widget> trailing;

  final Function(Map<String, dynamic>)? onMentionAdd;

  final double suggestionListHeight;

  final ValueChanged<String>? onMarkupChanged;

  final void Function(String trigger, String value)? onSearchChanged;

  final bool appendSpaceOnAdd;

  final InputDecoration decoration;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle? style;

  final StrutStyle? strutStyle;

  final TextAlign textAlign;

  final TextDirection? textDirection;

  final bool autofocus;

  final bool autocorrect;

  final bool enableSuggestions;

  final int maxLines;

  final int? minLines;

  final bool expands;

  final bool readOnly;

  final bool? showCursor;

  static const int noMaxLength = -1;

  final int? maxLength;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onEditingComplete;

  final ValueChanged<String>? onSubmitted;

  final bool? enabled;

  final double cursorWidth;

  final double cursorHeight;

  final Radius? cursorRadius;

  final Color? cursorColor;

  final Brightness? keyboardAppearance;

  final EdgeInsets scrollPadding;

  final bool enableInteractiveSelection;

  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback? onTap;

  final InputCounterWidgetBuilder? buildCounter;

  final ScrollPhysics? scrollPhysics;

  final ScrollController? scrollController;

  final Iterable<String>? autofillHints;

  final Function? parseMention;

  @override
  FlutterMentionsIssueState createState() => FlutterMentionsIssueState();
}

class FlutterMentionsIssueState extends State<FlutterMentionsIssue> {
  AnnotationEditingController? controller;
  ValueNotifier<bool> showSuggestions = ValueNotifier(false);
  LengthMap? _selectedMention;
  String _pattern = '';
  FocusNode focusNode = FocusNode();
  Map<String, dynamic>? currentMention;
  var _textMarkUp = "";
  Alignment? alignment;

  Map<String, Annotation> mapToAnotation() {
    final data = <String, Annotation>{};

    // Loop over all the mention items and generate a suggestions matching list
    widget.mentions.forEach((element) {
      // if matchAll is set to true add a general regex patteren to match with
      if (element.matchAll) {
        data['${element.trigger}([A-Za-z0-9])*'] = Annotation(
          style: element.style,
          id: null,
          display: null,
          trigger: element.trigger,
          disableMarkup: element.disableMarkup,
          markupBuilder: element.markupBuilder,
        );
      }
      element.data.forEach(
        (e) => data["${element.trigger}${e['display']}"] = e['style'] != null
            ? Annotation(
                style: e['style'],
                id: e['id'],
                display: e['display'],
                trigger: element.trigger,
                disableMarkup: element.disableMarkup,
                markupBuilder: element.markupBuilder,
              )
            : Annotation(
                style: element.style,
                id: e['id'],
                display: e['display'],
                trigger: element.trigger,
                disableMarkup: element.disableMarkup,
                markupBuilder: element.markupBuilder,
              ),
      );
    });

    return data;
  }

  void setMarkUpText(String markUp){
    var parse  = checkMentions(markUp);
    _textMarkUp = markUp;
    controller!.text =  parse["success"] ? Utils.getStringFromParse(parse["data"]) : markUp;
    controller!.selection = TextSelection.fromPosition(TextPosition(offset: (controller!.text.length)));
  }

  String getStringFromParse(List parses){
    return Utils.getStringFromParse(parses);
  }

  String getMarkUpFromParse(List parses){
    return parses.map((e) {
      if (e["type"] == "text") return e["value"];
      try {
        var trigger = e["trigger"];
        final _list = widget.mentions.firstWhere((element) => trigger.contains(element.trigger));
        return _list.markupBuilder( e["trigger"], e["value"], e["name"], e["type"]);
      } catch (err) {
        // case nay vi mobile chua co mention issue => ham markUp se lay mac dinh
        return "=======${e["trigger"]}/${e["value"]}^^^^^${e["name"]}^^^^^${e["type"]}+++++++";
      }
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
    if (widget.parseMention == null) return checkMentions(markUpText);
    return widget.parseMention!(markUpText, trim: false);
  }

  int checkIsInOldMention(List dataParse, int count){
    if (count < 0) return -1;
    var offset = 0;
    for(int i =0 ; i < dataParse.length ; i++){
      String strDataParse = dataParse[i]["type"] == "text" ? dataParse[i]["value"] : "${dataParse[i]["trigger"]}${dataParse[i]["name"]}";
      if (offset + (strDataParse.length) <= count) {
        offset += strDataParse.length;
        continue;
      }
      if (dataParse[i]["type"] != "text") return i;

    }
    return -1;
  }
  
  void addMention(Map<String, dynamic> value, [Mention? list]) {
    final selectedMention = _selectedMention!;
    var t = _selectedMention;
    setState(() {
      _selectedMention = null;
      currentMention = null;
    });

    final _list = widget.mentions.firstWhere((element) => selectedMention.str!.contains(element.trigger));
    if (t == null) return;
    var text = controller!.value.text;
    var parse = checkMentions(_textMarkUp);
    if (parse["success"] == false){
      // neu tin do chua co mention, thi tu them vao vi tri con tro
      _textMarkUp = text.replaceRange(
        selectedMention.start!,
        selectedMention.end,
        _list.markupBuilder(_list.trigger, value["id"], value["display"], value["type"] ) + (widget.appendSpaceOnAdd ? " " : "")
      );
      controller!.text = controller!.value.text.replaceRange(
        selectedMention.start!,
        selectedMention.end,
        "${_list.trigger}${value['display']}${widget.appendSpaceOnAdd ? ' ' : ''}",
      );

      if (widget.onMentionAdd != null) widget.onMentionAdd!(value);

      // Move the cursor to next position after the new mentioned item.
      var nextCursorPosition = selectedMention.start! + 1 + value['display']?.length as int? ?? 0;
      if (widget.appendSpaceOnAdd) nextCursorPosition++;
      controller!.selection = TextSelection.fromPosition(TextPosition(offset: nextCursorPosition));        
    } else {
      var dataParses  = parse["data"];

      // thay the mention hien tai = mention moi (neu da o mention)

      var indexMentionOld = checkIsInOldMention(dataParses,  selectedMention.start  ?? -1);
      if (indexMentionOld  == -1){
          // khoi tao lai chuoi trai
          var leftStr = leftNewString(dataParses, selectedMention.start!);

          //  khoi tao chuoi phai
          var rightStr = rightNewString(dataParses, text.length - selectedMention.end!);

          // khoi tao chuoi giua
          var innerStr = getMarkUpFromParse([{
            "type": value["type"],
            "value": value["id"],
            "trigger": _list.trigger,
            "name": value["display"]
          }]);

          // print("keft: $leftStr \n right: $rightStr \n inner: $innerStr");

          _textMarkUp = (leftStr + innerStr + (widget.appendSpaceOnAdd ? " " : "") + rightStr);
          autoDetectMention();

          // print("onaddMention: ,$_textMarkUp,");

          controller!.text = controller!.value.text.replaceRange(
            selectedMention.start!,
            selectedMention.end,
            "${_list.trigger}${value['display']}${widget.appendSpaceOnAdd ? ' ' : ''}",
          );

          if (widget.onMentionAdd != null) widget.onMentionAdd!(value);

          // Move the cursor to next position after the new mentioned item.
          var nextCursorPosition = selectedMention.start! + 1 + value['display']?.length as int? ?? 0;
          if (widget.appendSpaceOnAdd) nextCursorPosition++;
          controller!.selection = TextSelection.fromPosition(TextPosition(offset: nextCursorPosition));            
        } else {
          dataParses[indexMentionOld] = {
            "type": value["type"],
            "trigger": _list.trigger,
            "value": value["id"],
            "name": value["display"]
          };
          if (indexMentionOld == (dataParses.length - 2)) dataParses += [{"type": "text", "value": " "}];
          _textMarkUp = getMarkUpFromParse(dataParses);
          controller!.text = getStringFromParse(dataParses);
          var nextCursorPosition = selectedMention.start! + 1 + value['display']?.length as int? ?? 0;
          controller!.selection = TextSelection.fromPosition(TextPosition(offset: nextCursorPosition + 1 > controller!.text.length ? nextCursorPosition : nextCursorPosition + 1)); 
      }
    }
  }

  checkReMarkUpText(String newString){
    var parse = checkMentions(_textMarkUp);
    if (parse["success"] == false){
      _textMarkUp = newString;
    } else {
      var dataParses  = parse["data"];
      // lay lai text cu
      var oldStr = getStringFromParse(dataParses);
      var newStr = controller!.text;
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
    autoDetectMention();
  }

  autoDetectMention(){
    controller!.setMarkText(_textMarkUp);
    // List totalMentions = widget.mentions.map((ele) {
    //   return ele.data.map((d) {
    //     return Utils.mergeMaps([
    //       d, 
    //       {
    //         "trigger": ele.trigger,
    //         "strMath": Utils.unSignVietnamese("${ele.trigger}${d["display"]}")
    //       }
    //     ]);
    //   });
    // }).toList().reduce((value, element) => value = value + element).toList();
    // totalMentions.sort((a, b) =>  a["strMath"].length <= b["strMath"].length ? 1 :  -1);

    // var parses = [];
    // if (parse["success"] == false){
    //   parses = [{
    //     "type": "text",
    //     "value": _textMarkUp,
    //   }];
    // } else {
    //   parses = parse["data"];
    // }
    // var results = [];
    // for (int i = 0; i < parses.length; i++){
    //   if (parses[i]["type"] != "text") {
    //     results  = [] + results + [parses[i]];
    //   } else {
    //     // detect
    //     // lay tat ca cac mentions lai, uu tien mention co ten dai nhat

    //     String text = parses[i]["value"];
    //     String cloneText = text;
    //     // lap den khi cloneText = ""
    //      RegExp exp = new RegExp(r"[@|#]{1}");
    //     while (cloneText != "") {
    //       if (exp.hasMatch(cloneText[0])){
    //         // tim mention dai nhat
    //         try {
    //           var first = totalMentions.firstWhere((element) {
    //             try {
    //               int length = element["strMath"].length;
    //               if (element["strMath"] == Utils.unSignVietnamese(cloneText.substring(0, length))) return true;
    //               return false;
    //             } catch (e) {
    //               return false;
    //             }
    //           });
    //           if (first == null){
    //             results += [{
    //               "type": "text",
    //               "value": cloneText[0]
    //             }];
    //             cloneText = cloneText.replaceRange(0, 1, "");
    //           } else {
    //             results += [{
    //               "type": first["type"],
    //               "name": first["display"],
    //               "trigger": first["trigger"],
    //               "value": first["id"]
    //             }];
    //             cloneText = cloneText.replaceRange(0, first["strMath"].length, "");
    //           } 
    //         } catch (e) {
    //           results += [{
    //             "type": "text",
    //             "value": cloneText[0]
    //           }];
    //           cloneText = cloneText.replaceRange(0, 1, "");
    //         }
    //       }
    //       else {
    //         results += [{
    //           "type": "text",
    //           "value": cloneText[0]
    //         }];
    //         cloneText = cloneText.replaceRange(0, 1, "");
    //       }
    //     }
    //   }
    // }
    // _textMarkUp = getMarkUpFromParse(results);
    // // an dong nay de giu lai text cu
    // // if (getStringFromParse(results) != controller!.text)
    // //   controller!.text = getStringFromParse(results);
    // controller!.setMarkText(_textMarkUp);
  }

  void suggestionListerner() {
    final cursorPos = controller!.selection.baseOffset;
    // print("cursorPos $cursorPos");

    if (cursorPos >= 0) {
      var _pos = 0;

      final lengthMap = <LengthMap>[];
      // final String text = convertStringRegex(controller!.value.text);
      final String text = controller!.value.text.replaceAllMapped(RegExp(r'(?=[@|#]{2,})'), (map) {
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
          if (element.start! <= cursorPos && cursorPos <= (element.end ?? 0)) content = controller!.value.text.substring(element.start!, cursorPos);
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
      checkReMarkUpText(controller!.value.text);
      try {
        // end là vị trí con trỏ hiện tại
        t = LengthMap(end: cursorPos, start: lengthMap[val].start, str: controller!.value.text.substring(lengthMap[val].start!, cursorPos));
        if (checkIsInOldMention(checkMentions(_textMarkUp)["data"], lengthMap[val].start ?? -1) != -1) hasShow = false;
      } catch (e) { }

      setState(() {
        _selectedMention = hasShow ? t : null;
      });
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

  convertStringRegex(String l) {
    var s = "";
    var length = l.length + 2;
    for(var i =0; i< length; i++){
      if (i == 0 || i == length -1) continue;
      var index  = i-1;
      if (l[index] != "@" || l[index] != "#"){
        s+=l[index];
        continue;
      }
      else {
        if ((index - 1 >= 0 ? (l[index -1] == " " || l[index -1] == "\n") : true) && (index +1 < l.length ? l[index +1] != "@" || l[index +1] != "#" : true ))
          s+=l[index];
        else s+= "_";
      }
    }

    return s;
  }

  void inputListeners() {
    if (widget.onChanged != null) {
      widget.onChanged!(controller!.text);
    }

    if (widget.onMarkupChanged != null) {
      widget.onMarkupChanged!(controller!.markupText);
    }

    if (widget.onSearchChanged != null && _selectedMention?.str != null) {
      final str = _selectedMention!.str!.toLowerCase();

      widget.onSearchChanged!(str[0], str.substring(1));
    }
  }

  checkMentionIssue(data) {
    if (data.length > 0 && data[0]["full_name"] != null) {
      return false;
    } else {
      return true;
    }
  }

  checkMention(value) {
    var text = !Utils.checkedTypeEmpty(value) ? "" : value;
    RegExp exp = new RegExp(r"@");
    var matchs = exp.allMatches(text).toList();
    if (matchs.length == 0 ) return true;
    else return false;
  }

  @override
  void initState() {
    final data = mapToAnotation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.afterFirstFrame != null) widget.afterFirstFrame!();
    });
    controller = AnnotationEditingController(data, context, checkMentions, widget.mentions);

    // setup a listener to figure out which suggestions to show based on the trigger
    controller!.addListener(suggestionListerner);

    controller!.addListener(inputListeners);

    super.initState();

    if (widget.controller != null) {
      controller!.text = widget.controller!.text;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller!.removeListener(suggestionListerner);
    controller!.removeListener(inputListeners);
    controller!.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    try {
      super.didUpdateWidget(oldWidget);

      controller!.mapping = mapToAnotation();    
    } catch (e) {
      print("____ $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on the selection
    final list = _selectedMention != null
        ? widget.mentions.firstWhere(
            (element) => _selectedMention!.str!.contains(element.trigger))
        : widget.mentions[0];
    final data = _selectedMention != null ? list.data.where((e) {
      final ele =  Utils.unSignVietnamese(e["display"]);
      final str = _selectedMention!.str!
        .replaceAll(RegExp(_pattern), '');
      
      bool check = ele.contains(Utils.unSignVietnamese(str));
      return check;
    }).toList() : [];
    bool isMentionIssue = checkMentionIssue(data);
    return Container(
      child: PortalEntry(
        portalAnchor: alignment ?? Alignment.bottomCenter,
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
                    : Utils.checkedTypeEmpty(widget.isIssues) ? widget.suggestionListHeight/1.8 : widget.suggestionListHeight,
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
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4)
                ),
                child: TextField(
                  // key: key,
                  // cursorHeight: widget.cursorHeight,
                  focusNode: focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines ?? (widget.isIssues! ? 22 : 1), 
                  maxLength: widget.maxLength,
                  keyboardType: TextInputType.multiline,
                  keyboardAppearance: widget.keyboardAppearance,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  style: widget.style,
                  textAlign: widget.textAlign,
                  textDirection: widget.textDirection,
                  readOnly: widget.readOnly,
                  showCursor: widget.showCursor,
                  autofocus: widget.autofocus,
                  autocorrect: widget.autocorrect,
                  cursorColor: widget.cursorColor,
                  cursorRadius: widget.cursorRadius,
                  cursorWidth: widget.cursorWidth,
                  buildCounter: widget.buildCounter,
                  autofillHints: widget.autofillHints,
                  decoration: widget.decoration,
                  expands: widget.expands,
                  onEditingComplete: widget.onEditingComplete,
                  onTap: widget.onTap,
                  enabled: widget.enabled,
                  enableInteractiveSelection: widget.enableInteractiveSelection,
                  enableSuggestions: widget.enableSuggestions,
                  scrollPadding: widget.scrollPadding,
                  scrollPhysics: widget.scrollPhysics,
                  controller: controller,
                )
              ),
            ),
            ...widget.trailing,
          ],
        ),
      ),
    );
  }
}