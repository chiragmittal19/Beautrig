import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:Beautrig/curve_painter.dart';
import 'package:flutter/foundation.dart';
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
  
  static const int CURVE_TYPE = 0;
  static const int NUM_CURVES = 20;
  static const double HEIGHT_FACTOR = 15.0;
  static const double GAP_FACTOR = 7.0;
  static const double POINT_RADIUS = 2.0;
  static const bool VARIABLE_POINT_RADIUS = false;

  CurvePainter _painter;
  int _curveType = CURVE_TYPE;
  int _numCurves = NUM_CURVES;
  double _heightFactor = HEIGHT_FACTOR;
  double _gapFactor = GAP_FACTOR;
  double _pointRadius = POINT_RADIUS;
  bool _variablePointRadius = VARIABLE_POINT_RADIUS;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _painter = _painter ?? CurvePainter(
        curveType: _curveType,
        numCurves: _numCurves,
        heightFactor: _heightFactor,
        gapFactor: _gapFactor,
        pointRadius: _pointRadius,
        variablePointRadius: _variablePointRadius,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black54,
        elevation: 0,
        leading: Icon(Icons.category, color: Colors.white,),
        actions: <Widget>[

          if (!kIsWeb) IconButton(
            icon: Icon(Icons.file_download, color: Colors.white,),
            onPressed: () { _checkPermissionAndSavePng(); },
          ),

          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: () { setState(() { _painter = null; }); },
          ),

          IconButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              onPressed: _openSettingsDialog,
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
      _savePng();
    } else if (await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
    } else {
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

  void _openSettingsDialog() {

    showDialog(context: context,
      builder: (ctx) {
      
        int curveType = _curveType;
        bool variablePointRadius = _variablePointRadius;
        
        TextEditingController numCurvesController = TextEditingController(text: _numCurves.toString());
        bool numCurvesValid = true;

        TextEditingController heightFactorController = TextEditingController(text: _heightFactor.toString());
        bool heightFactorValid = true;

        TextEditingController gapFactorController = TextEditingController(text: _gapFactor.toString());
        bool gapFactorValid = true;

        TextEditingController pointRadiusController = TextEditingController(text: _pointRadius.toString());
        bool pointRadiusValid = true;
        
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
                      errorText: numCurvesValid ? null : "Please enter a number between 1 and 100",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'[1-9]\d*'))
                    ],
                    style: TextStyle(
                      color: Colors.white
                    ),
                    maxLines: 1,
                    controller: numCurvesController,
                    onChanged: (value) {
                      
                      if (value == null || value.trim().isEmpty) {
                        setDialogState(() {
                          numCurvesValid = false;
                        });
                        return;
                      }
                      
                      int n = int.tryParse(value);

                      if (n == null || n > 100 || n < 1) {
                        setDialogState(() {
                          numCurvesValid = false;
                        });
                        return;
                      }

                      setDialogState(() {
                        numCurvesValid = true;
                      });

                      setState(() {
                        _numCurves = n;
                        _painter = null;
                      });
                      
                    },
                  ),
  
                  SizedBox(
                    height: 20,
                  ),
  
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Height factor",
                      errorText: heightFactorValid ? null : "Please enter a number between 1 and 150",
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'[1-9]\d*(\.\d{0,3})?'))
                    ],
                    style: TextStyle(
                        color: Colors.white
                    ),
                    maxLines: 1,
                    controller: heightFactorController,
                    onChanged: (value) {
      
                      if (value == null || value.trim().isEmpty) {
                        setDialogState(() {
                          heightFactorValid = false;
                        });
                        return;
                      }

                      double n = double.tryParse(value);
      
                      if (n == null || n > 150 || n < 1) {
                        setDialogState(() {
                          heightFactorValid = false;
                        });
                        return;
                      }

                      setDialogState(() {
                        heightFactorValid = true;
                      });
      
                      setState(() {
                        _heightFactor = n;
                        _painter = null;
                      });
      
                    },
                  ),
  
                  SizedBox(
                    height: 20,
                  ),
  
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Gap factor",
                      errorText: gapFactorValid ? null : "Please enter a number between 1 and 50",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'[1-9]\d*(\.\d{0,3})?'))
                    ],
                    style: TextStyle(
                        color: Colors.white
                    ),
                    maxLines: 1,
                    controller: gapFactorController,
                    onChanged: (value) {
      
                      if (value == null || value.trim().isEmpty) {
                        setDialogState(() {
                          gapFactorValid = false;
                        });
                        return;
                      }
      
                      double n = double.tryParse(value);
      
                      if (n == null || n > 50 || n < 1) {
                        setDialogState(() {
                          gapFactorValid = false;
                        });
                        return;
                      }
      
                      setDialogState(() {
                        gapFactorValid = true;
                      });
      
                      setState(() {
                        _gapFactor = n;
                        _painter = null;
                      });
      
                    },
                  ),
  
                  SizedBox(
                    height: 20,
                  ),
  
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Line width",
                      errorText: pointRadiusValid ? null : "Please enter a number between 0+ and 50",
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'\d*(\.\d{1,3})|\d+(\.\d{0,3})?'))
                    ],
                    style: TextStyle(
                        color: Colors.white
                    ),
                    maxLines: 1,
                    controller: pointRadiusController,
                    onChanged: (value) {
      
                      if (value == null || value.trim().isEmpty) {
                        setDialogState(() {
                          pointRadiusValid = false;
                        });
                        return;
                      }
      
                      double n = double.tryParse(value);
      
                      if (n == null || n > 50 || n <= 0) {
                        setDialogState(() {
                          pointRadiusValid = false;
                        });
                        return;
                      }
      
                      setDialogState(() {
                        pointRadiusValid = true;
                      });
      
                      setState(() {
                        _pointRadius = n;
                        _painter = null;
                      });
      
                    },
                  ),

                  SizedBox(
                    height: 20,
                  ),
  
                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16,),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.fromBorderSide(BorderSide(
                        color: Colors.white,
                      )),
                    ),
                    child: Row(
                      children: [
                        
                        Expanded(
                            child: Text("Variable line width",
                                style: TextStyle(
                                    color: Colors.white
                                )
                            )
                        ),
  
                        Switch(
                            value: variablePointRadius,
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            inactiveThumbColor: Colors.white30,
                            onChanged: (value) {
                              setDialogState(() {
                                variablePointRadius = value;
                              });
        
                              setState(() {
                                _variablePointRadius = value;
                                _painter = null;
                              });
                            }
                        ),
                        
                      ],
                    ),
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
                    onPressed: () {
                      setDialogState(() {
                        curveType = CURVE_TYPE;
                        numCurvesController.text = NUM_CURVES.toString();
                        heightFactorController.text = HEIGHT_FACTOR.toString();
                        gapFactorController.text = GAP_FACTOR.toString();
                        pointRadiusController.text = POINT_RADIUS.toString();
                        variablePointRadius = VARIABLE_POINT_RADIUS;

                        numCurvesValid = true;
                        heightFactorValid = true;
                        gapFactorValid = true;
                        pointRadiusValid = true;
                      });
  
                      setState(() {
                        _curveType = CURVE_TYPE;
                        _numCurves = NUM_CURVES;
                        _heightFactor = HEIGHT_FACTOR;
                        _gapFactor = GAP_FACTOR;
                        _pointRadius = POINT_RADIUS;
                        _variablePointRadius = VARIABLE_POINT_RADIUS;
                        _painter = null;
                      });
                    },
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