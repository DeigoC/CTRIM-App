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
  Map<Post, String> _myPostsTime;

  @override
  void initState() {
    String userID = BlocProvider.of<AppBloc>(context).currentUser.id;
    _myPostsTime = BlocProvider.of<TimelineBloc>(context).getUserPosts(userID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert searchbar soon'),
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(condition: (_, state) {
        if (state is TimelineRebuildMyPostsPageState) return true;
        return false;
      }, builder: (_, state) {
        if (state is TimelineRebuildMyPostsPageState) {
          _myPostsTime = state.postTime;
        }
        return ListView.builder(
            itemCount: _myPostsTime.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(_myPostsTime.keys.toList()[index].title),
                subtitle: Text(_myPostsTime.values.toList()[index]),
                onTap: () {
                  BlocProvider.of<AppBloc>(context).add(AppToEditPostPageEvent(
                      _myPostsTime.keys.toList()[index]));
                },
              );
            });
      }),
    );
  }
}
