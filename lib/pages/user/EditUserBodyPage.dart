import 'dart:convert';

import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class EditUserBodyPage extends StatefulWidget {
  final User user;
  EditUserBodyPage(this.user);
  @override
  _EditUserBodyPageState createState() => _EditUserBodyPageState();
}

class _EditUserBodyPageState extends State<EditUserBodyPage> {
  
  ZefyrController _textController;
  FocusNode _fnEditor;

  @override
  void initState() {
    _textController = ZefyrController(widget.user.getBodyDoc());
    _fnEditor = FocusNode();
    super.initState();
  }

  @override
  void dispose() { 
    _textController.dispose();
    _fnEditor.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        String contents = jsonEncode(_textController.document);
        widget.user.body = contents;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit About Pastor Body'),),
        body:  ZefyrScaffold(
          child: ZefyrEditor(
            mode: ZefyrMode.edit,
            controller: _textController,
            focusNode: _fnEditor,
            padding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }
}