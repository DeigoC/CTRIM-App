import 'package:flutter/material.dart';

class User{
  String id, forename,surname, imgSrc, email, authID, role;
  int adminLevel;
  List<String> likedPosts;
  Map<String, String> socialLinks;
  bool disabled, onDarkTheme;

  String get roleString {
    if(role.trim().isEmpty) return 'N/A';
    return role;
  }

  User({
    this.id, 
    this.forename, 
    this.surname,
    this.socialLinks,
    this.imgSrc,
    this.email,
    this.adminLevel,
    this.likedPosts,
    this.disabled = false,
    this.onDarkTheme = false,
    this.role = '',
    this.authID = '',
  });

  User.fromMap(String id, Map<String,dynamic> data) 
  : id = id,
  forename = data['Forename'],
  surname = data['Surname'],
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
}