import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewLocationOnMap extends StatefulWidget {
  
  final Location location;
  ViewLocationOnMap(this.location);
  @override
  _ViewLocationOnMapState createState() => _ViewLocationOnMapState();
}

class _ViewLocationOnMapState extends State<ViewLocationOnMap> {
  
  //GoogleMapController _mapController;
  LatLng latLng;
  BuildContext _context;

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
      appBar: AppBar(title: Text('Google Maps'),centerTitle: true,),
      body: Builder(builder:(_){
        _context = _;
         return _buildBody();
      }),
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
            title: widget.location.addressLine, 
            snippet: 'Tap again to copy address',
            onTap: (){
              Clipboard.setData(ClipboardData(text: widget.location.addressLine));
              Scaffold.of(_context).showSnackBar(SnackBar(content: Text('Address line copied')));
            }
          )
        )
      ]),
      onMapCreated: (controller){
        //setState(() {_mapController = controller;});
      },
    );
  }
}