import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';

class CameraSimples extends StatelessWidget {
  final Function(File) onFile;
  const CameraSimples({
    this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    return Camera(
      mode: CameraMode.normal,
      initialCamera: CameraSide.back,
      enableCameraChange: false,
      onFile: (file) {
        if (onFile != null) {
          onFile(file);
        } else {
          Navigator.pop<File>(context, file);
        }
      },
    );
  }
}
