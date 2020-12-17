import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class User{
  String id, forename,surname, imgSrc, email, authID, role, body;
  int adminLevel;
  List<String> likedPosts;
  Map<String, String> socialLinks;
  bool disabled, onDarkTheme;

  User({
    this.id, 
    this.forename, 
    this.surname,
    this.socialLinks,
    this.imgSrc,
    this.email,
    this.adminLevel,
    this.likedPosts,
    this.body,
    this.disabled = false,
    this.onDarkTheme = false,
    this.role = '',
    this.authID = '',
  });

  User.fromMap(String id, Map<String,dynamic> data) 
  : id = id,
  forename = data['Forename'],
  surname = data['Surname'],
  this.body = data['Body'],
  role = data['Role'],
  authID = data['AuthID'],
  adminLevel = data['AdminLevel'],
  socialLinks = Map<String,String>.from(data['SocialLinks']),
  disabled = data['Disabled'],
  imgSrc = data['ImgSrc'],
  likedPosts = List.from(data['LikedPosts'], growable: true),
  onDarkTheme = data['OnDarkTheme'],
  email = data['Email'];

  toJson(){
    return {
      'AdminLevel':adminLevel,
      'AuthID':authID,
      'SocialLinks':socialLinks??{},
      'Disabled':disabled,
      'Email':email,
      'Forename':forename,
      'ImgSrc':imgSrc??'',
      'LikedPosts':likedPosts??[],
      'OnDarkTheme':onDarkTheme,
      'Role':role,
      'Surname':surname,
      'Body':body,
    };
  }

  CircleAvatar buildAvatar(BuildContext context){
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

  String get roleString {
    if(role.trim().isEmpty) return 'N/A';
    return role;
  }

  NotusDocument getBodyDoc() {
    var jsonDecoded = jsonDecode(body);
    return NotusDocument.fromJson(jsonDecoded);
  }

}