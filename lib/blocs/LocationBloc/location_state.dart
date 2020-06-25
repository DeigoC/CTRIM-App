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

class LocationSetNewLocationImageState extends LocationState{
  final File locationFile;
  LocationSetNewLocationImageState(this.locationFile);
}
class LocationRemoveSelectedImageState extends LocationState{}


// * The Query Parts
class LocationQueryState extends LocationState{}

class LocationDisplayQueryResultsState extends LocationQueryState{
  final List<String> results; //TODO change this of course
  LocationDisplayQueryResultsState(this.results);
}
class LocationDisplaySelectedLocationMapState extends LocationQueryState{
  final String selectedAddress;
  LocationDisplaySelectedLocationMapState(this.selectedAddress);
}

class LocationCancelQueryState extends LocationQueryState{}

class LocationRebuildQueryResultsState extends LocationQueryState{}

class LocationDisplayConfirmedQueryAddressState extends LocationQueryState{
  final String confirmedAddress;
  LocationDisplayConfirmedQueryAddressState(this.confirmedAddress);
}

// ! Edit Location events
class LocationEditLocationState extends LocationState{}

class LocationEditDisableUpdateButtonState extends LocationEditLocationState{}
class LocationEditEnableUpdateButtonState extends LocationEditLocationState{}
class LocationEditChangesSavedState extends LocationEditLocationState{
  final Location updatedLocation;
  LocationEditChangesSavedState(this.updatedLocation);
}
