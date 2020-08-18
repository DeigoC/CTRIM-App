import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
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
    //BlocProvider.of<TimelineBloc>(context).add(TimelineDisplayCurrentUserLikedPosts(currentU.likedPosts));
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liked Posts'),),
      body: _newBody(),
      
      /* BlocBuilder<TimelineBloc, TimelineState>(condition: (_, state) {
        if (state is TimelineDisplaySearchFeedState) return true;
        return false;
      }, builder: (_, state) {
        if (state is TimelineDisplaySearchFeedState) {
          if (state.posts.length == 0) {
            return Center(child: Text('No liked Posts'),);
          }

          if(_confirmSameResults(state.timelines)){
            return ListView.builder(
              itemCount: BlocProvider.of<AppBloc>(context)
                  .currentUser
                  .likedPosts
                  .length,
              itemBuilder: (_, index) {
                return PostArticle(
                  mode: 'view',
                  allUsers: state.users,
                  post: _getPostFromID(state.timelines[index].postID, state.posts),
                  timelinePost: state.timelines[index],
                );
              });
          }
        }
        return Center( child: CircularProgressIndicator(),);
      }), */
    );
  }

  Widget _newBody(){
    List<String> likedPostsIDs = BlocProvider.of<AppBloc>(context).currentUser.likedPosts;
    
    return FutureBuilder<Map<TimelinePost,Post>>(
      future: null,//BlocProvider.of<TimelineBloc>(context).fetchLikedPostsFeed(likedPostsIDs),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = _buildBodyWithData(snap.data);
        }else if(snap.hasError){
          result = Center(child: Text('Something went wrong'),);
        }else{
          result = Center(child: CircularProgressIndicator(),);
        }
        return result;
      },
    );
  }

  Widget _buildBodyWithData(Map<TimelinePost,Post> data){
    if(data.length == 0){
      return Center(child: Text('No Liked Posts'),);
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: 'view',
          allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
          timelinePost: data.keys.elementAt(index),
          //post: data[data.keys.elementAt(index)],
        );
      }
    );
  }

  bool _confirmSameResults(List<TimelinePost> tPosts){
    for (var i = 0; i < tPosts.length; i++) {
      if(!currentU.likedPosts.contains(tPosts[i].postID) ) return false;
    }
    return true;
  }

  Post _getPostFromID(String id, List<Post> allPosts) {
    Post result;
    allPosts.forEach((post) {
      if (post.id.compareTo(id) == 0) {
        result = post;
      }
    });
    return result;
  }
}
