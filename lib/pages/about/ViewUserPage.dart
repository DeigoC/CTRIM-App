import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';

class ViewUserPage extends StatefulWidget {
  final User _user;
  ViewUserPage(this._user);
  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View User: ' + widget._user.forename),),
    );
  }
}