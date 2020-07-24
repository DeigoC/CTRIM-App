import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostUpdatesTab extends StatelessWidget {
  
  final Post post;
  PostUpdatesTab(this.post);
  
  @override
  Widget build(BuildContext context) {
    List<TimelinePost> allUpdates = BlocProvider.of<TimelineBloc>(context).getAllUpdatePosts(post.id);
    Map<DateTime, List<TimelinePost>> updatesSortedToLists = {};
    allUpdates.forEach((u) {
      DateTime thisDate = DateTime(u.postDate.year, u.postDate.month, u.postDate.day);
      if(updatesSortedToLists[thisDate] == null){
        updatesSortedToLists[thisDate] = [];
      }
      updatesSortedToLists[thisDate].add(u);
    });

    List<DateTime> sortedDates = updatesSortedToLists.keys.toList();
    sortedDates.sort((a,b) => b.compareTo(a));
    User user = BlocProvider.of<TimelineBloc>(context).allUsers.firstWhere(
      (author) => author.id == allUpdates.last.authorID);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Hero(child: user.buildAvatar(),tag: '0/'+user.imgSrc,),
          title: Text(user.forename + ' ' + user.surname[0] + '.'),
          subtitle: Text(user.role),
          onTap: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewUserPageEvent(user)),
          trailing: Text('(AUTHOR)'),
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
        Expanded(child: ListView.separated(
          itemCount: sortedDates.length,
          separatorBuilder: (_,index)=>Divider(),
          itemBuilder: (_,index){
            List<TimelinePost> updates = updatesSortedToLists[sortedDates[index]];
            updates.sort((a,b) => b.postDate.compareTo(a.postDate));
            
            return Container(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
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
            );
          }
        ),)
      ],
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