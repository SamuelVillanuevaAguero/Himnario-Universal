import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';  // En lugar de himnario_home_page.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himnario Universal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}