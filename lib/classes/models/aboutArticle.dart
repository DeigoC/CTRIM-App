class AboutArticle{

  String id, body, title, locationID, serviceTime, locationPastorUID;
  bool aboutPastors;
  Map<String, String> gallerySources;

  AboutArticle({
    this.id,
    this.body,
    this.title,
    this.locationID,
    this.serviceTime,
    this.locationPastorUID,
    this.gallerySources,
    this.aboutPastors,
  });
}