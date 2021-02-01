import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';

import 'camera_button.dart';

class FlashModeButton extends StatelessWidget {
  final ValueNotifier<CameraOrientations> orientation;
  final CameraFlashes tipo;
  final AnimationController iconAnimationController;
  final Function(CameraFlashes) onSet;

  const FlashModeButton({
    this.orientation,
    this.tipo,
    this.iconAnimationController,
    this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    return CameraButton(
      icon: _getFlashIcon(),
      color: Theme.of(context).primaryColor,
      rotationController: iconAnimationController,
      orientation: orientation,
      onTapCallback: () => _nextFlashMode(tipo),
    );
  }

  IconData _getFlashIcon() {
    switch (tipo) {
      case CameraFlashes.NONE:
        return Icons.flash_off;
      case CameraFlashes.ON:
        return Icons.flash_on;
      case CameraFlashes.AUTO:
        return Icons.flash_auto;
      case CameraFlashes.ALWAYS:
        return Icons.highlight;
      default:
        return Icons.flash_off;
    }
  }

  /// NONE -> ON -> ALWAYS -> NONE
  void _nextFlashMode(CameraFlashes tipo) {
    switch (tipo) {
      case CameraFlashes.NONE:
        onSet(CameraFlashes.ON);
        break;
      case CameraFlashes.ON:
        // onSet(CameraFlashes.AUTO);
        // break;
        // case CameraFlashes.AUTO:
        onSet(CameraFlashes.ALWAYS);
        break;
      case CameraFlashes.ALWAYS:
        onSet(CameraFlashes.NONE);
        break;
      default:
        onSet(CameraFlashes.NONE);
    }
  }
}
