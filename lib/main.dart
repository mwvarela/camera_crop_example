import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'camera/camera_vistoria.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Photo {
  String title;
  File photo;

  Photo({this.title, this.photo});
}

class _MyHomePageState extends State<MyHomePage> {
  List<Photo> listPhoto = [
    Photo(title: 'Photo 1'),
    Photo(title: 'Photo 2'),
    Photo(title: 'Photo 3'),
    Photo(title: 'Photo 4'),
    Photo(title: 'Photo 5'),
    Photo(title: 'Photo 6'),
    Photo(title: 'Photo 7'),
    Photo(title: 'Photo 8'),
    Photo(title: 'Photo 9'),
    Photo(title: 'Photo 11'),
    Photo(title: 'Photo 12'),
    Photo(title: 'Photo 13'),
    Photo(title: 'Photo 14'),
    Photo(title: 'Photo 15'),
    Photo(title: 'Photo 16'),
    Photo(title: 'Photo 17'),
    Photo(title: 'Photo 18'),
    Photo(title: 'Photo 19'),
    Photo(title: 'Photo 20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: listPhoto.length,
        itemBuilder: (BuildContext context, int index) {
          final test = listPhoto[index];
          return ListTile(
            leading: test.photo != null ? Image.file(test.photo) : null,
            title: Text(test.title),
            trailing: IconButton(
              onPressed: () async {
                final photo = await takeFoto(context);
                final cropPhoto = await cropImage(context, photo.path);
                setState(() {
                  test.photo = cropPhoto;
                });
              },
              icon: Icon(Icons.camera),
            ),
          );
        },
      ),
    );
  }

  Future<File> takeFoto(BuildContext ctx) async {
    final foto = await showDialog(
      context: ctx,
      builder: (_) => CameraVistoria(useZoomGesture: false, titulo: 'Title'),
    );
    return foto;
  }

  Future<File> cropImage(BuildContext context, String imgPath) async {
    final imgCortada = await ImageCropper.cropImage(
      maxWidth: 1200,
      maxHeight: 900,
      sourcePath: imgPath,
      aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
      aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
      compressQuality: 90,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Ajuste no formato 4x3',
        toolbarColor: Theme.of(context).primaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.ratio4x3,
        lockAspectRatio: true,
        showCropGrid: false,
      ),
    );
    return imgCortada;
  }
}
