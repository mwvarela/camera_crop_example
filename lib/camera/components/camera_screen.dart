import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_level.dart';
import 'camera_button.dart';
import 'flash_mode_button.dart';
import 'fullscreen_camera.dart';
import 'take_photo_button.dart';

class CameraScreen extends StatefulWidget {
  final bool useZoomGesture;
  final Function(File) onFile;
  const CameraScreen({
    @required this.onFile,
    this.useZoomGesture,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraLevel _zoomLevel = CameraLevel();
  double _initialZoomDragLevel = 0;
  ValueNotifier<Size> _photoSizeNotifier = ValueNotifier(null);
  ValueNotifier<CameraFlashes> _tipoFlashNotifier =
      ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<CameraOrientations> _orientation =
      ValueNotifier(CameraOrientations.PORTRAIT_UP);

  AnimationController _iconsAnimationController;

  bool _salvandoFoto = false;

  @override
  void initState() {
    super.initState();

    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tipoFlashNotifier.dispose();
    _orientation.dispose();
    _zoomLevel.dispose();

    _iconsAnimationController.dispose();
    _photoSizeNotifier.dispose();
    super.dispose();
  }

  void _tirarFoto() async {
    final Directory dir = await getTemporaryDirectory();
    String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${dir.path}/$filename';
    setState(() => _salvandoFoto = true);

    File file;
    try {
      print('==> Foto salva em : $filePath');
      await PictureController().takePicture(filePath);
      file = File(filePath);
    } on PlatformException catch (error, stacktrace) {
      print('Problema ao tirar a foto: $error');
      print('==> code: ${error?.code}');
      print('==> details: ${error?.details}');
      print('==> message: ${error?.message}');
      print('==> stacktrace: ${error?.stacktrace}');
      print('$stacktrace');
    } catch (e, stacktrace) {
      print('problema ao tirar a foto: $e');
      print('$stacktrace');
    } finally {
      setState(() => _salvandoFoto = false);
    }

    if (file != null) {
      HapticFeedback.mediumImpact();
      widget.onFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onDoubleTap: _salvandoFoto ? null : _tirarFoto,
            onScaleStart: widget.useZoomGesture
                ? (_) {
                    setState(() =>
                        _initialZoomDragLevel = _zoomLevel.notifier.value + 1);
                  }
                : null,
            onScaleUpdate: widget.useZoomGesture
                ? (details) {
                    double value = _initialZoomDragLevel * details.scale - 1;
                    if (0 < value && value < 1) {
                      _zoomLevel.notifier.value = value;
                    }
                  }
                : null,
            child: FullscreenCamera(
              photoSize: _photoSizeNotifier,
              flashMode: _tipoFlashNotifier,
              zoom: _zoomLevel.notifier,
              onOrientationChange: _onOrientationChange,
              onPermissionsResult: _onPermissionsResult,
            ),
          ),
        ),
        SafeArea(
          child: _salvandoFoto
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: <Widget>[
                    _buildTopBar(),
                    _buildBottomBar(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  _zoomLevel.level > 0
                      ? 'Zoom: ${_zoomLevel.level}x'
                      : 'Sem zoom',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              FlashModeButton(
                iconAnimationController: _iconsAnimationController,
                orientation: _orientation,
                tipo: _tipoFlashNotifier.value,
                onSet: (tipo) {
                  _tipoFlashNotifier.value = tipo;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CameraButton(
              icon: Icons.zoom_out,
              color: Theme.of(context).primaryColor,
              rotationController: _iconsAnimationController,
              orientation: _orientation,
              onTapCallback: _zoomLevel.podeDiminuir
                  ? () {
                      _zoomLevel.diminuir();
                      setState(() {});
                    }
                  : null,
            ),
            TakePhotoButton(
              key: ValueKey("takePhotoButton"),
              onTap: _tirarFoto,
            ),
            CameraButton(
              icon: Icons.zoom_in,
              color: Theme.of(context).primaryColor,
              rotationController: _iconsAnimationController,
              orientation: _orientation,
              onTapCallback: _zoomLevel.podeAumentar
                  ? () {
                      _zoomLevel.aumentar();
                      setState(() {});
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  _onPermissionsResult(bool granted) {
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Atenção!'),
        content: Text(
            'As permissões necessárias para o funcionamento da câmera não foram autorizadas.\n\n' +
                'Por favor verifique as configurações e tente novamente.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print('permissoes da camera foram aceitas');
    }
  }

  _onOrientationChange(CameraOrientations newOrientation) {
    _orientation.value = newOrientation;
  }
}
