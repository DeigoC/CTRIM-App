import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectLocationForEvent extends StatefulWidget {
  
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
    return ListView(
      children: [
         Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){

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
                          onPressed: () =>BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent()),
                          child: Text('MAP'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),) 
        )
      ],
    );
  }
}