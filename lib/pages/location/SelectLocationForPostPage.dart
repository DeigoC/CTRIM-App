import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectLocationForEvent extends StatefulWidget {
  
  final PostBloc _postBloc;
  SelectLocationForEvent(this._postBloc);

  @override
  _SelectLocationForEventState createState() => _SelectLocationForEventState();
}

class _SelectLocationForEventState extends State<SelectLocationForEvent> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToAddLocationEvent()), 
        label: Text('New Location'),
        icon: Icon(Icons.add_location),
      ),
    );
  }

  ListView _buildBody(){
    List<Widget> children = BlocProvider.of<TimelineBloc>(context).locations.map((location){
      return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            widget._postBloc.add(PostSelectedLocationEvent(
              locationID: location.id,
              addressLine: location.addressLine,
            ));
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.width * 0.30,
                  color: Colors.pink,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(location.addressLine),
                      subtitle: Text('Sub'),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          onPressed: () =>BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent()),
                          child: Text('MAP'),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }).toList();

    return ListView(
      children: children,
    );
  }
}