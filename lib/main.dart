import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For formatting date and time
import 'BMICalculator.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Management System',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const BMICalculator(),
    );
  }
}



