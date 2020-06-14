class Location{
  String id, imgSrc, addressLine;
  Map<String,double> coordinates;
  List<String> postsUsed;

  Location({
    this.id,
    this.imgSrc,
    this.coordinates,
    this.postsUsed,
    this.addressLine,
  });
}