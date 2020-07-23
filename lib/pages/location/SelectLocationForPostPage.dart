import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/locationCard.dart';
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
        onPressed: () =>
            BlocProvider.of<AppBloc>(context).add(AppToAddLocationEvent(widget._postBloc)),
        label: Text('New Location'),
        icon: Icon(Icons.add_location),
      ),
    );
  }

  ListView _buildBody() {
    return ListView.builder(
      itemCount: BlocProvider.of<TimelineBloc>(context).selectableLocations.length,
      itemBuilder: (_, index) {
        Location location =BlocProvider.of<TimelineBloc>(context).selectableLocations[index];
        return LocationCard.addressSelect(
          location: location,
          onTap: () {
            widget._postBloc.add(PostSelectedLocationEvent(
              locationID: location.id,
              addressLine: location.addressLine,
            ));
            Navigator.of(context).pop();
          },
        );
      });
  }
}
