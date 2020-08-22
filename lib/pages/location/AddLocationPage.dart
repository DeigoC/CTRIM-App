import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/location_query.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
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
              ConfirmationDialogue.uploadTaskStarted(context: context);
            } else if (state is LocationCreatedState){
              widget._postBloc.add(PostSelectedLocationEvent(
                addressLine: LocationDBManager.allLocations.last.addressLine,
                locationID: LocationDBManager.allLocations.last.id,
              ));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: _buildBody()),
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
          hint: '12 Example Rd.',
          controller: _tecStreetAddress,
          onTextChange: (newStreetAddress) => _locationBloc
              .add(LocationTextChangeEvent(streetAddress: newStreetAddress)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Town/City',
          hint: 'Belfast',
          controller: _tecTownCity,
          onTextChange: (newTownCity) => _locationBloc
              .add(LocationTextChangeEvent(townCityAddress: newTownCity)),
        ),
        SizedBox(height: itemPaddingHeight,),
        MyTextField(
          label: 'Postcode',
          hint: 'BT13 2DE',
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
                  onPressed: enabled
                      ? () {
                          _locationBloc.add(LocationFindAddressEvent(
                              streetAddress: _tecStreetAddress.text,
                              townCityAddress: _tecTownCity.text,
                              postcode: _tecPostcode.text));
                        }: null,
                ),
              );
            }),
        SizedBox(height: itemPaddingHeight,),
        BlocBuilder(
            bloc: _locationBloc,
            condition: (previousState, currentState) {
              if (currentState is LocationDisplayConfirmedQueryAddressState)
                return true;
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
                    controller: _tecSelectedAddress,
                    readOnly: true,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8.0),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: MyRaisedButton(
                      onPressed:
                          _tecSelectedAddress.text.isEmpty ? null : (){
                            _locationBloc.add(LocationSaveNewLocationEvent());
                          },
                      label: 'Save New Location',
                    ),
                  ),
                ],
              );
            }),
        SizedBox(height: itemPaddingHeight,),
        _buildImageSelector(),
        SizedBox(height: itemPaddingHeight,),
      ],
    );
  }

  Column _buildImageSelector() {
    return Column(
      children: [
        Text('Location Image (Optional)'),
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
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: hasFile
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            onPressed: () => _locationBloc
                                .add(LocationRemoveSelectedImageEvent()),
                          )
                        : Container(),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    image: hasFile
                        ? DecorationImage(
                            image: FileImage(imageFile), fit: BoxFit.cover)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            })
      ],
    );
  }

  Future _selectLocationImage() async {
    File selectedImage;
    selectedImage = await FilePicker.getFile(type: FileType.image);
    _locationBloc.add(LocationImageSelectedEvent(selectedImage));
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
}
