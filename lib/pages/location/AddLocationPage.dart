import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/location_query.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/helpDialogTile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AddLocation extends StatefulWidget {
  final PostBloc _postBloc;
  AddLocation(this._postBloc);
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  TextEditingController _tecStreetAddress,
      _tecTownCity,
      _tecPostcode,
      _tecSelectedAddress,
      _tecDescription;
  LocationBloc _locationBloc;
  
  @override
  void initState() {
    super.initState();
    _tecStreetAddress = TextEditingController();
    _tecTownCity = TextEditingController();
    _tecPostcode = TextEditingController();
    _tecSelectedAddress = TextEditingController();
    _tecDescription = TextEditingController();
    _locationBloc = LocationBloc(BlocProvider.of<AppBloc>(context));
  }

  @override
  void dispose() {
    _tecStreetAddress.dispose();
    _tecTownCity.dispose();
    _tecPostcode.dispose();
    _tecSelectedAddress.dispose();
    _locationBloc.close();
    _tecDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return ConfirmationDialogue().leaveEditPage(
          context: context,
          creatingRecord: true,
        );
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Add Location'),),
        body: BlocListener(
            bloc: _locationBloc,
            listener: (_, state) {
              if (state is LocationDisplayQueryResultsState) {
                _displayLocationQueryResults(state.results);
              } else if (state is LocationCancelQueryState) {
                Navigator.of(context).pop();
              } else if (state is LocationDisplayConfirmedQueryAddressState) {
                Navigator.of(context).pop();
              }else if(state is LocationEditAttemptToUpdateState){
                ConfirmationDialogue().uploadTaskStarted(context: context);
              } else if (state is LocationCreatedState){
                widget._postBloc.add(PostSelectedLocationEvent(
                  addressLine: state.location.addressLine,
                  location: state.location
                ));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }else if(state is LocationQueryAddressAlreadyExistsState){
                _locationAlreadyExistsDialog(state.existingRecord);
                
              }
            },
            child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    double itemPaddingHeight = 8.0;
    return ListView(
      shrinkWrap: false,
      children: [
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Street Address',
         // hint: '# Example Rd.',
          controller: _tecStreetAddress,
          helpText: "First line of address. Doesn't require the street number.",
          onTextChange: (newStreetAddress) => _locationBloc
              .add(LocationTextChangeEvent(streetAddress: newStreetAddress)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Town/City',
          //hint: 'Town/City Name',
          helpText: "Self-explanatory.",
          controller: _tecTownCity,
          onTextChange: (newTownCity) => _locationBloc
              .add(LocationTextChangeEvent(townCityAddress: newTownCity)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Postcode',
          //hint: 'BT## ###',
          helpText: "Very important field, make sure it's in the correct format.",
          controller: _tecPostcode,
          onTextChange: (newPostcode) =>
              _locationBloc.add(LocationTextChangeEvent(postcode: newPostcode)),
        ),
        SizedBox(height: itemPaddingHeight,),
        BlocBuilder(
            bloc: _locationBloc,
            condition: (previousStatem, currentState) {
              if (currentState is LocationButtonState) return true;
              return false;
            },
            builder: (_, state) {
              bool enabled = false;
              if (state is LocationEnableFindButtonState) enabled = true;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: MyRaisedButton(
                  label: 'Find Address',
                  onPressed: enabled ? () {
                    _locationBloc.add(LocationFindAddressEvent(
                        streetAddress: _tecStreetAddress.text,
                        townCityAddress: _tecTownCity.text,
                        postcode: _tecPostcode.text));
                  }: null,
                ),
              );
            }),
        SizedBox(height: itemPaddingHeight,),
        _buildImageSelector(),
        SizedBox(height: itemPaddingHeight * 2,),
         BlocBuilder(
            bloc: _locationBloc,
            condition: (previousState, currentState) {
              if (currentState is LocationDisplayConfirmedQueryAddressState) return true;
              return false;
            },
            builder: (_, state) {
              if (state is LocationDisplayConfirmedQueryAddressState) {
                _tecSelectedAddress.text = state.confirmedAddress;
              }
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  MyTextField(
                    label: 'Selected Address',
                    centerLabel: true,
                    helpText: 
                    "Read-Only, seperate words of this address line will be used for the 'Seach Locations' query.",
                    optional: true,
                    controller: _tecSelectedAddress,
                    readOnly: true,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8.0),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: MyRaisedButton(
                      onPressed: _tecSelectedAddress.text.isEmpty ? null : (){
                            _locationBloc.add(LocationSaveNewLocationEvent());
                          },
                      label: 'Save New Location',
                    ),
                  ),
                ],
              );
            }),
        SizedBox(height: 16,),
      ],
    );
  }

  Column _buildImageSelector() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Location Image', style: TextStyle(fontSize: 18),),
              IconButton(
            icon: Icon(AntDesign.questioncircleo),
            onPressed: (){
              showDialog(
                context: context,
                builder: (_){
                  return HelpDialogTile(
                    title: 'Location Image (Optional)',
                    subtitle: 'Show what the location looks like. Can be added at another time by level 2 or 3 admins.',
                  );
                }
              );
            },
          )
            ],
          ),
        ),
        BlocBuilder(
            bloc: _locationBloc,
            condition: (_, state) {
              if (state is LocationSetNewLocationImageState)
                return true;
              else if (state is LocationRemoveSelectedImageState) return true;
              return false;
            },
            builder: (_, state) {
              bool hasFile = false;
              File imageFile;
              if (state is LocationSetNewLocationImageState) {
                hasFile = true;
                imageFile = state.locationFile;
              }

              return GestureDetector(
                onTap: () => _selectLocationImage(),
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: hasFile? IconButton(
                          icon: Icon(Icons.cancel,color: Colors.red,),
                          onPressed: () => _locationBloc.add(LocationRemoveSelectedImageEvent()),
                        ): Container(),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        image: hasFile? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover): null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              );
            })
      ],
    );
  }

  Future _selectLocationImage() async {
    FilePickerResult selectedImage;
    selectedImage = await FilePicker.platform.pickFiles(type: FileType.image);
    _locationBloc.add(LocationImageSelectedEvent(File(selectedImage.files.first.path)));
  }

  void _displayLocationQueryResults(List<String> results) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return LocationQuery(results,_locationBloc);
      });
  }

  void _locationAlreadyExistsDialog(Location existingLocation) async{
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return AlertDialog(
          title: Text('Existing Location Found!'),
          content: Text('Selected address is already recorded. Choose to select that record or'
           + ' query another address.\n\n• Record may have been deleted, selecting will re-enable it.'),
           actions: [
             MyFlatButton(
               label: 'Query Again',
               onPressed: (){
                 Navigator.of(context).pop();
               },
             ),
             MyFlatButton(
               label: 'Select Record',
               onPressed: (){
                 widget._postBloc.add(PostSelectedLocationEvent(
                  addressLine: existingLocation.addressLine,
                  location: existingLocation
                ));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
               },
             ),
           ],
        );
      }
    );
    Navigator.of(context).pop();
  }

}
