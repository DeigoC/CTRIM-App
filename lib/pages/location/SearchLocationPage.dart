import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
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
  List<Location> _locationResults= [];
  String _searchString;

  bool _fetchingResults = false;

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
        titleSpacing: 8.0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _buildAppBarLeading(),
            MySearchBar(
              focusNode: _fnSearchLocation,
              onSubmitted: (searchString){
                setState(() {
                  _searchString = searchString;
                  _fetchingResults = true;
                });
              },
              onTap: () => setState(() {_fnSearchLocation.requestFocus();}),
            ),
          ],
        ),
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
    }else if(_fetchingResults){
      BlocProvider.of<TimelineBloc>(context).fetchLocationsByPostCode(_searchString).then((results){
        setState(() {
          _locationResults = results;
          _fetchingResults = false;
        });
      });
      return Center(child: CircularProgressIndicator(),);
    }else{
      return _buildResults();
    }
   
  }

  Widget _buildResults(){
    if(_locationResults.length ==0) return Center(child: Text('Sorry, No Results!'),);
    return ListView.builder(
        itemCount: _locationResults.length,
        itemBuilder: (_,index){
          if(widget._postBloc==null) return LocationCard(location: _locationResults[index],);
          return LocationCard.addressSelect(
            location: _locationResults[index], 
            onTap: (){
              widget._postBloc.add(PostSelectedLocationEvent(
                location: _locationResults[index],
                addressLine: _locationResults[index].addressLine,
              ));
              Navigator.of(context).pop();
            }
          );
        }
      );
  }

  Widget _buildAppBarLeading(){
    if( _fnSearchLocation.hasFocus){
      return FlatButton(
        child: Text('CANCEL',style: TextStyle(color: Colors.white)),
        onPressed: (){
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        },
      );
    }
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: ()=>Navigator.of(context).pop(),
    );
    /* return FlatButton(
      child: Text('BACK',style: TextStyle(color: Colors.white),),
      onPressed: (){
        Navigator.of(context).pop();
      },
    ); */
  }
}

