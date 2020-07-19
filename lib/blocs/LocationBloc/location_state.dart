part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object> get props => [];
  const LocationState();
}

class LocationInitial extends LocationState {}

// ! Button states
class LocationButtonState extends LocationState {}

class LocationDisableFindButtonState extends LocationButtonState {}

class LocationEnableFindButtonState extends LocationButtonState {}

// ! Images states
class LocationSetNewLocationImageState extends LocationState {
  final File locationFile;
  LocationSetNewLocationImageState(this.locationFile);
}

class LocationRemoveSelectedImageState extends LocationState {}

// !  Query Address / Add Location states
class LocationCreatedState extends LocationState{}

class LocationQueryState extends LocationState {}

class LocationDisplayQueryResultsState extends LocationQueryState {
  final List<String> results;
  LocationDisplayQueryResultsState(this.results);
}

class LocationDisplaySelectedLocationMapState extends LocationQueryState {
  final String selectedAddress;
  LocationDisplaySelectedLocationMapState(this.selectedAddress);
}

class LocationCancelQueryState extends LocationQueryState {}

class LocationRebuildQueryResultsState extends LocationQueryState {}

class LocationDisplayConfirmedQueryAddressState extends LocationQueryState {
  final String confirmedAddress;
  LocationDisplayConfirmedQueryAddressState(this.confirmedAddress);
}

// ! Edit Location events
class LocationEditLocationState extends LocationState {}

class LocationEditDisableUpdateButtonState extends LocationEditLocationState {}

class LocationEditEnableUpdateButtonState extends LocationEditLocationState {}

class LocationEditAttemptToUpdateState extends LocationEditLocationState {}

class LocationEditUpdateCompleteState extends LocationEditLocationState{}
