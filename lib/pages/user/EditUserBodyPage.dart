import 'dart:convert';

import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class EditUserBodyPage extends StatefulWidget {
  final AdminBloc _adminBloc;
  EditUserBodyPage(this._adminBloc);

  @override
  _EditUserBodyPageState createState() => _EditUserBodyPageState();
}

class _EditUserBodyPageState extends State<EditUserBodyPage> {
  
  ZefyrController _textController;
  FocusNode _fnEditor;

  @override
  void initState() {
    _textController = ZefyrController(widget._adminBloc.selectedUser.getBodyDoc());
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
        widget._adminBloc.add(AdminBodyChangedEvent(contents));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit Text'),),
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