import 'dart:math';

import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraButton extends StatefulWidget {
  final IconData icon;
  final Function onTapCallback;
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;
  final Color color;
  final Color textColor;
  const CameraButton({
    Key key,
    @required this.icon,
    this.onTapCallback,
    this.rotationController,
    this.orientation,
    this.color,
    this.textColor,
  }) : super(key: key);

  bool get isDisabled => onTapCallback == null;
  bool get hasRotation => orientation != null && rotationController != null;

  @override
  _CameraButtonState createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  double _angle = 0.0;
  CameraOrientations _oldOrientation = CameraOrientations.PORTRAIT_UP;

  @override
  void initState() {
    super.initState();

    if (widget.hasRotation) {
      _initRotation();
    }
  }

  void _initRotation() {
    Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.ease))
        .animate(widget.rotationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _oldOrientation =
                  OrientationUtils.convertRadianToOrientation(_angle);
            }
          });

    widget.orientation.addListener(() {
      _angle =
          OrientationUtils.convertOrientationToRadian(widget.orientation.value);

      if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
        widget.rotationController.reverse();
      } else if (_oldOrientation == CameraOrientations.LANDSCAPE_LEFT ||
          _oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
        widget.rotationController.reset();

        if ((widget.orientation.value == CameraOrientations.LANDSCAPE_LEFT ||
            widget.orientation.value == CameraOrientations.LANDSCAPE_RIGHT)) {
          widget.rotationController.forward();
        } else if ((widget.orientation.value ==
            CameraOrientations.PORTRAIT_DOWN)) {
          if (_oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
            widget.rotationController.forward(from: 0.5);
          } else {
            widget.rotationController.reverse(from: 0.5);
          }
        }
      } else if (widget.orientation.value == CameraOrientations.PORTRAIT_DOWN) {
        widget.rotationController.reverse(from: 0.5);
      } else {
        widget.rotationController.forward();
      }
    });
  }

  double _calcNewAngle() {
    double newAngle;

    if (_oldOrientation == CameraOrientations.LANDSCAPE_LEFT) {
      if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
        newAngle = -widget.rotationController.value;
      }
    }

    if (_oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
      if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
        newAngle = widget.rotationController.value;
      }
    }

    if (_oldOrientation == CameraOrientations.PORTRAIT_DOWN) {
      if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
        newAngle = widget.rotationController.value * -pi;
      }
    }
    return newAngle;
  }

  @override
  Widget build(BuildContext context) {
    var button = ClipOval(
      child: Material(
        color:
            widget.isDisabled ? Colors.grey : widget.color ?? Color(0xFF4F6AFF),
        child: InkWell(
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              widget.icon,
              color: widget.textColor ?? Colors.white,
              size: 24.0,
            ),
          ),
          onTap: widget.isDisabled
              ? null
              : () {
                  // Trigger short vibration
                  HapticFeedback.selectionClick();

                  widget.onTapCallback();
                },
        ),
      ),
    );

    return widget.hasRotation
        ? AnimatedBuilder(
            animation: widget.rotationController,
            builder: (context, child) {
              double newAngle = _calcNewAngle();

              return Transform.rotate(
                angle: newAngle ?? widget.rotationController.value * _angle,
                child: button,
              );
            },
          )
        : button;
  }
}

class OrientationUtils {
  static CameraOrientations convertRadianToOrientation(double radians) {
    CameraOrientations orientation;
    if (radians == -pi / 2) {
      orientation = CameraOrientations.LANDSCAPE_LEFT;
    } else if (radians == pi / 2) {
      orientation = CameraOrientations.LANDSCAPE_RIGHT;
    } else if (radians == 0.0) {
      orientation = CameraOrientations.PORTRAIT_UP;
    } else if (radians == pi) {
      orientation = CameraOrientations.PORTRAIT_DOWN;
    }
    return orientation;
  }

  static double convertOrientationToRadian(CameraOrientations orientation) {
    double radians;
    switch (orientation) {
      case CameraOrientations.LANDSCAPE_LEFT:
        radians = -pi / 2;
        break;
      case CameraOrientations.LANDSCAPE_RIGHT:
        radians = pi / 2;
        break;
      case CameraOrientations.PORTRAIT_UP:
        radians = 0.0;
        break;
      case CameraOrientations.PORTRAIT_DOWN:
        radians = pi;
        break;
      default:
    }
    return radians;
  }
}
