import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<User> allUsers = BlocProvider.of<TimelineBloc>(context).allUsers;
    allUsers.sort((a,b) => a.surname.compareTo(b.surname));

    return Scaffold(
      appBar: AppBar(title: Text('View All Users'),),
      body: BlocBuilder<TimelineBloc, TimelineState>(
        condition: (_,state){
          if(state is TimelineRebuildUserListState) return true;
          return false;
        },
        builder: (_, state) {
        return ListView.builder(
            itemCount: allUsers.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(allUsers[index].forename + ' ' + allUsers[index].surname),
                subtitle: Text('Admin Lvl: ' + allUsers[index].adminLevel.toString()),
                trailing: Text(allUsers[index].disabled ? 'Disabled':''),
                onTap: () => BlocProvider.of<AppBloc>(context).add(AppToEditUserEvent(allUsers[index])),
              );
            });
      }),
    );
  }
}
