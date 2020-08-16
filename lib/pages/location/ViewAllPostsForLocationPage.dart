import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsForLocation extends StatelessWidget {
  
final String _locationID;
ViewAllEventsForLocation(this._locationID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Posts'),centerTitle: true,),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context){
     return Center(child: Text('UNDER CONSTRUCTION'),);
    /* if(data.length==0){
      return Center(child: Text('No Posts Yet!'),);
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: 'view',
          post: data.keys.elementAt(index),
          timelinePost: data.values.elementAt(index),
          allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
        );
      }
    ); */
  }
}