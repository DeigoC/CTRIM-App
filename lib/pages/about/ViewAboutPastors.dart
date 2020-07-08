import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:flutter/material.dart';

class ViewAboutPastorPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewAboutPastorPage(this._aboutArticle);
  @override
  _ViewAboutPastorPageState createState() => _ViewAboutPastorPageState();
}

class _ViewAboutPastorPageState extends State<ViewAboutPastorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Pastors'),),
    );
  }
}