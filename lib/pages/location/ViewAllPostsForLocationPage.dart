import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
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

  FutureBuilder _buildBody(BuildContext context){
     return FutureBuilder<List<TimelinePost>>(
       future: BlocProvider.of<TimelineBloc>(context).fetchPostsForLocation(_locationID),
       builder: (_,snap){
         Widget result;

         if(snap.hasData){
           List<User> allUsers = BlocProvider.of<TimelineBloc>(context).allUsers;
           result = _buildBodyWithData(snap.data,allUsers);
         }else if(snap.hasError){
           result = Center(child: Text('Something went wrong!'),);
         }else{
           result = Center(child: CircularProgressIndicator(),);
         }
         return result;
       },
     );
  }

  Widget _buildBodyWithData(List<TimelinePost> data, List<User> allUsers){
    if(data.length==0){
      return Center(child: Text('No Posts Yet!'),);
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: 'view',
          allUsers: allUsers,
          timelinePost: data[index],
        );
      }
    );
  }
}