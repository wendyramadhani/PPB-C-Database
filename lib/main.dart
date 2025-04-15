import 'package:expense_tracker/login.dart';
import 'package:expense_tracker/register.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(), // bisa Login atau halaman lain
    );
  }
}
