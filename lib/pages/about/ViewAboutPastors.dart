import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewAboutPastorPage extends StatefulWidget {
  final AboutArticle _aboutArticle;
  ViewAboutPastorPage(this._aboutArticle);
  @override
  _ViewAboutPastorPageState createState() => _ViewAboutPastorPageState();
}

class _ViewAboutPastorPageState extends State<ViewAboutPastorPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTitle(),centerTitle: true,),
      body: _buildBody(),
    );
  }

  Widget _buildTitle(){
    return FutureBuilder<User>(
      future: BlocProvider.of<TimelineBloc>(context).fetchUserByID(widget._aboutArticle.locationPastorUID),
      builder: (_,snap){
        Widget result;
        if(snap.hasData) result = Text(snap.data.surname + ' Family',);
        else if(snap.hasError) result = Text('...');
        else result = CircularProgressIndicator();
        return result;
      },
    );
  }

  Widget _buildBody(){
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent({
              widget._aboutArticle.thirdImage:ImageTag(
                src: widget._aboutArticle.thirdImage,
                type: 'img'
              )
            }, 0));
            },
            child: Hero(
              child: Image.network(widget._aboutArticle.thirdImage,fit: BoxFit.cover,),
              tag: '0/' + widget._aboutArticle.thirdImage,
            ),
          ),
        ),
        SizedBox(height: 16,),
        ZefyrView(document: widget._aboutArticle.getBodyDocument()),
      ],
    );
  }
}
