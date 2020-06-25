import 'package:flutter/material.dart';

class MyDetailsPage extends StatefulWidget {
  @override
  _MyDetailsPageState createState() => _MyDetailsPageState();
}

class _MyDetailsPageState extends State<MyDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View my data'),),
      body: Center(child: Text('Body stuff'),),
    );
  }
}