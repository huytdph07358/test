import 'package:flutter/material.dart';
import 'dart:core';

const double bleedWidth = 20;

enum RevealSide { left, right, main }

class Overlapping extends StatefulWidget {
  final Widget? left;
  final Widget main;
  final Widget? right;
  final double restWidth;
  final ValueChanged<RevealSide>? onSideChange;

  const Overlapping({this.left,
    required this.main,
    this.right,
    this.restWidth = 80,
    this.onSideChange,
    Key? key})
      : super(key: key);

  static OverlappingState? of(BuildContext context) {
    return context.findAncestorStateOfType<OverlappingState>();
  }

  @override
  State<StatefulWidget> createState() {
    return OverlappingState();
  }
}

class OverlappingState extends State<Overlapping>
    with TickerProviderStateMixin {
  AnimationController? controller;
  double translate = 0;

  double _calculateGoal(double width, int multiplier) {
    return (multiplier * width) + (-multiplier * widget.restWidth );
  }
  double _calculateGoal1(double width, int multiplier) {
    return (multiplier * width) + (-multiplier * 0 );
  }

  get onApplyTranslation => this._onApplyTranslation;

  void _onApplyTranslation() {
    final mediaWidth = MediaQuery
        .of(context)
        .size
        .width;

    final animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onSideChange != null) {
          widget.onSideChange!(translate == 0
              ? RevealSide.main
              : (translate > 0 ? RevealSide.left : RevealSide.right));
        }
        animationController.dispose();
      }
    });

    if (translate.abs() >= mediaWidth / 2) {
      final multiplier = (translate > 0 ? 1 : -1);
      final goal = translate > 0 ? _calculateGoal(mediaWidth, multiplier) : _calculateGoal1(mediaWidth, multiplier);
      final Tween<double> tween = Tween(begin: translate, end: goal);

      final animation = tween.animate(animationController);

      animation.addListener(() {
        setState(() {
          translate = animation.value;
        });
      });
    } else {
      final animation =
      Tween<double>(begin: translate, end: 0).animate(animationController);

      animation.addListener(() {
        setState(() {
          translate = animation.value;
        });
      });
    }

    animationController.forward();
  }

  void reveal(RevealSide direction) {
    // can only reveal when showing main
    if (translate != 0) {
      return;
    }

    final mediaWidth = MediaQuery
        .of(context)
        .size
        .width;

    final multiplier = (direction == RevealSide.left ? 1 : -1);
    final goal = _calculateGoal(mediaWidth, multiplier);

    final animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onApplyTranslation();
        animationController.dispose();
      }
    });

    final animation =
    Tween<double>(begin: translate, end: goal).animate(animationController);

    animation.addListener(() {
      setState(() {
        translate = animation.value;
      });
    });

    animationController.forward();
  }

  void onTranslate(double delta) {
    setState(() {
      final translate = this.translate + delta;
      if (translate < 0 && widget.right != null ||
          translate > 0 && widget.left != null) {
        this.translate = translate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Offstage(
        offstage: translate < 0,
        child: widget.left,
      ),
      Offstage(
        offstage: translate > 0,
        child: widget.right,
      ),
      Transform.translate(
        offset: Offset(translate, 0),
        child: widget.main
      ),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          onTranslate(details.delta.dx);
        },
        onHorizontalDragStart: translate > 0 ? (details){
          if (details.globalPosition.dx > translate) {
            translate = 0;
            onApplyTranslation();
          }
        } : null,
        onHorizontalDragEnd: (details) {
          // _onApplyTranslation();
        },
      ) 
    ]);
  }
}