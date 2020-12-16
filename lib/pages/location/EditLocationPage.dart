import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/LocationBloc/location_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/location_query.dart';
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
  TextEditingController _tecStreetAddress,
      _tecTownCity,
      _tecPostcode,
      _tecSelectedAddress,
      _tecDescription;
  LocationBloc _locationBloc;
  bool _hasPosts;

  @override
  void initState() {
    _locationBloc = LocationBloc(BlocProvider.of<AppBloc>(context));
    _locationBloc.setLocationForEdit(widget._location);
    _tecDescription = TextEditingController(text: widget._location.description);
    _tecSelectedAddress =
        TextEditingController(text: widget._location.addressLine);
    _tecStreetAddress = TextEditingController();
    _tecTownCity = TextEditingController();
    _tecPostcode = TextEditingController();
    super.initState();
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
        );
      },
      child: Scaffold(
        appBar: AppBar( title: Text('Edit Location'),centerTitle: true,),
        body: BlocListener(
            cubit: _locationBloc,
            listener: (_, state) {
              if (state is LocationDisplayQueryResultsState) {
                _displayLocationQueryResults(state.results);
              } else if (state is LocationCancelQueryState) {
                Navigator.of(context).pop();
              } else if (state is LocationDisplayConfirmedQueryAddressState) {
                Navigator.of(context).pop();
              } else if (state is LocationEditAttemptToUpdateState) {
                ConfirmationDialogue().uploadTaskStarted(context: context);
              }else if(state is LocationEditUpdateCompleteState){
                BlocProvider.of<TimelineBloc>(context).add(TimelineLocationUpdateOccuredEvent(state.updatedLocation));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
        //Text('Query Address',textAlign: TextAlign.center,),
        // * Selected Address
        BlocBuilder(
            cubit: _locationBloc,
            buildWhen: (previousState, currentState) {
              if (currentState is LocationDisplayConfirmedQueryAddressState) return true;
              return false;
            },
            builder: (_, state) {
              if (state is LocationDisplayConfirmedQueryAddressState) {
                _tecSelectedAddress.text = state.confirmedAddress;
              }
              return MyTextField(
                label: 'Selected Address',
                controller: _tecSelectedAddress,
                buildHelpIcon: false,
                centerLabel: true,
                optional: true,
                readOnly: true,
              );
            }),
       /*  SizedBox(height: itemPaddingHeight,),
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
        // * Find Address button
        BlocBuilder(
            bloc: _locationBloc,
            condition: (previousStatem, currentState) {
              if (currentState is LocationButtonState) return true;
              return false;
            },
            builder: (_, state) {
              bool enabled = false;
              if (state is LocationEnableFindButtonState) enabled = true;
              return MyRaisedButton(
                externalPadding: EdgeInsets.all(8),
                label: 'Find Address',
                onPressed: enabled
                    ? () {
                        _locationBloc.add(LocationFindAddressEvent(
                            streetAddress: _tecStreetAddress.text,
                            townCityAddress: _tecTownCity.text,
                            postcode: _tecPostcode.text));
                      }
                    : null,
              );
            }), */
        SizedBox(height: 32,),
        MyTextField(
          label: 'Short Description',
          controller: _tecDescription,
          optional: true,
          buildHelpIcon: false,
          centerLabel: true,
          hint: '(Optional)',
          maxLength: 60,
          onTextChange: (newDec) {
            _locationBloc.add(LocationDescriptionTextChangeEvent(newDec));
          },
        ),
        SizedBox(height: itemPaddingHeight,),
        _buildImageSelector(),
        SizedBox(height: itemPaddingHeight,),
        // * Save Button
        BlocBuilder(
          cubit: _locationBloc,
          buildWhen: (_, state) {
            if (state is LocationEditEnableUpdateButtonState) return true;
            else if (state is LocationEditDisableUpdateButtonState) return true;
            return false;
          },
          builder: (_, state) {
            return MyRaisedButton(
              externalPadding: EdgeInsets.all(8),
              label: 'Update Location',
              onPressed: (state is LocationEditEnableUpdateButtonState)
                  ? () {
                      ConfirmationDialogue().saveRecord(
                              context: context,
                              record: 'Location',
                              editing: true)
                          .then((confirmation) {
                        if (confirmation) {
                          _locationBloc.add(LocationEditUpdateLocationEvent());
                        }
                      });
                    }: null,
            );
          },
        ),
       _buildDeleteButton(),
       SizedBox(height: 16,),
      ],
    );
  }

  Widget _buildDeleteButton(){
    
    if(BlocProvider.of<AppBloc>(context).currentUser.adminLevel != 3) return Container();
    else{
      if(_hasPosts == null){
        BlocProvider.of<TimelineBloc>(context).doesLocationHaveEvents(widget._location.id).then((value){
          setState(() { _hasPosts = value;});
        });
        return Container();
      }
      return  MyRaisedButton(
        externalPadding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        label: 'Delete Location',
        isDestructive: true,
        onPressed: _hasPosts ? null :(){
          ConfirmationDialogue().deleteRecord(context: context, record: 'Location').then((confirmation){
            if(confirmation){
              _locationBloc.add(LocationEditDeleteLocationEvent());
              Navigator.of(context).pop();
            }
          });
        },
      );
    }
  }

  Column _buildImageSelector() {
    return Column(
      children: [
        Text('Location Image'),
        SizedBox(height: 8,),
        BlocBuilder(
            cubit: _locationBloc,
            buildWhen: (_, state) {
              if (state is LocationSetNewLocationImageState)
                return true;
              else if (state is LocationRemoveSelectedImageState) return true;
              return false;
            },
            builder: (_, state) {
              bool hasFile = false, 
              hasSrc = _locationBloc.locationToEdit.imgSrc != null && _locationBloc.locationToEdit.imgSrc != '';
              File imageFile;
              String src = _locationBloc.locationToEdit.imgSrc;

              if (state is LocationSetNewLocationImageState) {
                hasFile = true;
                imageFile = state.locationFile;
              }
              return GestureDetector(
                onTap: () {
                  if (!hasSrc) _selectLocationImage();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: (hasFile || hasSrc) ? _buildIconButton(hasSrc, hasFile) : Container(),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    image: (hasFile || hasSrc)
                        ? DecorationImage(image: (hasFile) ? FileImage(imageFile) : NetworkImage(src),fit: BoxFit.cover)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            })
      ],
    );
  }

  IconButton _buildIconButton(bool hasSrc, bool hasFile) {
    return IconButton(
      icon: Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      onPressed: () {
        if (hasSrc) {
          ConfirmationDialogue().deleteRecord(context: context, record: 'Image')
              .then((confirmation) {
            if (confirmation) {
              _locationBloc.add(LocationEditRemoveSrcEvent());
            }
          });
        } else {
          _locationBloc.add(LocationRemoveSelectedImageEvent());
        }
      },
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
}
