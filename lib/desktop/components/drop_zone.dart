import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class StreamDropzone extends ValueNotifier<bool>{
  static final channel = MethodChannel("drop_zone");
  static final instance = StreamDropzone();

  final _droppedController = StreamController<List>.broadcast(sync: false);
  final _stringController = StreamController<String>.broadcast(sync: false);
  final _focusedController = StreamController<bool>.broadcast(sync: false);
  StreamDropzone() : super(false){
    channel.setMethodCallHandler((call) async{
      switch (call.method){
        case "entered":
          value = true;
          break;
        case "exited":
          value = false;
          break;
        case "update":
          break;
        case "dropped":
          _droppedController.add(call.arguments);
          value = false;
          break;
        case "change_theme":
          _stringController.add(call.arguments);
        break;
        case "is_focused":
          _focusedController.add(call.arguments);
        break;
      }

      return null;
    });
  }

  Stream<List> get dropped => _droppedController.stream;
  Stream<String> get currentTheme => _stringController.stream;
  Stream<bool> get isFocusedApp =>_focusedController.stream;
  initDrop(){
    _droppedController.add([]);
  }
}


class DropZone<T, S> extends StatefulWidget{
  const DropZone({
    Key? key,
    this.stream,
    this.initialData,
    @required this.builder
  });

  final stream;
  final builder;
  final initialData;
  @override
  State<StatefulWidget> createState() => _DropZoneState();
}

class _DropZoneState<T, S> extends State<DropZone<T, S>>{
  var _subscription;
  var _summary;
  GlobalKey key = GlobalKey();
  var objectSize;
  var wrapperSize;
  var globalPosition;
  var renderBox;
  late bool hasFocus;
  double? ratioScreen;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      StreamDropzone.instance.initDrop();
      findWidgetPosition();
    });
    _summary = widget.initialData == null ? AsyncSnapshot<T>.nothing() : AsyncSnapshot<T>.withData(ConnectionState.none, widget.initialData);
    _subscribe();
  }
  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
  @override
  void didUpdateWidget(covariant var oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.stream != widget.stream){
      if(_subscription != null){
        _unsubscribe();
        _summary = _summary.inState(ConnectionState.none);
      }
      _subscribe();
    }
    if(oldWidget.builder != widget.builder){
      WidgetsBinding.instance.addPostFrameCallback((_){
        StreamDropzone.instance.initDrop();
        findWidgetPosition();
    });
    }
  }

  void _subscribe(){
    if(widget.stream != null){
      _subscription = widget.stream.listen((data) {
        if(data.length != 0) {
          final curStr = data[0].toString();
          if(curStr == "paste_bytes"){
            if(hasFocus){
              final _dataStream = new List<dynamic>.from(data);
              _dataStream.removeAt(0);
              Future.wait(
                (_dataStream).map((bytes) async {})
              ).then((value){
                setState(() {
                  _summary = AsyncSnapshot<T>.withData(ConnectionState.active, value.where((element) => element != null).toList() as T);
                });
              });
            }
          }
          else if(curStr == "paste"){
            if (hasFocus){
              final _dataStream = new List<dynamic>.from(data);
              _dataStream.removeAt(0);
              Future.wait(
                (_dataStream).map((uro) async{
                  try{
                    var uri = uro.replaceAll("%2520", "%20");
                    File file = File(uri);
                    var name  = file.path.split("\\").last;
                    var type =  name.split(".").last;
                    if (type  == "png" || type == "jpg" || type == "jpeg") type = "image";
                    if (type == "") type = "text";
                    // print(type);

                    return {
                      "name": name,
                      "mime_type": "image",
                      "path": file.path,
                      "file": await file.readAsBytes()
                    };
                  } catch(e){
                    return null;
                  }
                })
              ).then((value){
                setState(() {
                  _summary = AsyncSnapshot<T>.withData(ConnectionState.active, value.where((element) => element != null).toList() as T);
                });
              });
            }
          }
          else{
            final d = curStr.split(":");
            findWidgetPosition();
            final cursor = Offset(double.parse(d[0]), double.parse(d[1]));
            if(renderBox.contains(cursor)){
              final _dataStream = new List<dynamic>.from(data);
              _dataStream.removeAt(0);
              Future.wait(
                (_dataStream).map((uro) async{
                  try{
                    var uri = uro.replaceAll("%2520", "%20");
                    File file = Platform.isWindows ? File(uri) : File.fromUri(Uri.parse(uri));
                    var name  = Platform.isWindows ? file.path.split("\\").last :  file.path.split("/").last;
                    var type =  name.split(".").last;
                    if (type  == "png" || type == "jpg" || type == "jpeg") type = "image";
                    if (type == "") type = "text";

                    return {
                      "name": name,
                      "mime_type": type,
                      "path": file.path,
                      "file": await file.readAsBytes()
                    };
                  } catch(e){
                    return null;
                  }
                })
              ).then((value){
                setState(() {
                  _summary = AsyncSnapshot<T>.withData(ConnectionState.active, value.where((element) => element != null).toList() as T);
                });
              });
            }
          }
        }
        else{
          _summary = AsyncSnapshot<T>.withData(ConnectionState.active, [] as T);
        }
      }, onError: (Object error){
        setState(() {
          _summary = AsyncSnapshot<T>.withError(ConnectionState.active, error);
        });
      }, onDone: () {
        setState(() {
          _summary = _summary.inState(ConnectionState.done);
        });
      });
      _summary = _summary.inState(ConnectionState.waiting);
    }
  }
  void _unsubscribe(){
    if (_subscription != null){
      _subscription.cancel();
      _subscription = null;
    }
  }
  void findWidgetPosition(){
    final renderObject = key.currentContext?.findRenderObject() as RenderBox;
    var translation = renderObject.getTransformTo(null).getTranslation();
    setState(() {
      double _ratio =  ratioScreen != null && Platform.isWindows ? ratioScreen! : 1;
      objectSize = Size(renderObject.paintBounds.width * _ratio, renderObject.paintBounds.height * _ratio);
      // wrapperSize = objectSize;
      // globalPosition = Offset(renderObject.paintBounds.width + translation.x, renderObject.paintBounds.height + translation.y);
      renderBox = Offset(translation.x * _ratio, translation.y * _ratio) & objectSize;
    });
  }
  @override
  Widget build(BuildContext context) {
    ratioScreen = MediaQuery.of(context).devicePixelRatio;
    return FocusScope(
      key: key,
      autofocus: true,
      child: Focus(
        onFocusChange: (value) {
          if(value){
            hasFocus = true;
          }
          else{
            hasFocus = false;
          }
        },
        child: Container(
          child: widget.builder(context, _summary),
        ),
      ),
    );
  }
}
