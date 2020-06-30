import 'package:flutter/material.dart';

void main() {
  runApp(DiveApp());
}

class DiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dive home page'),
        ),
        body: Center(
          child: Text('Welcome to Dive'),
        ),
      ),
    );
  }
}
