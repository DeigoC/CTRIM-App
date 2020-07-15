import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class ViewAboutPastorPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewAboutPastorPage(this._aboutArticle);
  @override
  _ViewAboutPastorPageState createState() => _ViewAboutPastorPageState();
}

class _ViewAboutPastorPageState extends State<ViewAboutPastorPage> {
  
  ZefyrController _zefyrController;
  FocusNode _fnEditor;

  @override
  void initState() {
    _zefyrController = ZefyrController(widget._aboutArticle.getBodyDocument());
    _fnEditor = FocusNode();
    super.initState();
  }

  @override
  void dispose() { 
    _fnEditor.dispose();
    _zefyrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Pastors'),),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    return ZefyrScaffold(
      child: ZefyrEditor(
        mode: ZefyrMode.select,
        autofocus: false,
        focusNode: _fnEditor,
        controller: _zefyrController,
        padding: EdgeInsets.all(8),
      ),
    );
  }
}