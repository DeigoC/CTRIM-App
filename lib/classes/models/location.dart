class Location{
  String id, imgSrc, addressLine, description;
  Map<String,double> coordinates;
  List<String> searchArray;
  bool deleted;
    
  String getAddressLine(){
    if(id.compareTo('0')==0) return 'N/A';
    return addressLine;
  }

  Location({
    this.id,
    this.imgSrc='',
    this.coordinates,
    this.addressLine ='',
    this.description ='',
    this.deleted = false,
    this.searchArray,
  });

  Location.fromMap(String id, Map<String, dynamic> data)
  : id = id,
  imgSrc = data['ImgSrc'],
  coordinates = Map<String,double>.from(data['Coordinates']),
  addressLine = data['AddressLine'],
  description = data['Description'],
  searchArray = List.from(data['SearchArray']),
  deleted = data['Deleted'];

  toJson(){
    return{
      'ImgSrc':imgSrc??'',
      'Coordinates':coordinates,
      'AddressLine':addressLine,
      'Description':description,
      'SearchArray':searchArray,
      'Deleted':deleted,
    };
  }
}