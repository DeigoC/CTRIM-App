part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
   @override
  List<Object> get props => [];
  const LocationEvent();
}

class LocationTextChangeEvent extends LocationEvent{
  final String streetAddress, townCityAddress, postcode;
  LocationTextChangeEvent({this.streetAddress, this.townCityAddress, this.postcode});
}

class LocationQueryAddressEvent extends LocationEvent{}
class LocationCancelQueryEvent extends LocationQueryAddressEvent{}

class LocationFindAddressEvent extends LocationQueryAddressEvent{
  final String streetAddress, townCityAddress, postcode;
  LocationFindAddressEvent({@required this.streetAddress, @required this.townCityAddress, @required this.postcode});
}

class LocationSelectedQueryAddressEvent extends LocationQueryAddressEvent{
  final String selectedAddress;
  LocationSelectedQueryAddressEvent(this.selectedAddress);
}

class LocationWrongQueryAddressEvent extends LocationQueryAddressEvent{}
class LocationConfirmedQueryAddressEvent extends LocationQueryAddressEvent{}
class LocationImageSelectedEvent extends LocationEvent{
  final File selectedFile;
  LocationImageSelectedEvent(this.selectedFile);
}

class LocationRemoveSelectedImageEvent extends LocationEvent{}

class LocationEditLocationEvent extends LocationEvent{}
class LocationEditTextChangeEvent extends LocationEditLocationEvent{
  final String description, addressLine;
  LocationEditTextChangeEvent({this.description, this.addressLine});
}