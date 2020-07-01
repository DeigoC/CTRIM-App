import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewMyPostsPage extends StatefulWidget {
  @override
  _ViewMyPostsPageState createState() => _ViewMyPostsPageState();
}

class _ViewMyPostsPageState extends State<ViewMyPostsPage> {
  Map<Post, String> _myPostsTime, _myDeletedPosts;

  bool _showDeleted = false;

  @override
  void initState() {
    String userID = BlocProvider.of<AppBloc>(context).currentUser.id;
    _myPostsTime = BlocProvider.of<TimelineBloc>(context).getUserPosts(userID);
    _myDeletedPosts = BlocProvider.of<TimelineBloc>(context).getUserDeletedPosts(userID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert searchbar soon'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_){
              return [
                PopupMenuItem(
                  child: SwitchListTile(
                    value: _showDeleted,
                    title: Icon(Icons.delete, color: Colors.black,),
                    onChanged: (newValue){ 
                      setState(() {_showDeleted = newValue;});
                      Navigator.of(context).pop();
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
          _myPostsTime = BlocProvider.of<TimelineBloc>(context).getUserPosts(userID);
          _myDeletedPosts = BlocProvider.of<TimelineBloc>(context).getUserDeletedPosts(userID);
        }
        Map<Post,String> myPosts = _showDeleted ? _myDeletedPosts : _myPostsTime;
        return ListView.builder(
            itemCount: myPosts.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(myPosts.keys.toList()[index].title),
                subtitle: Text(myPosts.values.toList()[index]),
                onTap: () {
                  BlocProvider.of<AppBloc>(context).add(AppToEditPostPageEvent(
                      myPosts.keys.toList()[index]));
                },
              );
            });
      }),
    );
  }
}
