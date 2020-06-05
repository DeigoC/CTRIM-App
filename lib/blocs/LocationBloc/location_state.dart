part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
   @override
  List<Object> get props => [];
  const LocationState();
}

class LocationInitial extends LocationState {}

class LocationButtonState extends LocationState{}
class LocationDisableFindButtonState extends LocationButtonState{}
class LocationEnableFindButtonState extends LocationButtonState{}

// * The Query Parts
class LocationQueryState extends LocationState{}

class LocationDisplayQueryResultsState extends LocationQueryState{
  final List<String> results; //TODO change this of course
  LocationDisplayQueryResultsState(this.results);
}
class LocationDisplaySelectedLocationMap extends LocationQueryState{
  final String selectedAddress;
  LocationDisplaySelectedLocationMap(this.selectedAddress);
}

class LocationCancelQueryState extends LocationQueryState{}

class LocationRebuildQueryResults extends LocationQueryState{}

class LocationDisplayConfirmedQueryAddressState extends LocationQueryState{
  final String confirmedAddress;
  LocationDisplayConfirmedQueryAddressState(this.confirmedAddress);
}
