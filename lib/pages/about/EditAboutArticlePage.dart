import 'package:flutter/material.dart';

class EditAboutArticlePage extends StatefulWidget {
  @override
  _EditAboutArticlePageState createState() => _EditAboutArticlePageState();
}

class _EditAboutArticlePageState extends State<EditAboutArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit About Article'),),
    );
  }
}