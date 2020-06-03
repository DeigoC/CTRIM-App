import 'package:flutter/material.dart';

class SelectLocationForEvent extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => null, 
        label: Text('New Location'),
        icon: Icon(Icons.add_location),
      ),
    );
  }
}