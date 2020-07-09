import 'dart:convert';

import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class AboutBodyEditorPage extends StatefulWidget {
  @override
  _AboutBodyEditorPageState createState() => _AboutBodyEditorPageState();
}

class _AboutBodyEditorPageState extends State<AboutBodyEditorPage> {
  
  ZefyrController _textController;
  FocusNode _fnEditor;
  
  @override
  void initState() {
    _textController = ZefyrController(BlocProvider.of<AboutBloc>(context).getAboutBody());
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
        BlocProvider.of<AboutBloc>(context).add(AboutArticleSaveBodyEvent(contents));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit About Article Body'),
        ),
        body: ZefyrScaffold(
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