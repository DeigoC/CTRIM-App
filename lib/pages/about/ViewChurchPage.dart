import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:flutter/material.dart';

class ViewChurchPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewChurchPage(this._aboutArticle);
  @override
  _ViewChurchPageState createState() => _ViewChurchPageState();
}

class _ViewChurchPageState extends State<ViewChurchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Church'),),
      body: Center(child: Text('Text'),),
    );
  }
}