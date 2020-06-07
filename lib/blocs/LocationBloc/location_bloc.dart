import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  
  String _streetAddress ='', _townCity ='', _postCode='';
  String _selectedAddress= '';
  
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
    }
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
