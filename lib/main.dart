import 'package:dive/auth.dart';
import 'package:dive/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DiveApp());
}

class DiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: new RootPage(auth: new Auth(FirebaseAuth.instance)),
    );
  }
}
