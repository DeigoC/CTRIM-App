import 'dart:convert';

import 'package:zefyr/zefyr.dart';

class AboutArticle{

  String id, body, title, locationID, serviceTime, locationPastorUID;
  Map<String, String> gallerySources, socialLinks;
  List<String> _imgSrc =[];

  AboutArticle({
    this.id,
    this.body,
    this.title,
    this.locationID,
    this.serviceTime,
    this.locationPastorUID,
    this.gallerySources,
    this.socialLinks
  });

  AboutArticle.fromMap(String id, Map<String,dynamic> data )
  : id = id,
  body = data['Body'],
  title = data['Title'],
  locationID = data['LocationID'],
  serviceTime = data['ServiceTime'],
  locationPastorUID = data['LocationPastorUID'],
  socialLinks = Map<String,String>.from(data['SocialLinks']),
  gallerySources = Map<String,String>.from(data['GallerySources']);

  toJson(){
    return{
      'Title':title,
      'Body':body,
      'LocationID':locationID,
      'ServiceTime':serviceTime,
      'LocationPastorUID':locationPastorUID,
      'SocialLinks':socialLinks,
      'GallerySources':gallerySources,
    };
  }

  String get firstImage{
    _imgSrc = gallerySources.keys.toList();
    _imgSrc.sort();
    return _imgSrc.first;
  }

  String get secondImage => _imgSrc[1];
  String get thirdImage => _imgSrc[2];

  Map<String, String> get slideShowItems {
    Map<String, String> result = {};
    _imgSrc.sublist(3).forEach((src) {
      result[src] = gallerySources[src];
    });
    return result;
  } 
 
  NotusDocument getBodyDocument(){
    if(body == null || body == ''){
      List<dynamic> initialWords = [
        {"insert": "Body Starts Here\n"}
      ];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(body);
    return NotusDocument.fromJson(jsonDecoded);
  }
}