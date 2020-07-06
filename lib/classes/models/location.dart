class Location{
  String id, imgSrc, addressLine, description;
  Map<String,double> coordinates;
  List<String> postsUsed;
  bool deleted;
    
  String getAddressLine(){
    if(id.compareTo('0')==0) return 'N/A';
    return addressLine;
  }

  Location({
    this.id,
    this.imgSrc,
    this.coordinates,
    this.postsUsed,
    this.addressLine,
    this.description,
    this.deleted = false,
  });

  Location.fromMap(String id, Map<String, dynamic> data)
  : id = id,
  imgSrc = data['ImgSrc'],
  coordinates = Map<String,double>.from(data['Coordinates']),
  postsUsed = List<String>.from(data['PostsUsed']),
  addressLine = data['AddressLine'],
  description = data['Description'],
  deleted = data['Deleted'];

  toJson(){
    return{
      'ImgSrc':imgSrc??'',
      'Coordinates':coordinates,
      'PostsUsed':postsUsed??[],
      'AddressLine':addressLine,
      'Description':description,
      'Deleted':deleted,
    };
  }
}