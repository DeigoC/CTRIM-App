import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage{

  final BuildContext _context;

  ViewAllEventsPage(this._context);

  Widget buildAppBar(){
    return AppBar(
      title: Text('Insert Logo and search icon',),
    );
  }

  FloatingActionButton buildFAB(){
    return FloatingActionButton.extended(
      onPressed: (){
        BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent());
      },
      icon: Icon(Icons.add),
       label: Text('Event'),
      );
  }

  Widget buildBody(){
    return ListView(
      children: [
        ListTile(
          title: Text('Insert full test here'),
          onTap: (){
            BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent());
          },  
        )
      ],
    );
  }

}