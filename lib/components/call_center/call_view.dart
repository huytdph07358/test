import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/components/call_center/session_call_manager.dart';
import 'package:workcake/models/models.dart';

import 'call_manager.dart';
import 'enums_consts.dart';

class CallView extends StatefulWidget {
  CallView({required this.user, this.session, required this.callback, this.conversationId});
  final user;
  final session;
  final callback;
  final conversationId;
  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with TickerProviderStateMixin {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _connected = false;
  late final user;
  bool isVideoEnable = true;

  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;
  Map<PIPViewCorner, Offset> _offsets = {};
  late PIPViewCorner _corner;
  bool isFloating = false;

  TimerCounter _timerCounter = new TimerCounter();
  late final AnimationController _toggleFloatingAnimationController;
  late final AnimationController _dragAnimationController;
  String timer = "0:00";
  @override
  void initState() {
    super.initState();
    user = widget.user;
    callManager.onCallStateChange = (state) {
      switch (state) {
        case CallConnectionState.CallStateConnected:
          if (this.mounted) setState(() {
            _connected = true;
          });
          _timerCounter.startTimeout().onChange = (second) {
            if (this.mounted) setState(() {
              SessionCallManager.sessionWithId(widget.session).timer = second;
              timer = second;
            });
          };
          break;
        default:
        break;
      }
    };
    callManager.onLocalStream = ((stream) async {
      if (_localRenderer.textureId == null) {
        await _localRenderer.initialize();
      }
      if (this.mounted) setState(() {
        _localRenderer.srcObject = stream;
      });
    });

    callManager.onAddRemoteStream = ((stream) async {
      if (_remoteRenderer.textureId == null) {
        await _remoteRenderer.initialize();
      }
      if (this.mounted) setState(() {
        _remoteRenderer.srcObject = stream;
      });
    });


    _corner = PIPViewCorner.topRight;
    _toggleFloatingAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
    _dragAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => {widget.callback?.call(this.context), print("[widget callback call] ${widget.callback == null}")});
    
  }

  void _updateCornersOffsets({
    required Size spaceSize,
    required Size widgetSize,
    required EdgeInsets windowPadding,
  }) {
    _offsets = _calculateOffsets(
      spaceSize: spaceSize,
      widgetSize: widgetSize,
      windowPadding: windowPadding,
    );
  }

  bool _isAnimating() {
    return _toggleFloatingAnimationController.isAnimating ||
      _dragAnimationController.isAnimating;
  }

  void startFloating() {
    if (_isAnimating() || isFloating) return;
    dismissKeyboard(context);
    setState(() {
      isFloating = true;
    });
    _toggleFloatingAnimationController.forward();
  }

  void stopFloating() {
    if (_isAnimating() || !isFloating) return;
    dismissKeyboard(context);
    _toggleFloatingAnimationController.reverse().whenCompleteOrCancel(() {
      if (mounted) {
        setState(() {
          isFloating = false;
        });
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = _dragOffset.translate(
        details.delta.dx,
        details.delta.dy,
      );
    });
  }

  void _onPanCancel() {
    if (!_isDragging) return;
    setState(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final nearestCorner = _calculateNearestCorner(
      offset: _dragOffset,
      offsets: _offsets,
    );
    setState(() {
      _corner = nearestCorner;
      _isDragging = false;
    });
    _dragAnimationController.forward().whenCompleteOrCancel(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating()) return;
    setState(() {
      _dragOffset = _offsets[_corner]!;
      _isDragging = true;
    });
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    callManager.onCallStateChange = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var windowPadding = mediaQuery.padding;
    windowPadding += mediaQuery.viewInsets;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        double floatingWidth = 120.0;
        double floatingHeight = height / width * floatingWidth;

        final floatingWidgetSize = Size(floatingWidth, floatingHeight);
        final fullWidgetSize = Size(width, height);

        _updateCornersOffsets(
          spaceSize: fullWidgetSize,
          widgetSize: floatingWidgetSize,
          windowPadding: windowPadding,
        );
        final calculatedOffset = _offsets[_corner];
        final widthRatio = floatingWidth / width;
        final heightRatio = floatingHeight / height;
        final scaledDownScale = widthRatio > heightRatio
            ? floatingWidgetSize.width / fullWidgetSize.width
            : floatingWidgetSize.height / fullWidgetSize.height;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([
                _toggleFloatingAnimationController,
                _dragAnimationController
              ]),
              builder: (context, child) {
                final animationCurve = CurveTween(curve: Curves.linearToEaseOut);
                final dragAnimationValue = animationCurve.transform(_dragAnimationController.value);
                final toggleFloatingAnimationValue = animationCurve.transform(_toggleFloatingAnimationController.value);
                final floatingOffset = _isDragging
                    ? _dragOffset
                    : Tween<Offset>(
                      begin: _dragOffset,
                      end: calculatedOffset,
                    ).transform(_dragAnimationController.isAnimating ? dragAnimationValue : toggleFloatingAnimationValue);
                final borderRadius = Tween<double>(
                  begin: 0,
                  end: 10
                ).transform(toggleFloatingAnimationValue);
                final width = Tween<double>(
                  begin: fullWidgetSize.width,
                  end: floatingWidgetSize.width
                ).transform(toggleFloatingAnimationValue);
                final height = Tween<double>(
                  begin: fullWidgetSize.height,
                  end: floatingWidgetSize.height,
                ).transform(toggleFloatingAnimationValue);
                final scale = Tween<double>(
                  begin: 1,
                  end: scaledDownScale,
                ).transform(toggleFloatingAnimationValue);
                return Positioned(
                  left: floatingOffset.dx,
                  top: floatingOffset.dy,
                  child: GestureDetector(
                    onPanStart: isFloating ? _onPanStart : null,
                    onPanUpdate: isFloating ? _onPanUpdate : null,
                    onPanCancel: isFloating ? _onPanCancel : null,
                    onPanEnd: isFloating ? _onPanEnd : null,
                    onTap: isFloating ? stopFloating : null,
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(borderRadius)
                        ),
                        width: width,
                        height: height,
                        child: Transform.scale(
                          scale: scale,
                          child: OverflowBox(
                            maxHeight: fullWidgetSize.height,
                            maxWidth: fullWidgetSize.width,
                            child: IgnorePointer(
                              ignoring: isFloating,
                              child: child,
                            ),
                          ),
                        )
                      ),
                    ),
                  ),
                );
              },
              child: Scaffold(
                body: SafeArea(
                  child: Material(
                    color: Colors.black,
                    child: !_connected ? _buildCallOutScreen() : _buildCallInScreen(),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
  Widget _buildCallOutScreen() {
    return Container(
      alignment: Alignment.center,
      child: isVideoEnable ? _buildWithLocalVideo() : _buildNonLocalVideo()
    );
  }

  Widget _buildCallInScreen () {
    return Stack(
      children: [
        _buildRemoteRenderer(),
        _buildLocalRenderer(),
        _buildBackButton(),
      ],
    );
  }
  Widget _buildListActionButtons() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            enableIcon: PhosphorIcons.videoCameraFill, 
            disableIcon: PhosphorIcons.videoCameraSlashFill,
            color: Colors.white, 
            defaultState: isVideoEnable,
            backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xff1890FF),
            onAction: (value) {
              setState(() {
                isVideoEnable = value;
                callManager.setEnableVideo(value);
              });
            },
          ),
          _buildActionButton(
            enableIcon: CupertinoIcons.camera_rotate_fill,
            disableIcon: CupertinoIcons.camera_rotate_fill,
            color: isDark ? Color(0xffEDEDED) : Color(0xffFFFFFF),
            backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffC9C9C9),
            onAction: (_) {
              callManager.toggleCamera();
            }
          ),
          
          _buildActionButton(
            enableIcon: PhosphorIcons.phoneDisconnectFill,
            disableIcon: PhosphorIcons.phoneDisconnectFill,
            color: Colors.white,
            backgroundColor: Color(0xffEB5757),
            onAction: (_) {
              SessionCallManager.sessionWithId(callManager.sessionId).abort();
            }
          ),

          _buildActionButton(
            enableIcon: PhosphorIcons.microphoneFill,
            disableIcon: PhosphorIcons.microphoneSlashFill,
            color: Colors.white,
            backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffC9C9C9),
            onAction: (value) {
              callManager.setEnableMic(value);
            }
          ),

          _buildActionButton(
            enableIcon: PhosphorIcons.speakerHighFill,
            disableIcon: PhosphorIcons.speakerSlashFill,
            color: Colors.white,
            backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffC9C9C9),
            onAction: (value) {
              callManager.toggleSpeakerPhone(value);
            }
          )
        ],
      ),
    );
  }
  ActionButton _buildActionButton({enableIcon, disableIcon, defaultState, color, backgroundColor, onAction}) {
    return ActionButton(
      enableIcon: enableIcon,
      disableIcon: disableIcon,
      defaultState: defaultState,
      color: color,
      backgroundColor: backgroundColor,
      onAction: onAction,
    );
  }

  Widget _buildNameAndTimer() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      children: [
        Container(width: 40, height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
        SizedBox(height: 10),
        Text(user["full_name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
        SizedBox(height: 5,),
        Text(timer.toString()),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBackButton() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Positioned(
      top: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: startFloating,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff5E5E5E) : Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(19)
                ),
                width: 38,
                height: 38,
                child: Icon(PhosphorIcons.arrowLeft),
              ),
            ),
            Container(
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteRenderer() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10),),
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
            ),
            padding: EdgeInsets.only(bottom: 30, top: 5),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                _buildNameAndTimer(),
                _buildListActionButtons()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalRenderer() {
    return Positioned(
      right: 20,
      top: 30,
      child: isVideoEnable ? Material(
        shadowColor: Colors.black,
        color: Colors.transparent,
        elevation: 10,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7)
          ),
          width: 120,
          height: 160,
          child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,),
        ),
      ) : Container(),
    );
  }
  Widget _buildNonLocalVideo() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 18,),
        Text(user["full_name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
        SizedBox(height: 4,),
        Text("Calling...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff1890FF))),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                  child: Lottie.network("https://assets8.lottiefiles.com/temp/lf20_PeIV5A.json"),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width/2 - 130/2,
                  left: MediaQuery.of(context).size.width/2 - 130/2,
                  child: Container(
                    child: CachedAvatar(
                      user["avatar_url"], 
                      name: user["full_name"], 
                      width: 130, height: 130
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildListActionButtons(),
        SizedBox(height: 24)
      ],
    );
  }
  Widget _buildWithLocalVideo() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
              Positioned(
                top: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: startFloating,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff5E5E5E) : Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(19)
                          ),
                          width: 38,
                          height: 38,
                          child: Icon(PhosphorIcons.arrowLeft),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10),),
              color: isDark ? Color(0xff2E2E2E) : Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 24),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(user["full_name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
              SizedBox(height: 6),
              Text("Calling...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff1890FF))),
              SizedBox(height: 16,),
              _buildListActionButtons()
            ],
          ),
        )
      ],
    );
  }
}

class TimerCounter{
  final interval = const Duration(seconds: 1);
  int currentSeconds = 0;
  Timer? _timer;
  Function? onChange;

  String get timerText =>
      '${(currentSeconds ~/ 60).toString().padLeft(2, '0')}: ${(currentSeconds % 60).toString().padLeft(2, '0')}';
  TimerCounter startTimeout([milliseconds]) {
    var duration = interval;
    _timer = Timer.periodic(duration, (timer) {
      currentSeconds = timer.tick;
      onChange?.call(timerText);
    });
    return this;
  }
  void destroy() {
    _timer?.cancel();
  }
}

Map<PIPViewCorner, Offset> _calculateOffsets({
  required Size spaceSize,
  required Size widgetSize,
  required EdgeInsets windowPadding,
}) {
  Offset getOffsetForCorner(PIPViewCorner corner) {
    final spacing = 16;
    final left = spacing + windowPadding.left;
    final top = spacing + windowPadding.top;
    final right =
        spaceSize.width - widgetSize.width - windowPadding.right - spacing;
    final bottom =
        spaceSize.height - widgetSize.height - windowPadding.bottom - spacing;

    switch (corner) {
      case PIPViewCorner.topLeft:
        return Offset(left, top);
      case PIPViewCorner.topRight:
        return Offset(right, top);
      case PIPViewCorner.bottomLeft:
        return Offset(left, bottom);
      case PIPViewCorner.bottomRight:
        return Offset(right, bottom);
      default:
        throw Exception('Not implemented.');
    }
  }

  final corners = PIPViewCorner.values;
  final Map<PIPViewCorner, Offset> offsets = {};
  for (final corner in corners) {
    offsets[corner] = getOffsetForCorner(corner);
  }

  return offsets;
}
void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

PIPViewCorner _calculateNearestCorner({
  required Offset offset,
  required Map<PIPViewCorner, Offset> offsets,
}) {
  _CornerDistance calculateDistance(PIPViewCorner corner) {
    final distance = offsets[corner]!
        .translate(
          -offset.dx,
          -offset.dy,
        )
        .distanceSquared;
    return _CornerDistance(
      corner: corner,
      distance: distance,
    );
  }

  final distances = PIPViewCorner.values.map(calculateDistance).toList();

  distances.sort((cd0, cd1) => cd0.distance.compareTo(cd1.distance));

  return distances.first.corner;
}

class _CornerDistance {
  final PIPViewCorner corner;
  final double distance;

  _CornerDistance({
    required this.corner,
    required this.distance,
  });
}

class ActionButton extends StatefulWidget {
  const ActionButton({ Key? key, this.enableIcon = Icons.abc, this.disableIcon = Icons.abc, this.color = Colors.black, this.backgroundColor = Colors.white, this.defaultState, required this.onAction }) : super(key: key);
  final IconData enableIcon;
  final IconData disableIcon;
  final Color color;
  final backgroundColor;
  final defaultState;
  final onAction;
  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _value = true;
  @override
  void initState() {
    if (widget.defaultState != null) _value = widget.defaultState;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(50),
      elevation: 10,
      child: InkWell(
        onTap: () {
          setState(() {
            _value = !_value;
            widget.onAction.call(_value);
          });
        },
        child: Container(
          margin: EdgeInsets.all(13),
          child: Icon(
            widget.defaultState != null ? widget.defaultState ? widget.enableIcon : widget.disableIcon :
            _value? widget.enableIcon : widget.disableIcon,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}