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
    BlocProvider.of<TimelineBloc>(context).add(TimelineDisplayCurrentUserLikedPosts(currentU.likedPosts));
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Posts'),
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(condition: (_, state) {
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
      }),
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
