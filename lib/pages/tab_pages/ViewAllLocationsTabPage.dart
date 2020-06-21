import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllLocationsPage{

  BuildContext _context;
  void setContext(BuildContext context) => _context = context;

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
    List<Location> allLocations = BlocProvider.of<TimelineBloc>(_context).locations;
    allLocations.removeWhere((element) => element.id == '0');

    return ListView(
      children: allLocations.map((location){
        return Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){
               BlocProvider.of<AppBloc>(_context).add(AppToViewLocationOnMapEvent());
            },
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
                        title: Text(location.addressLine),
                        subtitle: Text(location.description),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToViewAllPostsForLocationEvent()),
                            child: Text('POSTS'),
                          ),
                           FlatButton(
                            onPressed: () =>BlocProvider.of<AppBloc>(_context).add(AppToEditLocationEvent()),
                            child: Text('EDIT',style: TextStyle(color: Colors.blue),),
                          ),
                           IconButton(
                            icon: Icon(Icons.content_copy),
                            tooltip: 'Copy address line',
                            onPressed: (){
                              Clipboard.setData(ClipboardData(text: location.addressLine));
                              Scaffold.of(_context).showSnackBar(SnackBar(
                                content: Text('Address line copied')
                              ));
                              //TODO add snackbar here!
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      /* [
        Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){
               BlocProvider.of<AppBloc>(_context).add(AppToViewLocationOnMapEvent());
            },
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
                        title: Text("48 The Demesne, Carryduff, Belfast, BT8 8GU, UK"),
                        subtitle: Text('Sub'),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToViewAllPostsForLocationEvent()),
                            child: Text('EVENTS'),
                          ),
                           FlatButton(
                            onPressed: () =>BlocProvider.of<AppBloc>(_context).add(AppToEditLocationEvent()),
                            child: Text('EDIT',style: TextStyle(color: Colors.blue),),
                          ),
                           IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: (){
                              Clipboard.setData(ClipboardData(text: 'Copy this boi'));
                              //TODO add snackbar here!
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ], */
    );
  }
}