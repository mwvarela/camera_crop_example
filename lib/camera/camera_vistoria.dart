import 'dart:io';

import 'package:flutter/material.dart';

import 'components/camera_screen.dart';

class CameraVistoria extends StatelessWidget {
  final String titulo;
  final bool useZoomGesture;
  final Function(File image) onFile;
  const CameraVistoria({
    Key key,
    this.onFile,
    this.titulo,
    this.useZoomGesture = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      bottom: false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(titulo ?? 'Câmera', overflow: TextOverflow.ellipsis),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop<File>(context),
            ),
          ),
          backgroundColor: Colors.black,
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: CameraScreen(
              useZoomGesture: useZoomGesture,
              onFile: (file) {
                if (onFile != null) {
                  onFile(file);
                } else {
                  Navigator.pop<File>(context, file);
                }
              },
            ),
          )),
    );
  }
}
