class Location{
  String id, imgSrc, addressLine, description;
  Map<String,double> coordinates;
  List<String> postsUsed;
    
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
    this.description
  });
}