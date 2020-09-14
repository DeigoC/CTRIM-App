import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationQuery extends StatefulWidget {
  
  final LocationBloc _locationBloc;
  final List<String> _results;

  LocationQuery(this._results,this._locationBloc);
  
  @override
  _LocationQueryState createState() => _LocationQueryState();
}

class _LocationQueryState extends State<LocationQuery> {
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: widget._locationBloc,
      condition: (previousState, currentState) {
        if (currentState is LocationQueryState) return true;
        return false;
      },
      builder: (_, state) {
        return Scaffold(
          appBar: _buildQueryAppbar(state),
          body: _buildQueryBody(state, widget._results),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: (state is LocationDisplaySelectedLocationMapState) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text('No'),
                onPressed: () => widget._locationBloc.add(LocationWrongQueryAddressEvent()),
              ),
              SizedBox(width: 10,),
              RaisedButton(
                child: Text('Yes'),
                onPressed: () => widget._locationBloc.add(LocationEditConfirmedQueryAddressEvent()),
              ),
            ],
          ): null,
        );
      });
  }

  AppBar _buildQueryAppbar(LocationQueryState state) {
    if (state is LocationDisplayQueryResultsState ||state is LocationRebuildQueryResultsState) {
      return AppBar(
        title: Text( 'Select Address',),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => widget._locationBloc.add(LocationCancelQueryEvent()),
        ));
    }
    return AppBar(
      title: Text('Is this it?'),
      leading: Container(),
      centerTitle: true,
    );
  }

  Widget _buildQueryBody(LocationQueryState state, List<String> results) {
    if (state is LocationDisplaySelectedLocationMapState) {
      return _buildGoogleMaps(state.selectedAddress);
    }else if(results.length==0) return Center(child: Text('No address found with given query!'),);
    return ListView(
      children: results.map((address) {
        return ListTile(
          title: Text(address),
          leading: Icon(Icons.location_searching),
          onTap: () => widget._locationBloc.add(LocationSelectedQueryAddressEvent(address)),
        );
      }).toList(),
    );
  }

  Widget _buildGoogleMaps(Address address){
    LatLng latLng = LatLng(address.coordinates.latitude, address.coordinates.longitude);
    
    return GoogleMap(
      mapToolbarEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        zoom: 17,
        target: latLng,
      ),
      markers: Set<Marker>.of([
        Marker(
          markerId: MarkerId('InitialLocation'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: address.addressLine, 
            snippet: 'Location for Query',
            onTap: (){}
          )
        )
      ]),
      onMapCreated: (controller){},
    );
  }
}