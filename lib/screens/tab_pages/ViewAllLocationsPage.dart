import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllLocationsPage{

  final BuildContext _context;

  ViewAllLocationsPage(this._context);

  FloatingActionButton buildFAB(){
    return FloatingActionButton.extended(
      onPressed: ()=>null,
      label: Text('New Location'),
      icon: Icon(Icons.add_location),
    );
  }

  AppBar buildAppBar(){
    return AppBar(title: Text('View all locations'),);
  }

  Widget buildBody(){
    return ListView(
      children: [
        Card(
          
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(_context).size.width * 0.30,
                  height: MediaQuery.of(_context).size.width * 0.30,
                  color: Colors.pink,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                      title: SelectableText("Youth Day Out at Lodon's Bridge"),
                      subtitle: Text('Sub'),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          onPressed: () => BlocProvider.of<AppBloc>(_context).add(ToViewAllEventsForLocation()),
                          child: Text('EVENTS'),
                        ),
                        FlatButton(
                          onPressed: () =>BlocProvider.of<AppBloc>(_context).add(ToViewLocationOnMap()),
                          child: Text('MAP'),
                        ),
                         FlatButton(
                          onPressed: () =>BlocProvider.of<AppBloc>(_context).add(ToEditLocation()),
                          child: Text('EDIT',style: TextStyle(color: Colors.blue),),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}