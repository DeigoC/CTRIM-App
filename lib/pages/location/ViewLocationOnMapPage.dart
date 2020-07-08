import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewLocationOnMap extends StatefulWidget {
  
  final Location location;
  ViewLocationOnMap(this.location);
  @override
  _ViewLocationOnMapState createState() => _ViewLocationOnMapState();
}

class _ViewLocationOnMapState extends State<ViewLocationOnMap> {
  
  GoogleMapController _mapController;
  LatLng latLng;

  @override
  void initState() {
    latLng = LatLng(
      widget.location.coordinates['Latitude'],
      widget.location.coordinates['Longitude'],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insert the map here'),),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    return GoogleMap(
      mapToolbarEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: latLng,
        zoom: 15,
      ),
      markers: Set<Marker>.of([
        Marker(
          markerId: MarkerId('InitialLocation'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.location.addressLine, snippet: widget.location.description,
            onTap: (){
              print('--------------------TAPPED!');
            }
          )
        )
      ]),
      onMapCreated: (controller){
        setState(() {_mapController = controller;});
      },
    );
  }
}