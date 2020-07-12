import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';

class ViewUserPage extends StatefulWidget {
  final User user;
  ViewUserPage(this.user);
  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text('View User data'),),
          SliverFillRemaining(
            child: Center(child: Text('View contact data for: ' + widget.user.forename),),
          ),
        ],
      ),
    );
  }
}