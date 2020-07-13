import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class User{
  String id, forename,surname, body, imgSrc, email, authID;
  int adminLevel;
  List<String> likedPosts;
  bool disabled, onDarkTheme;

  User({
    this.id, 
    this.forename, 
    this.surname,
    this.body,
    this.imgSrc,
    this.email,
    this.adminLevel,
    this.likedPosts,
    this.disabled = false,
    this.onDarkTheme = false,
    this.authID = '',
  });

  User.fromMap(String id, Map<String,dynamic> data) 
  : id = id,
  forename = data['Forename'],
  surname = data['Surname'],
  authID = data['AuthID'],
  adminLevel = data['AdminLevel'],
  body = data['Body'],
  disabled = data['Disabled'],
  imgSrc = data['ImgSrc'],
  likedPosts = List.from(data['LikedPosts'], growable: true),
  onDarkTheme = data['OnDarkTheme'],
  email = data['Email'];

  toJson(){
    return {
      'AdminLevel':adminLevel,
      'AuthID':authID,
      'Body':body,
      'Disabled':disabled,
      'Email':email,
      'Forename':forename,
      'ImgSrc':imgSrc??'',
      'LikedPosts':likedPosts??[],
      'OnDarkTheme':onDarkTheme,
      'Surname':surname,
    };
  }

  CircleAvatar buildAvatar(){
    String avatarName = forename[0].toUpperCase() + surname[0].toUpperCase();
    if(imgSrc=='' || imgSrc==null){
      return CircleAvatar(
        backgroundColor: Colors.grey,
        child: Text(avatarName),
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(imgSrc),
    );
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