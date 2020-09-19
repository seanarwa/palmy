import 'package:flutter/material.dart';
import 'package:palmy/pages/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palmy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => HomePage(),
        '/login': (BuildContext context) => LoginPage(),
        '/capture': (BuildContext context) => CapturePage(),
      }
    );
  }
}
