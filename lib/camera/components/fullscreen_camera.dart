import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:camerawesome/sensors.dart';
import 'package:flutter/material.dart';

class FullscreenCamera extends StatelessWidget {
  final Function(bool) onPermissionsResult;
  final Function(CameraOrientations) onOrientationChange;
  final ValueNotifier<Size> photoSize;
  final ValueNotifier<CameraFlashes> flashMode;
  final ValueNotifier<double> zoom;

  const FullscreenCamera({
    Key key,
    @required this.photoSize,
    this.onPermissionsResult,
    this.onOrientationChange,
    this.flashMode,
    this.zoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CameraAwesome(
        onPermissionsResult: onPermissionsResult,
        selectDefaultSize: (availableSizes) {
          // TODO salvar o tamanho da camera no login?
          return _getMaiorTamanho4por3(availableSizes);
        },
        photoSize: photoSize,
        sensor: ValueNotifier(Sensors.BACK),
        switchFlashMode: flashMode,
        zoom: zoom,
        onOrientationChanged: onOrientationChange,
        // onCameraStarted: () {
        //   print('onCameraStarted full');
        // },
      ),
    );
  }

  Size _getMaiorTamanho4por3(List<Size> availableSizes) {
    var tamanhos = availableSizes.where((size) => size.width < 2000).toList();
    tamanhos.sort((a, b) => b.width.compareTo(a.width));
    final tamanho =
        tamanhos.firstWhere((size) => ((3 * size.width) / size.height) == 4);
    debugPrint('availableSizes[] => $tamanho entre $tamanhos');
    return tamanho;
  }
}
