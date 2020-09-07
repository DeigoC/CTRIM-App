import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/viewUserSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostUpdatesTab extends StatelessWidget {
  
  final Post post;
  final List<TimelinePost> _allTimelinePosts;
  
  PostUpdatesTab(this.post, this._allTimelinePosts);
  
  @override
  Widget build(BuildContext context) {
    User user = BlocProvider.of<TimelineBloc>(context).allUsers
    .firstWhere( (author) => author.id == _allTimelinePosts.last.authorID);

    return CustomScrollView(
      slivers: [
        SliverList(//TODO wrap this into a FB to fetch user?
          delegate: SliverChildListDelegate([
            ListTile(
              leading: Hero(child: user.buildAvatar(context),tag:'no more',),
              title: Text(user.forename + ' ' + user.surname[0] + '.'),
              subtitle: Text('Author'),
              onTap: (){
                var controller = showBottomSheet(
                  context: context, 
                  backgroundColor: Colors.transparent,
                  builder: (_){
                    return ViewUserSheet(user);
                });
                BlocProvider.of<PostBloc>(context).add(PostRemoveViewFABEvent());
                controller.closed.then((_) => BlocProvider.of<PostBloc>(context).add(PostBuildViewFABEvent()));
              },
              trailing: Icon(Icons.info),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(top:8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('DATE', textAlign: TextAlign.center,),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text('TIME / UPDATE LOG',textAlign: TextAlign.center,),
                    flex: 2,
                  )
                ],
              ),
            ),
          ]),
        ),
        _buildUpdatesList(),
      ],
    );
  }

  SliverList _buildUpdatesList(){
    Map<DateTime, List<TimelinePost>> updatesSortedToLists = {};
    _allTimelinePosts.forEach((u) {
      DateTime thisDate = DateTime(u.postDate.year, u.postDate.month, u.postDate.day);
      if(updatesSortedToLists[thisDate] == null){
        updatesSortedToLists[thisDate] = [];
      }
      updatesSortedToLists[thisDate].add(u);
    });

    List<DateTime> sortedDates = updatesSortedToLists.keys.toList();
    sortedDates.sort((a,b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_,index){
          List<TimelinePost> updates = updatesSortedToLists[sortedDates[index]];
          updates.sort((a,b) => b.postDate.compareTo(a.postDate));
          
          return Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                index == 0 ? SizedBox(height: 16,):Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(updates.first.getPostDateString(), textAlign: TextAlign.center,),
                      flex: 1,
                    ),
                    Expanded(
                      child: _mapUpdatesLogsToWidgets(updates),
                      flex: 2,
                    )
                  ],
                ),
              ],
            ),
          );
        },
        childCount: sortedDates.length),
    );
  }

  Column _mapUpdatesLogsToWidgets(List<TimelinePost> updates){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: updates.map((u){
        List<Widget> children = [
          Text(u.getUpdateTime()),
          Text(u.getUpdateString()),
          Divider(),
        ];
        if(updates.indexOf(u) == updates.length - 1){
          children.removeLast();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }).toList(),
    );
  }
}