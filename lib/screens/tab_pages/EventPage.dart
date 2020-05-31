import 'package:ctrim_app_v1/blocs/AppNavBloc/appnav_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventPage{

  final BuildContext _context;

  EventPage(this._context);

  Widget buildAppBar(){
    return AppBar(
      title: Text('Insert Logo and search icon'),
    );
  }

  Widget buildBody(){
    return ListView(
      children: [
        ListTile(
          title: Text('Insert full test here'),
          onTap: (){
            BlocProvider.of<AppNavBloc>(_context).add(AppnavToViewEvent());
          },  
        )
      ],
    );
  }

}