class Location{
  String id, imgSrc, addressLine, description;
  Map<String,double> coordinates;
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
  });

  Location.fromMap(String id, Map<String, dynamic> data)
  : id = id,
  imgSrc = data['ImgSrc'],
  coordinates = Map<String,double>.from(data['Coordinates']),
  addressLine = data['AddressLine'],
  description = data['Description'],
  deleted = data['Deleted'];

  toJson(){
    return{
      'ImgSrc':imgSrc??'',
      'Coordinates':coordinates,
      'AddressLine':addressLine,
      'Description':description,
      'Deleted':deleted,
    };
  }
}