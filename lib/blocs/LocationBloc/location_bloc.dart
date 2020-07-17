import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  // ! Bloc Fields
  final LocationDBManager _locationDBManager = LocationDBManager();
  List<Address> _queryAddresses =[];

  String _streetAddress = '', _townCity = '', _postCode = '';
  String _selectedAddressLine = '';
  File _locationImage;

  Location _location, _originalLocation;
  void setLocationForEdit(Location location) {
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

  // ! Mapping events to states
  @override
  LocationState get initialState => LocationInitial();

  @override
  Stream<LocationState> mapEventToState(LocationEvent event,) async* {
    if (event is LocationTextChangeEvent)yield* _mapTextChangeEventsToState(event);
    else if (event is LocationQueryAddressEvent)yield* _mapQueryEventsToQueryStates(event);
    else if (event is LocationImageSelectedEvent)yield* _mapImageSetEventToState(event);
    else if (event is LocationRemoveSelectedImageEvent) {
      _locationImage = null;
      yield LocationRemoveSelectedImageState();
    } else if (event is LocationEditLocationEvent)yield* _mapEditLocationToState(event);
    else if(event is LocationSaveNewLocationEvent) yield* _saveNewLocation();
  }

  Stream<LocationState> _mapImageSetEventToState(LocationImageSelectedEvent event) async* {
    if (event.selectedFile != null) {
      _locationImage = event.selectedFile;
      yield LocationSetNewLocationImageState(_locationImage);
    }
  }

  Stream<LocationState> _mapEditLocationToState(LocationEditLocationEvent event) async* {
    if (event is LocationDescriptionTextChangeEvent) {
      _location.description = event.description;
      yield _canUpdateLocation();
    } else if (event is LocationEditRemoveSrcEvent) {
      _location.imgSrc = '';
      yield LocationRemoveSelectedImageState();
      yield _canUpdateLocation();
    } else if (event is LocationEditConfirmedQueryAddressEvent) {
      _location.addressLine = _selectedAddressLine;
      yield LocationDisplayConfirmedQueryAddressState(_selectedAddressLine);
      yield _canUpdateLocation();
    } else if (event is LocationEditUpdateLocationEvent) {
      yield LocationEditChangesSavedState(_location);
    }
  }

  Stream<LocationQueryState> _mapQueryEventsToQueryStates(LocationQueryAddressEvent event) async* {
    if (event is LocationFindAddressEvent) {
      yield* _mapQueryToResultsState(event);
    } else if (event is LocationCancelQueryEvent) {
      yield LocationCancelQueryState();
    } else if (event is LocationSelectedQueryAddressEvent) {
      _selectedAddressLine = event.selectedAddress;
      yield LocationDisplaySelectedLocationMapState(event.selectedAddress);
    } else if (event is LocationWrongQueryAddressEvent) {
      yield LocationRebuildQueryResultsState();
    } else if (event is LocationConfirmedQueryAddressEvent) {
      yield LocationDisplayConfirmedQueryAddressState(_selectedAddressLine);
    }else if (event is LocationSaveNewLocationEvent) yield* _saveNewLocation();
  }

  Stream<LocationState> _mapTextChangeEventsToState(LocationTextChangeEvent event) async* {
    _streetAddress = event.streetAddress ?? _streetAddress;
    _townCity = event.townCityAddress ?? _townCity;
    _postCode = event.postcode ?? _postCode;
    if (_streetAddress.trim().isEmpty ||
        _townCity.trim().isEmpty ||
        _postCode.trim().isEmpty) {
      yield LocationDisableFindButtonState();
    } else {
      yield LocationEnableFindButtonState();
    }
  }

  LocationState _canUpdateLocation() {
    if (_location.description.compareTo(_originalLocation.description) != 0 ||
        _location.addressLine.compareTo(_originalLocation.addressLine) != 0 ||
        _location.imgSrc == '') {
      return LocationEditEnableUpdateButtonState();
    }
    return LocationEditDisableUpdateButtonState();
  }

  Stream<LocationState> _saveNewLocation() async*{
    Address add = _queryAddresses.firstWhere((a) => a.addressLine.compareTo(_selectedAddressLine)==0);
    Location newLocation = Location(
      addressLine: _selectedAddressLine,
      coordinates: {'Latitude':add.coordinates.latitude, 'Longitude':add.coordinates.longitude},
      deleted: false,
      description: 'Used for Events',
    );
    await _locationDBManager.addLocation(newLocation).then((_){
      LocationDBManager.allLocations.add(newLocation);
    });
    yield LocationCreatedState();
  }

  Stream<LocationQueryState> _mapQueryToResultsState(LocationFindAddressEvent event) async*{
    _queryAddresses.clear();
    String query = event.streetAddress + ',' +event.townCityAddress + ',' + event.postcode;
    await Geocoder.local.findAddressesFromQuery(query).then((results){
      results.forEach((address){
        _queryAddresses.add(address);
      });
    });
    yield LocationDisplayQueryResultsState(_queryAddresses.map((a) => a.addressLine).toList());
  }


}
