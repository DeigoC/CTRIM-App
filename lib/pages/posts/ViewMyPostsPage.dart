import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewMyPostsPage extends StatefulWidget {
  @override
  _ViewMyPostsPageState createState() => _ViewMyPostsPageState();
}

class _ViewMyPostsPageState extends State<ViewMyPostsPage> {
  Map<Post, TimelinePost> _myPosts, _myDeletedPosts;

  bool _showDeleted = false;

  @override
  void initState() {
    String userID = BlocProvider.of<AppBloc>(context).currentUser.id;
    _myPosts = BlocProvider.of<TimelineBloc>(context).getUserPosts(userID);
    _myDeletedPosts = BlocProvider.of<TimelineBloc>(context).getUserDeletedPosts(userID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Posts'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_){
              return [
                PopupMenuItem(
                  child: SwitchListTile(
                    value: _showDeleted,
                    title: Icon(Icons.delete, color: Colors.black,),
                    onChanged: (newValue){ 
                      Navigator.of(context).pop();
                      setState(() {_showDeleted = newValue;});
                    },
                  ),
                )
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(condition: (_, state) {
        if (state is TimelineRebuildMyPostsPageState) return true;
        return false;
      }, builder: (_, state) {
        if (state is TimelineRebuildMyPostsPageState) {
           String userID = BlocProvider.of<AppBloc>(context).currentUser.id;
          _myPosts = BlocProvider.of<TimelineBloc>(context).getUserPosts(userID);
          _myDeletedPosts = BlocProvider.of<TimelineBloc>(context).getUserDeletedPosts(userID);
        }
        Map<Post,TimelinePost> myPosts = _showDeleted ? _myDeletedPosts : _myPosts;
        List<TimelinePost> tPosts = List.from(myPosts.values);
        tPosts.sort((a,b) => b.postDate.compareTo(a.postDate));

        return ListView.builder(
          itemCount: myPosts.length,
          itemBuilder: (_, index) {
            return PostArticle(
              mode: 'edit',
              allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
              timelinePost: tPosts[index],
              post: myPosts.keys.firstWhere((e) => e.id.compareTo(tPosts[index].postID)==0),
            );
          });
      }),
    );
  }
}
