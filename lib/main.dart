import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautrig',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black,
        canvasColor: Colors.black54,
        cursorColor: Colors.white70,
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.white
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.white70
          ),
          hintStyle: TextStyle(
              color: Colors.white70
          ),
          counterStyle: TextStyle(
            color: Colors.white
          ),
          errorStyle: TextStyle(
              color: Colors.white70
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1
            )
          ),
          errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Colors.white70,
                  width: 1
              )
          ),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Colors.white70,
                  width: 1
              )
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(title: 'Beautrig'),
    );
  }

}