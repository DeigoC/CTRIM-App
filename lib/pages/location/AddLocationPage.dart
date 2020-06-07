import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddLocation extends StatefulWidget {
  
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  
  TextEditingController _tecStreetAddress, _tecTownCity, _tecPostcode, _tecSelectedAddress;
  LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _tecStreetAddress = TextEditingController();
    _tecTownCity = TextEditingController();
    _tecPostcode = TextEditingController();
    _tecSelectedAddress = TextEditingController();
    _locationBloc = LocationBloc();
  }

  @override
  void dispose() {
    _tecStreetAddress.dispose();
    _tecTownCity.dispose();
    _tecPostcode.dispose();
    _tecSelectedAddress.dispose();
    _locationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Location'),),
      body: BlocListener(
        bloc: _locationBloc,
        listener: (_, state){
          if(state is LocationDisplayQueryResultsState){
            _displayLocationQueryResults(state.results);
          }else if(state is LocationCancelQueryState){
            Navigator.of(context).pop();
          }else if(state is LocationDisplayConfirmedQueryAddressState){
            Navigator.of(context).pop();
          }
        },
        child: _buildBody()
      ),
    );
  }

  Widget _buildBody(){
    double itemPaddingHeight = 8.0;
    return ListView(
      shrinkWrap: false,
      children: [
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Street Address',
          hint: '12 Example Rd.',
          controller: _tecStreetAddress,
          onTextChange: (newStreetAddress) => _locationBloc.add(LocationTextChangeEvent(streetAddress: newStreetAddress)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Town/City',
          hint: 'Belfast',
          controller: _tecTownCity,
          onTextChange: (newTownCity) => _locationBloc.add(LocationTextChangeEvent(townCityAddress: newTownCity)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Postcode',
          hint: 'BT13 2DE',
          controller: _tecPostcode,
          onTextChange: (newPostcode) => _locationBloc.add(LocationTextChangeEvent(postcode: newPostcode)),
        ),
        SizedBox(height: itemPaddingHeight,),
        BlocBuilder(
          bloc: _locationBloc,
          condition: (previousStatem, currentState){
            if(currentState is LocationButtonState) return true;
            return false;
          },
          builder:(_,state){
            bool enabled = false;
            if(state is LocationEnableFindButtonState) enabled = true;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: RaisedButton(
              child: Text('Find Address'),
              onPressed: enabled? (){
                _locationBloc.add(LocationFindAddressEvent(
                  streetAddress: _tecStreetAddress.text, 
                  townCityAddress: _tecTownCity.text, 
                  postcode: _tecPostcode.text));
              } : null,
              ),
            );
          } 
        ),
        SizedBox(height: itemPaddingHeight,),
        BlocBuilder(
          bloc: _locationBloc,
          condition: (previousState, currentState){
            if(currentState is LocationDisplayConfirmedQueryAddressState) return true;
            return false;
          },
          builder:(_,state){
            if(state is LocationDisplayConfirmedQueryAddressState){
              _tecSelectedAddress.text = state.confirmedAddress;
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                MyTextField(
                  label: 'Selected Address',
                  controller: _tecSelectedAddress,
                  readOnly: true,
                ),
                Container(
                  padding: EdgeInsets.only(top:8.0),
                   width: MediaQuery.of(context).size.width * 0.85,
                  child: RaisedButton(
                    onPressed: _tecSelectedAddress.text.isEmpty ? null : () => null,
                    child: Text('Save New Location'),
                  ),
                ),
              ],
            );
          } 
        ),
      ],
    );
  }

  void _displayLocationQueryResults(List<String> results){
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_){
        return BlocBuilder(
          bloc: _locationBloc,
          condition: (previousState, currentState){
            if(currentState is LocationQueryState) return true;
            return false; 
          },
          builder:(_,state){
            return Scaffold(
              appBar: _buildQueryAppbar(state),
              body: _buildQueryBody(state, results),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: (state is LocationDisplaySelectedLocationMapState) ?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   RaisedButton(
                    child: Text('No'),
                    onPressed: () => _locationBloc.add(LocationWrongQueryAddressEvent()),
                  ),
                  SizedBox(width: 10,),
                   RaisedButton(
                    child: Text('Yes'),
                    onPressed: () => _locationBloc.add(LocationConfirmedQueryAddressEvent()),
                  ),
                ],
              ): null,
            );
          } 
        );
      }
    );
  }

  AppBar _buildQueryAppbar(LocationQueryState state){
    if(state is LocationDisplayQueryResultsState || state is LocationRebuildQueryResultsState){
       return  AppBar(
         title: Text('Select Address',),
         leading: IconButton(
           icon: Icon(Icons.close),
           onPressed: ()=> _locationBloc.add(LocationCancelQueryEvent()),),
        );
    }
     return  AppBar(
       title: Text('Is this it?'),
       leading: Container(),
       centerTitle: true,
      );
  }

  Widget _buildQueryBody(LocationQueryState state, List<String> results){
    if(state is LocationDisplaySelectedLocationMapState){
      return Center(
        child: Text('Map here for: ' + state.selectedAddress),
      );
    }
    return  ListView(
      children: results.map((address){
        return ListTile(
          title: Text(address),
          leading: Icon(Icons.location_searching),
          onTap: () => _locationBloc.add(LocationSelectedQueryAddressEvent(address)),
        );
      }).toList(),
    );
  }
}