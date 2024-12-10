import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health_management/Service/BMIService.dart';
import 'package:health_management/Service/UserService.dart';
import 'package:health_management/di.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';
import 'package:intl/intl.dart';  
import 'BMICalculator.dart';
import 'package:provider/provider.dart';


void main() {
  setupDI();
  initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserService()),
        ChangeNotifierProvider(create: (context) => BMIService()),
      ],
      child: const MyApp(),
    ),
  );
}


void initialize() {
  
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/signup': (context) => SignupPage(),
        '/home': (context) => BMICalculator(),
        '/login': (context) => LoginPage(),
        
      }
    );
  }
}



