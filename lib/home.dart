import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:Beautrig/curve_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {

  CurvePainter _painter;
  int _curveType = 2;
  int _numCurves = 20;
  double _heightFactor;
  double _gapFactor;
  double _pointRadius;
  bool _variablePointRadius;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _painter = _painter ?? CurvePainter(curveType: _curveType, numCurves: _numCurves);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black54,
        elevation: 0,
        leading: Icon(Icons.category, color: Colors.white,),
        actions: <Widget>[

          IconButton(
            icon: Icon(Icons.file_download, color: Colors.white,),
            onPressed: () { _checkPermissionAndSavePng(); },
          ),

          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: () { setState(() { _painter = null; }); },
          ),

          IconButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              onPressed: () { _openSettingsDialog(context); }
          )

        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        child: CustomPaint(
          painter: _painter,
          child: Container(),
        ),
      ),
    );
  }

  Future<void> _checkPermissionAndSavePng() async {
    if (await Permission.storage.request().isGranted) {
      log("_checkPermissionAndSavePng 1");
      _savePng();
    } else if (await Permission.storage.isPermanentlyDenied) {
      log("_checkPermissionAndSavePng 2");
      openAppSettings();
    } else {
      log("_checkPermissionAndSavePng 3");
      Fluttertoast.showToast(msg: "Storage permission denied",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
        textColor: Colors.white
      );
    }
  }
  
  Future<void> _savePng() async {
    if (_painter != null) {
      ByteData png = await _painter.getPng();
      if (png != null) {
        Directory dir = await getExternalStorageDirectory();
        if (dir != null) {
          log("_savePng 1");
          String fileName = (_curveType == 0 ? "sin" : _curveType == 1 ? "cos" : "tan") +
              _numCurves.toString() + "-" + DateTime.now().millisecondsSinceEpoch.toString() + ".png";

          String filepath = "${dir.path}/Beautrig-Images/$fileName";
          log("_savePng $filepath");
          try {
            (await File(filepath).create(recursive: true)).writeAsBytesSync(png.buffer.asInt8List());
            Fluttertoast.showToast(msg: "Image stored at $filepath",
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.black54,
              textColor: Colors.white
            );
          } catch (e) {
            print(e);
          }

        }
      }
    }
  }

  void _openSettingsDialog(BuildContext context) {

    showDialog(context: context,
      builder: (ctx) {
        int curveType = _curveType;
        return StatefulBuilder(
          builder: (ctx1, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: SimpleDialog(
                elevation: 0,
                title: Text("Settings"),
                backgroundColor: Colors.transparent,
                children: <Widget>[

                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16,),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.fromBorderSide(BorderSide(
                        color: Colors.white,
                      )),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          style: TextStyle(
                              color: Colors.white
                          ),
                          isExpanded: true,
                          iconEnabledColor: Colors.white,
                          value: curveType,
                          items: [

                            DropdownMenuItem(
                              child: Text("Sine"),
                              value: 0,
                            ),

                            DropdownMenuItem(
                              child: Text("Cosine"),
                              value: 1,
                            ),

                            DropdownMenuItem(
                              child: Text("Tangent"),
                              value: 2,
                            ),

                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              curveType = value;
                            });

                            setState(() {
                              _curveType = value;
                              _painter = null;
                            });
                          }
                      )
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextField(
                    decoration: InputDecoration(
                      labelText: "Number of curves",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    style: TextStyle(
                      color: Colors.white
                    ),
                    maxLength: 2,
                    maxLines: 1,
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  FlatButton(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    onPressed: () {},
                    child: Text("Reset to default",
                      style: TextStyle(
                        color: Colors.white
                      )
                    ),
                  ),

                ],
              ),
            );
          }
        );
      },
    );

  }
  
}