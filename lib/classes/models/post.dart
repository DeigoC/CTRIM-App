import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';

enum PostTag { CHURCH, YOUTH, WOMEN }

class Post {
  String id,title,description,body = '',locationID,detailTableHeader;
  DateTime startDate, endDate;
  bool isDateNotApplicable, allDayEvent, deleted;
  int noOfGalleryItems;

  //List<List<String>> detailTable;
  List<Map<String, String>> detailTable;

  List<PostTag> selectedTags;
  Map<String, String> gallerySources, thumbnails;
  Map<File, String> temporaryFiles;

  Post({
    this.id,
    this.title = '',
    this.body = '',
    this.startDate,
    this.locationID = '',
    this.detailTableHeader,
    this.isDateNotApplicable = false,
    this.deleted = false,
    this.selectedTags,
    this.gallerySources,
    this.detailTable,
    this.description = '',
    this.temporaryFiles,
    this.noOfGalleryItems = 0,
    this.endDate,
    this.thumbnails,
    this.allDayEvent= false,
  });

  Post.fromMap(String id, Map<String,dynamic> data)
  :id = id,
  title = data['Title'],
  body = data['Body'],
  startDate = (data['StartDate'] as Timestamp).toDate(),
  endDate = (data['EndDate'] as Timestamp).toDate(),
  locationID = data['LocationID'],
  detailTable = _toProperFormat(data['DetailTable']) ,
  detailTableHeader = data['DetailTableHeader'],
  deleted = data['Deleted'],
  selectedTags = _setSelectedTags(data['SelectedTags']),
  gallerySources = Map<String,String>.from(data['GallerySources']),
  thumbnails =  Map<String,String>.from(data['Thumbnails']),
  description = data['Description'],
  isDateNotApplicable = data['IsDateNotApplicable'],
  noOfGalleryItems = data['NoOfGalleryItems'],
  allDayEvent = data['AllDayEvent'],
  temporaryFiles = {};

  static List<Map<String,String>> _toProperFormat(dynamic data){
    List<Map<String,String>> result = [];
    data.forEach((item) => result.add({
      'Leading':item['Leading'],
      'Trailing':item['Trailing'],
    }));
    return result;
  }

  toJson(){
    return {
      'Title':title,
      'Body':body,
      'StartDate': Timestamp.fromDate(startDate??DateTime.now()),
      'EndDate':Timestamp.fromDate(endDate??DateTime.now()),
      'LocationID':locationID,
      'DetailTable':detailTable,
      'DetailTableHeader':detailTableHeader??'',
      'Deleted':deleted??false,
      'SelectedTags':selectedTagsString,
      'GallerySources':gallerySources,
      'Thumbnails':thumbnails,
      'Description':description,
      'IsDateNotApplicable':isDateNotApplicable??false,
      'NoOfGalleryItems':noOfGalleryItems,
      'AllDayEvent':allDayEvent,
    };
  }
  
  static List<PostTag> _setSelectedTags(dynamic data){
    List<PostTag> result = [];
    data.forEach((postString) => result.add(_stringToTag(postString)));
    return result;
  }

  static PostTag _stringToTag(String s){
    switch(s){
      case 'Women': return PostTag.WOMEN;
      case 'Youth':return PostTag.YOUTH;
      case 'Church':return PostTag.CHURCH;
    }
    return null;
  }

  void setStartTimeOfDay(TimeOfDay tod) {
    if(tod != null){
      if (startDate == null) {
      startDate = DateTime(DateTime.now().year, DateTime.now().month,DateTime.now().day, tod.hour, tod.minute);
      } else {
        startDate = DateTime(startDate.year, startDate.month, startDate.day, tod.hour, tod.minute);
      }
    }
  }

  void setStartDate(DateTime date) {
    if (startDate == null) {
      startDate = date;
    } else {
      startDate = DateTime(date.year, date.month, date.day, startDate.hour, startDate.minute);
    }
  }

  void setEndTimeOfDay(TimeOfDay tod) {
    if(tod != null){
      if (endDate == null) {
      endDate = DateTime(DateTime.now().year, DateTime.now().month,DateTime.now().day, tod.hour, tod.minute);
      } else {
        endDate = DateTime(endDate.year, endDate.month, endDate.day, tod.hour, tod.minute);
      }
    }
  }

  void setEndDate(DateTime date) {
    if (endDate == null) {
      endDate = date;
    } else {
      endDate = DateTime(date.year, date.month, date.day, endDate.hour, endDate.minute);
    }
  }

  NotusDocument getBodyDoc() {
    var jsonDecoded = jsonDecode(body);
    return NotusDocument.fromJson(jsonDecoded);
  }

  String getTagsString() {
    String result = '';
    selectedTags.forEach((tag) {
      result += ' ' + _tagToString(tag) + ',';
    });
    return result;
  }

  String _tagToString(PostTag dept) {
    switch (dept) {
      case PostTag.CHURCH:
        return 'CHURCH';
      case PostTag.YOUTH:
        return 'YOUTH';
      case PostTag.WOMEN:
        return 'WOMEN';
    }
    return '';
  }

  String get firstImageSrc{
    if(gallerySources.length != 0){
      List<String> srcs = gallerySources.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));
      for (var i = 0; i < srcs.length; i++) {
        String src = srcs.elementAt(i);
        if(gallerySources[src]=='img') return src;
      }
    } 
    return null;
  }

  File get firstFileImage{
    if(temporaryFiles.length != 0){
      for (var i = 0; i < temporaryFiles.length; i++) {
        if(temporaryFiles.values.elementAt(i) == 'img'){
          return temporaryFiles.keys.elementAt(i);
        }
      }
    }
    return null;
  }

  String get dateString {
    if (!isDateNotApplicable) {
      String result = 'Start - ' + DateFormat('EEEE, dd MMMM yyyy @ h:mm a').format(startDate);
      result += '\nEnd - ' + DateFormat('EEEE, dd MMMM yyyy @ h:mm a').format(endDate);
      if(allDayEvent) result += '\nAll Day';
      return result;
    }
    return 'N/A';
  }

  List<String> get selectedTagsString {
    return selectedTags.map((tag) {
      switch (tag) {
        case PostTag.YOUTH:
          return 'Youth';
        case PostTag.WOMEN:
          return 'Women';
        case PostTag.CHURCH:
          return 'Church';
      }
      return null;
    }).toList();
  }
}
