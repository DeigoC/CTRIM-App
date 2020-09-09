import 'dart:ffi';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/locationCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchLocationPage extends StatefulWidget {
  
  final PostBloc _postBloc;
  SearchLocationPage(this._postBloc);

  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  
  FocusNode _fnSearchLocation;
  List<Location> _allLocations= [];
  String _searchString;

  @override
  void initState() { 
    super.initState();
    _fnSearchLocation = FocusNode();

  }

  @override
  void dispose() { 
    _fnSearchLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          onTap: (){
            setState(() {
              _fnSearchLocation.requestFocus();
            });
          },
          focusNode: _fnSearchLocation,
          onSubmitted: (searchString){
            setState(() {
              _searchString = searchString;
            });
          },
        ),
        actions: [_buildAppbarLeading()],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB(){
    if(widget._postBloc==null) return null;
    return FloatingActionButton(
      child: Icon(Icons.add_location),
      onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToAddLocationEvent(widget._postBloc)),
    );
  }

  Widget _buildBody(){
    if(_searchString == null){
       return Center(child: Text('Awaiting Search...'),);
    }else if(_allLocations.length ==0){
      BlocProvider.of<TimelineBloc>(context).fetchAllUndeletedLocations().then((allLocations){
        setState(() {
          _allLocations = allLocations;
        });
      });
      return Center(child: CircularProgressIndicator(),);
    }else{
      List<Location> filteredList = _allLocations
      .where((e) => e.addressLine.toLowerCase().contains(_searchString.toLowerCase())).toList();

      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (_,index){
          if(widget._postBloc==null) return LocationCard(location: filteredList[index],);
          return LocationCard.addressSelect(
            location: filteredList[index], 
            onTap: (){
              widget._postBloc.add(PostSelectedLocationEvent(
                location: filteredList[index],
                addressLine: filteredList[index].addressLine,
              ));
              Navigator.of(context).pop();
            }
          );
        }
      );
    }
   
  }

  Widget _buildAppbarLeading(){
    if( _fnSearchLocation.hasFocus){
      return FlatButton(
        child: Text('Cancel',style: TextStyle(color: Colors.white)),
        onPressed: (){
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        },
      );
    }
    return FlatButton(
      child: Text('Back',style: TextStyle(color: Colors.white),),
      onPressed: (){
        Navigator.of(context).pop();
      },
    );
  }
}