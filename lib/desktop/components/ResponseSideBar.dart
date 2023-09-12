import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class ResponseSideBar extends StatefulWidget{
  ResponseSideBar({
    @required this.child,
    this.onResize,
    this.minWidth = 230,
    this.maxWidth = 630
  });
  final child;
  final onResize;
  final double minWidth;
  final double maxWidth;
  @override
  State<StatefulWidget> createState() {
    return _ResponseSideBarState();
  }
}
class _ResponseSideBarState extends State<ResponseSideBar>{
  var wrapperSize;
  var objectSize;
  bool _onHover = false;
  bool _onPan = false;
  var globalPosition;
  GlobalKey wrapperKey = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => findWidgetPosition());
    super.initState();
  }
  void findWidgetPosition(){
    final renderObject = wrapperKey.currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if(translation != null){
      setState(() {
        objectSize = Size(renderObject!.paintBounds.width, renderObject.paintBounds.height);
        wrapperSize = objectSize;
        globalPosition = Offset(renderObject.paintBounds.width + translation.x, renderObject.paintBounds.height + translation.y);
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return objectSize == null ?
      LayoutBuilder(
        key: wrapperKey,
        builder: (context, constraints) {
          return widget.child;
        },
      )
      :Container(
        color: Color(0xff323f4b),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: _onPan ? 0 : 70),
              width: wrapperSize.width > widget.maxWidth ? widget.maxWidth : wrapperSize.width,
              child: widget.child,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: rightEdge(context)
            )
          ],
        ),
      );
  }
  Widget rightEdge(context){
    void _onEnter(PointerEvent event){
      setState(() {
        _onHover = true;
      });
    }
    void _onExit(PointerEvent event){
      setState(() {
        _onHover = false;
      });
    }
    return GestureDetector(
      onPanStart: (details){
        setState(() {
          _onPan = true;
        });
      },
      onPanUpdate: (details) {
        double newWidth = details.globalPosition.dx - (globalPosition.dx - objectSize.width);
        setState(() {
          wrapperSize = Size((newWidth < widget.minWidth) ? widget.minWidth : (newWidth > widget.maxWidth) ? widget.maxWidth : newWidth, wrapperSize.height);
        });
        
        if(widget.onResize != null && wrapperSize != null ) {
          widget.onResize(wrapperSize);
        }
        Provider.of<Windows>(context, listen: false).resSidebarSize = wrapperSize;
      },
      onPanEnd: (details){
        setState(() {
          _onPan = false;
        });
        Provider.of<Windows>(context, listen: false).saveResSidebarToHive();
      },
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          width: _onHover || _onPan ? 4 : 1,
          height: MediaQuery.of(context).size.height,
          color: _onHover || _onPan ? Colors.blue : Color.fromRGBO(31, 41, 51, 1)
        ),
      ),
    );
  }
}