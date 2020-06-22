import 'dart:io';

import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:ctrim_app_v1/models/location.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditLocation extends StatefulWidget {
  
  final Location _location;
  EditLocation(this._location);

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
 
 TextEditingController _tecStreetAddress, _tecTownCity, _tecPostcode, _tecSelectedAddress, _tecDescription;
 LocationBloc _locationBloc;
 
  @override
  void initState() {
    _locationBloc = LocationBloc();
    _locationBloc.setLocationForEdit(widget._location);
    _tecDescription = TextEditingController(text: widget._location.description);
    _tecSelectedAddress = TextEditingController(text: widget._location.addressLine);
    super.initState();
  }

  @override
  void dispose() {
    _locationBloc.close();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Location'),),
      body: BlocListener(
        bloc: _locationBloc,
        listener: (_,state){
          if(state is LocationDisplayQueryResultsState){
            _displayLocationQueryResults(state.results);
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
        MyTextField(
          label: 'Description',
          controller: _tecDescription,
          hint: '(Optional)',
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Street Address',
          hint: '12 Example Rd.',
          controller: null,
          onTextChange: (newStreetAddress) => _locationBloc.add(LocationTextChangeEvent(streetAddress: newStreetAddress)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Town/City',
          hint: 'Belfast',
          controller: null,
          onTextChange: (newTownCity) => _locationBloc.add(LocationTextChangeEvent(townCityAddress: newTownCity)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Postcode',
          hint: 'BT13 2DE',
          controller: null,
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
        SizedBox(height: itemPaddingHeight,),
        _buildImageSelector(),
      ],
    );
  }

  Column _buildImageSelector() {
    return Column(
        children: [
          Text('Location Image'),
          BlocBuilder(
            bloc: _locationBloc,
            condition: (_,state) {
              if(state is LocationSetNewLocationImageState) return true;
              else if(state is LocationRemoveSelectedImageState) return true;
              return false;
            },
            builder:(_,state) {
            bool hasFile = false;
            File imageFile;
            if(state is LocationSetNewLocationImageState){
              hasFile = true;
              imageFile = state.locationFile;
            }
            return GestureDetector(
              onTap: ()=> _selectLocationImage(),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.20,
                child: Align(
                  alignment: Alignment.topRight,
                  child: hasFile ? IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red,),
                    onPressed: () => _locationBloc.add(LocationRemoveSelectedImageEvent()),
                  ) : Container(),
                ),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  image: hasFile ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            } 
          )
        ],
      );
  }

  Future _selectLocationImage() async{
    File selectedImage;
    selectedImage = await FilePicker.getFile(
      type: FileType.image
    );
    _locationBloc.add(LocationImageSelectedEvent(selectedImage));
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