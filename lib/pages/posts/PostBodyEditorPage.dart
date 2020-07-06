import 'dart:convert';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class EventBodyEditor extends StatefulWidget {
  final PostBloc _postBloc;
  EventBodyEditor(this._postBloc);
  @override
  _EventBodyEditorState createState() => _EventBodyEditorState();
}

class _EventBodyEditorState extends State<EventBodyEditor> {
 
  ZefyrController _textController;
  FocusNode _fnEditor;

  @override
  void initState() {
    super.initState();
    _textController = ZefyrController(widget._postBloc.getEditorDoc());
    _fnEditor = FocusNode();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page for Editor'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
             String contents = jsonEncode(_textController.document);
              widget._postBloc.add(PostSaveBodyDocumentEvent(contents));
              Navigator.pop(context);
          },
        ),
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          mode: ZefyrMode.edit,
          controller: _textController,
          focusNode: _fnEditor,
          padding: EdgeInsets.all(8),
        ),
      ),
    );
  }
}