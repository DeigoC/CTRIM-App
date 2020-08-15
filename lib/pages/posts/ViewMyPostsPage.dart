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
  bool _showDeleted = false;

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
        return _newBody();
      }),
    );
  }

  Widget _newBody(){
    return FutureBuilder<Map<TimelinePost, Post>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchAllUserPosts(BlocProvider.of<AppBloc>(context).currentUser.id),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = _buildBodyWithData(snap.data);
        }else if(snap.hasError){
          result = Center(child: Text('Something went wrong!'),);
        }else{
          result = Center(child: CircularProgressIndicator(),);
        }
        return result;
      },
    );
  }

  Widget _buildBodyWithData(Map<TimelinePost, Post> data){
    Map<TimelinePost, Post> deleted = Map.from(data), notDeleted = Map.from(data);
    deleted.removeWhere((key, value) => !value.deleted);
    notDeleted.removeWhere((key, value) => value.deleted);
    Map<TimelinePost, Post> listToDisplay = _showDeleted ? deleted : notDeleted;

    return ListView.builder(
      itemCount: listToDisplay.length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: 'edit',
          allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
          timelinePost: listToDisplay.keys.elementAt(index),
          post: data[listToDisplay.keys.elementAt(index)],
        );
      }
    );
  }
}
