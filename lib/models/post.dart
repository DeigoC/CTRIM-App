import 'dart:io';
import 'package:flutter/material.dart';

enum Department{
  CHURCH, YOUTH, WOMEN
}

class Post{
  String id, title, description, body = '', duration, locationID;
  DateTime _eventDate;
  DateTime get getEventDate => _eventDate;
  bool isDateNotApplicable = false;
  List<List<String>> detailTable = [];
  Map<String,String> gallerySources;

  List<Department> selectedTags =[];

  Map<File,String> temporaryFiles = {};

  Post({
    this.id,
    this.title,
    this.body,
    this.locationID,
    this.isDateNotApplicable,
    this.selectedTags,
    this.gallerySources,
    this.detailTable,
    this.description
  });

  void setTimeOfDay(TimeOfDay tod){
    if(_eventDate == null){
      _eventDate = DateTime(DateTime.now().year, DateTime.now().month, 
      DateTime.now().day, tod.hour, tod.minute);
    }else{
      _eventDate = DateTime(_eventDate.year, _eventDate.month, _eventDate.day
      ,tod.hour, tod.minute);
    }
  }

  void setEventDate(DateTime date){
    if(_eventDate == null){
      _eventDate = date;
    }else{
      _eventDate = DateTime(date.year, date.month, date.day, _eventDate.hour, _eventDate.minute);
    }
  }
  
  String getTagsString(){
    String result = '';
    selectedTags.forEach((tag) {
      result += ' ' + _tagToString(tag) + ',';
    });
    return result;
  }

  String _tagToString(Department dept){
    switch(dept){
      case Department.CHURCH: return 'CHURCH';
      case Department.YOUTH: return 'YOUTH';
      case Department.WOMEN: return 'WOMEN';
    }
    return '';
  }

 }