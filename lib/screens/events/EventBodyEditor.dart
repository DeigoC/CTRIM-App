import 'dart:convert';
import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class EventBodyEditor extends StatefulWidget {
  final EventBloc _eventBloc;
  EventBodyEditor(this._eventBloc);
  
  @override
  _EventBodyEditorState createState() => _EventBodyEditorState();
}

class _EventBodyEditorState extends State<EventBodyEditor> {
  
  ZefyrController _textController;
  FocusNode _fnEditor;

  @override
  void initState() {
    super.initState();
    _textController = ZefyrController(widget._eventBloc.getEditorDoc());
    _fnEditor = FocusNode();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page for Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              _saveDocument();
            },
          )
        ],
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

  void _saveDocument(){
    String contents = jsonEncode(_textController.document);
    widget._eventBloc.eventBodyContent = contents;
    widget._eventBloc.add(SaveNewBodyDocumentEvent());
    print('--------------CONTENT LOOKS LIKE:\n' + contents);
  }
}