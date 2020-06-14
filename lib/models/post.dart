import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';

enum Department{
  CHURCH, YOUTH, WOMEN
}

class Post{
  String id, title, description, body = '', duration, locationID, detailTableHeader;
  DateTime eventDate;
  bool isDateNotApplicable = false;
  List<List<String>> detailTable;
  Map<String,String> gallerySources;
  List<Department> selectedTags;
  Map<File,String> temporaryFiles;

  Post({
    this.id,
    this.title ='',
    this.body = '',
    this.eventDate,
    this.locationID='',
    this.detailTableHeader,
    this.isDateNotApplicable = false,
    this.selectedTags,
    this.gallerySources,
    this.detailTable,
    this.description ='',
    this.temporaryFiles,
  });

  void setTimeOfDay(TimeOfDay tod){
    if(eventDate == null){
      eventDate = DateTime(DateTime.now().year, DateTime.now().month, 
      DateTime.now().day, tod.hour, tod.minute);
    }else{
      eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day
      ,tod.hour, tod.minute);
    }
  }

  void setEventDate(DateTime date){
    if(eventDate == null){
      eventDate = date;
    }else{
      eventDate = DateTime(date.year, date.month, date.day, eventDate.hour, eventDate.minute);
    }
  }

   NotusDocument getBodyDoc(){
    var jsonDecoded = jsonDecode(body);
    return NotusDocument.fromJson(jsonDecoded);
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

  String get dateString{
    if(!isDateNotApplicable){
      return DateFormat('EEEE, dd MMMM yyyy @ h:mm a').format(eventDate);
    }
    return 'N/A';
  }

  List<String> get selectedTagsString{
    return selectedTags.map((tag){
      switch(tag){
        case Department.YOUTH: return 'Youth';
        case Department.WOMEN: return 'Women';
        case Department.CHURCH: return 'Church';
      }
      return null;
    }).toList();
  }

 }