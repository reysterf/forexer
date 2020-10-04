import 'package:flutter/material.dart';
import 'package:forexer/loading_screen.dart';
import 'converter_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      title: 'Flutter Demo',
      home: LoadingScreen(),
    );
  }
}

