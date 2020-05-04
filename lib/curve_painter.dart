import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurvePainter extends CustomPainter {

  static const myColors = [
    Colors.red, Colors.green, Colors.blue, Colors.yellow, 
    Colors.purple, Colors.amber, Colors.cyan, Colors.teal, 
    Colors.pink, Colors.orange,
  ];
  
  final int curveType;
  final int numCurves;
  final double heightFactor;
  final double gapFactor;
  final double pointRadius;
  final bool variablePointRadius;

  ui.Picture _picture;
  ui.Size _size;

  CurvePainter({this.curveType = 2, this.numCurves = 20, this.heightFactor = 15, 
      this.gapFactor = 7, this.pointRadius = 2, this.variablePointRadius = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (_picture == null) {
      var recorder = ui.PictureRecorder();
      _renderDrawing(Canvas(recorder), size);
      _picture = recorder.endRecording();
    }

    canvas.drawPicture(_picture);
    if (_size == null) {
      _size = size;
    }
  }

  void _renderDrawing(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Colors.black);

    _renderStructure(canvas, size, numCurves);
  }

  void _renderStructure(Canvas canvas, Size size, int iteration) {
    if (iteration < 1 ||
        heightFactor < 1 ||
        gapFactor < 1 ||
        curveType < 0 ||
        curveType > 2 ||
        pointRadius <= 0) {
      return;
    }

    Color c = myColors[Random().nextInt(myColors.length)];

    int num = size.width.round();
    for (int i = 0; i < num; i++) {
      
      double x = i - num / 2.0;
      double theta = x / (gapFactor * (numCurves - iteration + 1));

      double trigValue;
      double radiusFactor;

      switch (curveType) {
        case 0:
          trigValue = sin(theta);
          radiusFactor = trigValue.abs() + 0.5;
          break;

        case 1:
          trigValue = cos(theta);
          radiusFactor = trigValue.abs() + 0.5;
          break;

        default:
          trigValue = tan(theta);
          radiusFactor = sin(theta).abs() + 0.5;
          break;
      }
      
      double radius = variablePointRadius ? pointRadius * radiusFactor : pointRadius;

      canvas.drawCircle(Offset(
          (size.width / 2) + x,
          (size.height / 2) + ((heightFactor * (numCurves - iteration + 1)) * trigValue)),
          radius, Paint()..color = c);
    }

    _renderStructure(canvas, size, iteration - 1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  Future<ByteData> getPng() async {
    ui.Image image;
    if (_picture == null || _size == null) {
      image = null;
      dev.log("getPng 1");
    } else {
      image = await _picture.toImage(_size.width.floor(), _size.height.floor());
      dev.log("getPng 2");
    }

    if (image == null) {
      dev.log("getPng 3");
      return null;
    } else {
      dev.log("getPng 4");
      return await image.toByteData(format: ui.ImageByteFormat.png);
    }
  }
}
