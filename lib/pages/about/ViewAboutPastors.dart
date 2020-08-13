import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:zefyr/zefyr.dart';

class ViewAboutPastorPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewAboutPastorPage(this._aboutArticle);
  @override
  _ViewAboutPastorPageState createState() => _ViewAboutPastorPageState();
}

class _ViewAboutPastorPageState extends State<ViewAboutPastorPage> {
  
  //ZefyrController _zefyrController;
  FocusNode _fnEditor;

  @override
  void initState() {
    //_zefyrController = ZefyrController(widget._aboutArticle.getBodyDocument());
    _fnEditor = FocusNode();
    super.initState();
  }

  @override
  void dispose() { 
    _fnEditor.dispose();
    //_zefyrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User u = BlocProvider.of<TimelineBloc>(context).allUsers
    .firstWhere((e) => widget._aboutArticle.locationPastorUID.compareTo(e.id)==0);
    return Scaffold(
      appBar: AppBar(title: Text(u.surname + ' Family',),centerTitle: true,),
      body: _placeHolder(),
    );
  }

 /*  Widget _buildBody(){
    return ZefyrScaffold(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent({
              widget._aboutArticle.thirdImage:ImageTag(
                src: widget._aboutArticle.thirdImage,
                type: 'img'
              )
            }, 0));
            },
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Hero(
                child: Image.network(widget._aboutArticle.thirdImage,fit: BoxFit.cover,),
                tag: '0/' + widget._aboutArticle.thirdImage,
              ),
            ),
          ),
          Expanded(
            child: ZefyrEditor(
              mode: ZefyrMode.view,
              autofocus: false,
              focusNode: _fnEditor,
              controller: _zefyrController,
              padding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  } */

  Widget _placeHolder(){
    return Center(child: Text('To be Fixed'),);
  }
}