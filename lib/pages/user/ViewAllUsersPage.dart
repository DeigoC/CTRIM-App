import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Users'),
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(builder: (_, state) {
        return ListView.builder(
            itemCount: BlocProvider.of<TimelineBloc>(context).allUsers.length,
            itemBuilder: (_, index) {
              User user =
                  BlocProvider.of<TimelineBloc>(context).allUsers[index];
              return ListTile(
                title: Text(user.forename + ' ' + user.surname),
                subtitle: Text('Admin Lvl: ' + user.adminLevel.toString()),
                onTap: () => BlocProvider.of<AppBloc>(context)
                    .add(AppToEditUserEvent(user)),
              );
            });
      }),
    );
  }
}
