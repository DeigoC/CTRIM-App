import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/models/location.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  
  String _streetAddress ='', _townCity ='', _postCode='';
  String _selectedAddress= '';
  File _locationImage;
  
  Location _location, _originalLocation;
  void setLocationForEdit(Location location){
     _location = Location(
       id: location.id,
      addressLine: location.addressLine,
      description: location.description,
      imgSrc: location.imgSrc,
    );

    _originalLocation = Location(
      addressLine: location.addressLine,
      description: location.description,
    );
  } 
  Location get locationToEdit => _location;

  @override
  LocationState get initialState => LocationInitial();

  @override
  Stream<LocationState> mapEventToState(
    LocationEvent event,
  ) async* {
    if(event is LocationTextChangeEvent){
      yield* _mapTextChangeEventsToState(event);
    }else if(event is LocationQueryAddressEvent){
      yield* _mapQueryEventsToQueryStates(event);
    }else if(event is LocationImageSelectedEvent){
      if(event.selectedFile != null){
        _locationImage = event.selectedFile;
        yield LocationSetNewLocationImageState(_locationImage);
      }
    }else if(event is LocationRemoveSelectedImageEvent){
      _locationImage = null;
      yield LocationRemoveSelectedImageState();
    }else if(event is LocationEditLocationEvent) yield* _mapEditLocationToState(event);
  }

  Stream<LocationState> _mapEditLocationToState(LocationEditLocationEvent event) async*{
    if(event is LocationDescriptionTextChangeEvent){
      _location.description = event.description;
      yield _canUpdateLocation();
    }else if(event is LocationEditRemoveSrcEvent){
      _location.imgSrc = '';
      yield LocationRemoveSelectedImageState();
      yield _canUpdateLocation();
    }else if(event is LocationEditConfirmedQueryAddressEvent){
      _location.addressLine = _selectedAddress;
      yield LocationDisplayConfirmedQueryAddressState(_selectedAddress);
      yield _canUpdateLocation();
    }else if(event is LocationEditUpdateLocationEvent){
      //TODO need to sort image in the future
      yield LocationEditChangesSavedState(_location);
    }
  }

  LocationState _canUpdateLocation(){
    if(_location.description.compareTo(_originalLocation.description) != 0 ||
    _location.addressLine.compareTo(_originalLocation.addressLine) != 0 ||
    _location.imgSrc == ''){
      return LocationEditEnableUpdateButtonState();
    }
    return LocationEditDisableUpdateButtonState();
  }

  Stream<LocationQueryState> _mapQueryEventsToQueryStates(LocationQueryAddressEvent event)async*{
    if(event is LocationFindAddressEvent){
      yield _mapQueryToResultsState(event);
    }else if(event is LocationCancelQueryEvent){
      yield LocationCancelQueryState();
    }else if(event is LocationSelectedQueryAddressEvent){
      _selectedAddress = event.selectedAddress;
      yield LocationDisplaySelectedLocationMapState(event.selectedAddress);
    }else if(event is LocationWrongQueryAddressEvent){
      yield LocationRebuildQueryResultsState();
    }else if(event is LocationConfirmedQueryAddressEvent){
      yield LocationDisplayConfirmedQueryAddressState(_selectedAddress);
    }
  }

  LocationState _mapQueryToResultsState(LocationFindAddressEvent event){
    //TODO add the logic here 
    
    return LocationDisplayQueryResultsState(['Address 1', 'Address 2']);
  }

  Stream<LocationState> _mapTextChangeEventsToState(LocationTextChangeEvent event) async*{
    _streetAddress = event.streetAddress ?? _streetAddress;
    _townCity = event.townCityAddress ?? _townCity;
    _postCode = event.postcode ?? _postCode;
    if(_streetAddress.trim().isEmpty || _townCity.trim().isEmpty || _postCode.trim().isEmpty){
      yield LocationDisableFindButtonState();
    }else{
      yield LocationEnableFindButtonState();
    }
  }
}
