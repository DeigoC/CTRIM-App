import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllUsers extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Users'),),
      body: BlocBuilder<TimelineBloc, TimelineState>(
        buildWhen: (_,state){
          if(state is TimelineRebuildUserListState) return true;
          return false;
        },
        builder: (_, state) {
        return _buildBody(_);
      }),
    );
  }

  Widget _buildBody(BuildContext context){
    return FutureBuilder<List<User>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchAllUsers(),
      builder: (_,snap){
        Widget result;

        if(snap.hasData) result = _buildListWithData(snap.data, _);
        else if(snap.hasError) result = Center(child: Text('Something went wrong!'),);
        else result = Center(child: CircularProgressIndicator(),);
        
        return result;
      },
    );
  }

  Widget _buildListWithData(List<User> data, BuildContext context){
    data.sort((a,b) => a.surname.compareTo(b.surname));
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(data[index].forename + ' ' + data[index].surname),
          subtitle: Text('Admin Lvl: ' + data[index].adminLevel.toString()),
          trailing: Text(data[index].disabled ? 'Disabled':''),
          onTap: () => BlocProvider.of<AppBloc>(context).add(AppToEditUserEvent(data[index])),
        );
      });
  }
}
