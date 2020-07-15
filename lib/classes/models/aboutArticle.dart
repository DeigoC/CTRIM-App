import 'dart:convert';

import 'package:zefyr/zefyr.dart';

class AboutArticle{

  String id, body, title, locationID, serviceTime, locationPastorUID;
  Map<String, String> gallerySources;

  AboutArticle({
    this.id,
    this.body,
    this.title,
    this.locationID,
    this.serviceTime,
    this.locationPastorUID,
    this.gallerySources,
  });

  AboutArticle.fromMap(String id, Map<String,dynamic> data )
  : id = id,
  body = data['Body'],
  title = data['Title'],
  locationID = data['LocationID'],
  serviceTime = data['ServiceTime'],
  locationPastorUID = data['LocationPastorUID'],
  gallerySources = Map<String,String>.from(data['GallerySources']);

  toJson(){
    return{
      'Title':title,
      'Body':body,
      'LocationID':locationID,
      'ServiceTime':serviceTime,
      'LocationPastorUID':locationPastorUID,
      'GallerySources':gallerySources,
    };
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