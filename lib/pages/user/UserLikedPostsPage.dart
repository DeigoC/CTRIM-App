import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserLikedPostsPage extends StatefulWidget {
  @override
  _UserLikedPostsPageState createState() => _UserLikedPostsPageState();
}

class _UserLikedPostsPageState extends State<UserLikedPostsPage> {
  
  User currentU;

  @override
  void initState() {
    currentU = BlocProvider.of<AppBloc>(context).currentUser;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liked Posts'),),
      body: _newBody(),
    );
  }

  Widget _newBody(){
    List<String> likedPostsIDs = BlocProvider.of<AppBloc>(context).currentUser.likedPosts;
    
    return FutureBuilder<Map<String, List>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchLikedPostsFeed(likedPostsIDs),
      builder: (_,snap){
        Widget result;

        if(snap.hasData) result = _buildBodyWithData(snap.data);
        else if(snap.hasError) result = Center(child: Text('Something went wrong'),);
        else result = Center(child: CircularProgressIndicator(),);
        
        return result;
      },
    );
  }

  Widget _buildBodyWithData(Map<String, List> data){
    if(data['TimelinePosts'].length == 0) return Center(child: Text('No Liked Posts'),);
    return ListView.builder(
      itemCount: data['TimelinePosts'].length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: 'view',
          allUsers: data['FeedUsers'],
          timelinePost: data['TimelinePosts'].elementAt(index),
        );
      }
    );
  }
}
