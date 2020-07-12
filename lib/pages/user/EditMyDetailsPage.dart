import 'package:flutter/material.dart';

class EditMyDetailsPage extends StatefulWidget {
  @override
  _EditMyDetailsPageState createState() => _EditMyDetailsPageState();
}

class _EditMyDetailsPageState extends State<EditMyDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit my data'),),
      body: Center(child: Text('Body stuff'),),
    );
  }
}