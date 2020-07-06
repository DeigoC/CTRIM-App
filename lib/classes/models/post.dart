import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';

enum PostTag { CHURCH, YOUTH, WOMEN }

class Post {
  String id,title,description,body = '',duration,locationID,detailTableHeader;
  DateTime eventDate;
  bool isDateNotApplicable, deleted;

  //List<List<String>> detailTable;
  List<Map<String, String>> detailTable;

  List<PostTag> selectedTags;
  Map<String, String> gallerySources;
  Map<File, String> temporaryFiles;

  Post({
    this.id,
    this.title = '',
    this.body = '',
    this.eventDate,
    this.locationID = '',
    this.detailTableHeader,
    this.isDateNotApplicable = false,
    this.deleted = false,
    this.selectedTags,
    this.gallerySources,
    this.detailTable,
    this.description = '',
    this.temporaryFiles,
    this.duration,
  });

  Post.fromMap(String id, Map<String,dynamic> data)
  :id = id,
  title = data['Title'],
  body = data['Body'],
  duration = data['Duration'],
  eventDate = (data['EventDate'] as Timestamp).toDate(),
  locationID = data['LocationID'],
  detailTable = _toProperFormat(data['DetailTable']) ,
  detailTableHeader = data['DetailTableHeader'],
  deleted = data['Deleted'],
  selectedTags = _setSelectedTags(data['SelectedTags']),
  gallerySources = Map<String,String>.from(data['GallerySources']),
  description = data['Description'],
  isDateNotApplicable = data['IsDateNotApplicable'],
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
      'Duration':duration??'',
      'EventDate': Timestamp.fromDate(eventDate??DateTime.now()),
      'LocationID':locationID,
      'DetailTable':detailTable,
      'DetailTableHeader':detailTableHeader??'',
      'Deleted':deleted,
      'SelectedTags':selectedTagsString,
      'GallerySources':gallerySources,
      'Description':description,
      'IsDateNotApplicable':isDateNotApplicable,
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

  void setTimeOfDay(TimeOfDay tod) {
    if (eventDate == null) {
      eventDate = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, tod.hour, tod.minute);
    } else {
      eventDate = DateTime(
          eventDate.year, eventDate.month, eventDate.day, tod.hour, tod.minute);
    }
  }

  void setEventDate(DateTime date) {
    if (eventDate == null) {
      eventDate = date;
    } else {
      eventDate = DateTime(
          date.year, date.month, date.day, eventDate.hour, eventDate.minute);
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

  String get dateString {
    if (!isDateNotApplicable) {
      return DateFormat('EEEE, dd MMMM yyyy @ h:mm a').format(eventDate);
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
