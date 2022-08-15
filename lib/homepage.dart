import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sketching_app/brushize_dialog.dart';
import 'package:sketching_app/draw_point.dart';
import 'package:sketching_app/sketch_canvas.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//List of points
  List<DrawPoint> _drawPoints = [];

// Color Picker
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  double _brushSize = 5;

//Screenshot
  Uint8List _imageFile;
  ScreenshotController screenshotController = ScreenshotController();

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void _changeBrushSize() async {
    double selectedSize = await showDialog(
        context: context,
        builder: (context) => BrushSize(
              initialSize: _brushSize,
            ));

    if (selectedSize != null) {
      _brushSize = selectedSize;
    }
  }

  void _showColorPicker() {
    showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (event) {
              setState(() {
                _drawPoints.add(DrawPoint(
                    position: event.localPosition,
                    paint: Paint()
                      ..color = currentColor
                      ..strokeWidth = _brushSize
                      ..strokeCap = StrokeCap.round));
              });
            },
            onPanUpdate: (event) {
              setState(() {
                _drawPoints.add(DrawPoint(
                    position: event.localPosition,
                    paint: Paint()
                      ..color = currentColor
                      ..strokeWidth = _brushSize
                      ..strokeCap = StrokeCap.round));
              });
            },
            onPanEnd: (event) {
              _drawPoints.add(null);
            },
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: SketchCanvas(
                    drawPoints: _drawPoints,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                margin: EdgeInsets.all(15.0),
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                decoration: BoxDecoration(
                    color: Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(50.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showColorPicker();
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: currentColor, shape: BoxShape.circle),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _changeBrushSize();
                      },
                      child: Text("Brush Size"),
                    ),
                    TextButton(
                        onPressed: () async {
                          var storagePermission =
                              await Permission.storage.request();
                          if (storagePermission.isGranted) {
                            screenshotController
                                .capture()
                                .then((Uint8List image) async {
                              //Capture Done
                              setState(() {
                                _imageFile = image;
                              });
                              print('Screenshot taken');
                              if (image != null) {
                                final result =
                                    await ImageGallerySaver.saveImage(
                                        Uint8List.fromList(image),
                                        quality: 60,
                                        name: "sketch_draw");
                                print("File: $result");
                                /*final directory = await getApplicationDocumentsDirectory();
                            final imagePath = await File('${directory.path}image.png').create();
                            // await imagePath.writeAsBytes(image);

                            /// Share Plugin
                            await Share.shareFiles([imagePath.path]);*/
                              }
                            }).catchError((onError) {
                              print(onError);
                            });
                          } else {
                            Permission.storage.request();
                          }
                        },
                        child: Text("Save")),
                    TextButton(
                        onPressed: () async {
                          screenshotController
                              .capture()
                              .then((Uint8List image) async {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final imagePath =
                                await File('${directory.path}/sketch_draw.jpg')
                                    .create();
                            await imagePath.writeAsBytes(image);
                            final share = await Share.shareFiles(
                                [imagePath.path],
                                text: "My art: ");
                          });
                        },
                        child: Text("Share")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _drawPoints.clear();
                          });
                        },
                        child: Text("Clear"))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
