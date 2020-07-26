import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';
import 'package:collection/collection.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  Post _post = Post(
    selectedTags: [],
    temporaryFiles: {},
    detailTable: [],
    gallerySources: {},
    thumbnails: {},
    deleted: false,
    locationID: '',
  );

  Post _originalPost;
  Post get newPost => _post;
  bool _editMode = false;

  // ! Post Fields - About Tab
  String get eventTitle => _post.title;
  String get postDescription => _post.description;
  String _addressLine = 'PENDING';
  String get addressLine => _addressLine;
  NotusDocument getEditorDoc() {
    if (_post.body == '') {
      List<dynamic> initialWords = [
        {"insert": "Body Starts Here\n"}
      ];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(_post.body);
    return NotusDocument.fromJson(jsonDecoded);
  }

  Map<PostTag, bool> selectedTags = {
    PostTag.CHURCH: false,
    PostTag.YOUTH: false,
    PostTag.WOMEN: false,
  };

  // ! Post Fields - Details Tab
  bool _endDateButtonEnabled = false;
  bool get isEndDateButtonEnabled => _endDateButtonEnabled;
  DateTime get selectedStartDate => _post.startDate??DateTime.now();
  DateTime get selectedEndDate => _post.endDate??DateTime.now();
  DateTime _endDateTOD;

  String get selectedStartDateString => _post.startDate == null? 'Start Date - PENDING': DateFormat('EEE, dd MMM yyyy').format(_post.startDate);
  String get selectedStartTimeString => _post.startDate == null? 'Start Time - PENDING': DateFormat('h:mm a').format(_post.startDate);
  String get selectedEndDateString => _post.endDate == null? 'End Date - PENDING': DateFormat('EEE, dd MMM yyyy').format(_post.endDate);
  String get selectedEndTimeString => _endDateTOD == null? 'End Time - PENDING': DateFormat('h:mm a').format(_endDateTOD);


  bool get isPostDateNotApplicable => _post.isDateNotApplicable;
  bool get isEventAllDay => _post.allDayEvent;
  

  // ! Post Fields - Details Tab - Detail Table
  List<Map<String,String>> get detailTable => _post.detailTable;
  String get detailTableHeader => _post.detailTableHeader;
  String _leadingDetailItem = '', _trailingDetailItem = '';
  void prepareNewDetailListItem() {
    _leadingDetailItem = '';
    _trailingDetailItem = '';
  }

  void prepareDetailItemEdit(Map<String,String> item) {
    _leadingDetailItem = item['Leading'];
    _trailingDetailItem = item['Trailing'];
  }

  // ! Post Fields - Gallery Tab
  Map<File, String> get files => _post.temporaryFiles;
  Map<String, String> get gallerySrc => _post.gallerySources;

  bool get hasAlbumChanged {
    List<String> originalSrc = _originalPost.gallerySources.keys.toList();
    List<String> newSrc = _post.gallerySources.keys.toList();

    if (!DeepCollectionEquality.unordered().equals(originalSrc, newSrc)) {
      return true;
    } else if (_post.temporaryFiles.length != 0) return true;
    return false;
  }

  // ! Mapping events to states

  PostBloc();
  PostBloc.editMode(Post postToEdit) {
    _editMode = true;
   
    _endDateTOD = postToEdit.endDate;
    _endDateButtonEnabled = _endDateTOD != null;

    _post = Post(
        id: postToEdit.id,
        title: postToEdit.title,
        body: postToEdit.body,
        selectedTags: List<PostTag>.from(postToEdit.selectedTags),
        description: postToEdit.description,
        detailTable: List<Map<String,String>>.from(postToEdit.detailTable),
        detailTableHeader: postToEdit.detailTableHeader??'',
        locationID: postToEdit.locationID,
        startDate: postToEdit.startDate,
        isDateNotApplicable: postToEdit.isDateNotApplicable,
        gallerySources: Map.from(postToEdit.gallerySources),
        noOfGalleryItems: postToEdit.noOfGalleryItems,
        endDate: postToEdit.endDate,
        allDayEvent: postToEdit.allDayEvent,
        thumbnails: Map<String,String>.from(postToEdit.thumbnails),
        temporaryFiles: {});

    _originalPost = Post(
      title: _post.title,
      body: _post.body,
      selectedTags: List<PostTag>.from(postToEdit.selectedTags),
      description: _post.description,
      detailTable: List<Map<String,String>>.from(postToEdit.detailTable),
      detailTableHeader: postToEdit.detailTableHeader??'',
      locationID: _post.locationID,
      startDate: postToEdit.startDate,
      isDateNotApplicable: _post.isDateNotApplicable,
      gallerySources: Map.from(_post.gallerySources),
      noOfGalleryItems: postToEdit.noOfGalleryItems,
      endDate: postToEdit.endDate,
      allDayEvent: postToEdit.allDayEvent,
      thumbnails: Map<String,String>.from(postToEdit.thumbnails),
      temporaryFiles: {},
    );

    _post.selectedTags.forEach((tag) {
      selectedTags[tag] = true;
    });
  }

  @override
  PostState get initialState => PostInitial();

  @override
  Stream<PostState> mapEventToState(PostEvent event,) async* {
    if (event is PostTabClickEvent)
      yield* _mapTabClickEventToState(event);
    else if (event is PostTextChangeEvent)
      yield* _mapTextChangeToState(event);
    else if (event is PostDepartmentClickEvent)
      yield* _mapDepartmentClickToState(event);
    else if (event is PostScheduleTabEvent||event is PostSelectedLocationEvent) yield* _mapScheduleTabEventsToState(event);
    else if (event is PostSaveBodyDocumentEvent) {
      _post.body = event.bodyContent;
      yield PostUpdateBodyState();
      yield* _canEnableSaveButton();
    } else if (event is PostDetailListEvent)
      yield* _mapDetailListEventToState(event);
    else if (event is PostGalleryEvent) yield* _mapGalleryEventsToState(event);
  }

  Stream<PostState> _mapGalleryEventsToState(PostGalleryEvent event) async* {
    if (event is PostFilesReceivedEvent){
      yield PostGalleryState();
      yield PostFilesReceivedState();
    }else if (event is PostFilesRemoveSelectedEvent) {
      event.selectedFiles.forEach((file) {
        _post.temporaryFiles.remove(file);
      });
      yield PostFilesReceivedState(); 
    } else if (event is PostRemoveSelectedFilesAndSrcEvent) {
      event.selectedFilesAndSrcs.forEach((src) {
        if (_post.gallerySources.keys.contains(src)) {
          _post.gallerySources.remove(src);
        } else {
          _post.temporaryFiles.removeWhere((key, value) => key.path.compareTo(src) == 0);
        }
      });
      yield PostFilesReceivedState();
    }else if(event is PostDiscardGalleryChnagesEvent){
      _post.temporaryFiles.clear();
      _post.gallerySources = Map.from(_originalPost.gallerySources);
    }
  }

  Stream<PostState> _mapDetailListEventToState(PostDetailListEvent event) async* {
    if (event is PostDetailListReorderEvent) {
      int newIndex = event.newIndex;
      if (newIndex >= _post.detailTable.length) newIndex = _post.detailTable.length - 1;
      var temp = _post.detailTable.removeAt(event.oldIndex);
      _post.detailTable.insert(newIndex, temp);
      yield PostDetailListReorderState();
      yield PostDetailListState();
    } else if (event is PostDetailListTextChangeEvent) {
      _leadingDetailItem = event.leading ?? _leadingDetailItem;
      _trailingDetailItem = event.trailing ?? _trailingDetailItem;
      if (_leadingDetailItem.isNotEmpty || _trailingDetailItem.isNotEmpty)
        yield PostDetailListSaveEnabledState();
      else
        yield PostDetailListSaveDisabledState();
    } else if (event is PostDetailListItemRemovedEvent) {
      _post.detailTable.remove(event.item);
      yield PostDetailListReorderState();
    } else if (event is PostDetailListAddItemEvent) {
      _post.detailTable.add({'Leading':_leadingDetailItem, 'Trailing':_trailingDetailItem});
      //_post.detailTable.add([_leadingDetailItem, _trailingDetailItem]);
      yield PostDetailListReorderState();
    } else if (event is PostDetailListSaveEditEvent) {
      _post.detailTable[event.itemIndex] = {
        'Leading':_leadingDetailItem,
        'Trailing':_trailingDetailItem
    };
    }
  }
  
  Stream<PostState> _mapScheduleTabEventsToState(PostEvent event) async* {
    if (event is PostSetStartPostDateEvent) yield _setStartDate(event);
    else if (event is PostSetStartPostTimeEvent) yield _setStartTime(event);
    else if(event is PostSetEndPostDateEvent) yield _setEndDate(event);
    else if(event is PostSetEndPostTimeEvent) yield* _setEndTime(event);

    // * All day post stuff
    else if(event is PostAllDayDateClickEvent){
      _post.allDayEvent = !_post.allDayEvent;
      yield PostScheduleState();
    }
    
    // * Date not applicable
    else if (event is PostDateNotApplicableClickEvent) {
      if (_post.isDateNotApplicable) _post.isDateNotApplicable = false;
      else  _post.isDateNotApplicable = true;
      yield PostScheduleState();
    } 
    
    // * Selected Location
    else if (event is PostSelectedLocationEvent) {
      _post.locationID = event.locationID;
      _addressLine = event.addressLine;
      yield PostLocationSelectedState();
    }
    yield* _canEnableSaveButton();
  }

  PostScheduleState _setStartDate(PostSetStartPostDateEvent event){
    if (event.selectedDate != null){
        _post.setStartDate(event.selectedDate);
        _post.endDate = null;
        _endDateTOD = null;
        _endDateButtonEnabled = false;
        if(_post.endDate == null) _endDateButtonEnabled = true;
      }
    return PostScheduleState();
  }

  PostScheduleState _setStartTime(PostSetStartPostTimeEvent event){
    if(event.selectedTOD != null){
         _post.setStartTimeOfDay(event.selectedTOD);
        _post.endDate = null;
        _endDateTOD = null;
        _endDateButtonEnabled = false;
        if(_post.endDate == null) _endDateButtonEnabled = true;
      } 
    return PostScheduleState();
  }

  PostScheduleState _setEndDate(PostSetEndPostDateEvent event){
    if(event.selectedDate != null) _post.setEndDate(event.selectedDate);
      _endDateTOD = null;
    return  PostScheduleState();
  }

  Stream<PostState> _setEndTime(PostSetEndPostTimeEvent event) async*{
    if(event.selectedTOD != null){
         _post.setEndTimeOfDay(event.selectedTOD);
          _endDateTOD = DateTime(DateTime.now().year, DateTime.now().month, 
          DateTime.now().day, event.selectedTOD.hour, event.selectedTOD.minute);
          if(_isStartTimeBeforeEndTime()) yield PostScheduleState(); 
          else{
            _endDateTOD = null;
            yield PostEndDateNotAcceptedState();
          }
      }
  }

  bool _isStartTimeBeforeEndTime(){
    if(_post.startDate.isBefore(_post.endDate)) return true;
    return false;
  }

  Stream<PostState> _mapDepartmentClickToState(PostDepartmentClickEvent event) async* {
    if (event.selected) {
      _post.selectedTags.add(event.department);
    } else {
      _post.selectedTags.remove(event.department);
    }
    selectedTags[event.department] = event.selected;
    bool selected = event.selected;
    switch (event.department) {
      case PostTag.CHURCH:
        if (selected) yield PostDepartmentChurchEnabledState();
        else yield PostDepartmentChurchDisabledState();
        break;

      case PostTag.YOUTH:
        if (selected) yield PostDepartmentYouthEnabledState();
        else yield PostDepartmentYouthDisabledState();
        break;

      case PostTag.WOMEN:
        if (selected) yield PostDepartmentWomenEnabledState();
        else yield PostDepartmentWomenDisabledState();
        break;
    }
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapTextChangeToState(PostTextChangeEvent event) async* {
    _post.title = event.title ?? _post.title;
    _post.description = event.description ?? _post.description;
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _canEnableSaveButton() async* {
    if (_editMode) {
      if (_haveAnyChangedFields() && !_haveAnyEmptyFields()) {
        yield PostEnableSaveButtonState();
      } else{
        yield PostDisableSaveButtonState();
      } 
    } else {
      if (_haveAnyEmptyFields()) {
        yield PostDisableSaveButtonState();
      } else {
        yield PostEnableSaveButtonState();
      }
    }
  }

  bool _haveAnyChangedFields() {
    if (_originalPost.title.compareTo(_post.title) != 0) return true;
    else if (_originalPost.body.compareTo(_post.body) != 0) return true;
    else if (_originalPost.description.compareTo(_post.description) != 0) return true;
    else if (_originalPost.detailTableHeader.compareTo(_post.detailTableHeader) !=0) return true;
    else if (!DeepCollectionEquality().equals(_originalPost.detailTable, _post.detailTable)) return true;
    else if (!DeepCollectionEquality.unordered().equals(_originalPost.selectedTags, _post.selectedTags))return true;
    else if (_originalPost.locationID.compareTo(_post.locationID) != 0)return true;
    else if (_originalPost.isDateNotApplicable != _post.isDateNotApplicable)return true;
    else if(hasAlbumChanged) return true;
    else if(_originalPost.startDate != null || _originalPost.endDate != null){
      if (_originalPost.startDate.compareTo(_post.startDate) != 0 &&!_post.isDateNotApplicable)return true;
      else if(_originalPost.endDate.compareTo(_post.endDate) !=0 && !_post.isDateNotApplicable)return true;
    }
    return false;
  }

  bool _haveAnyEmptyFields() {
    if (_post.title.trim().isEmpty ||
        _post.description.trim().isEmpty ||
        _post.selectedTags.length == 0 ||
        !_isDateFieldValid() ||
        _post.body.isEmpty ||
        _post.locationID.trim().isEmpty) return true;
    return false;
  }

  bool _isDateFieldValid() {
    if (_post.endDate != null && _endDateTOD != null) return true;
    else if(_post.allDayEvent) return true;
    else if(_post.isDateNotApplicable) return true;
    return false;
  }

  Stream<PostState> _mapTabClickEventToState(PostTabClickEvent event) async* {
    switch (event.selectedIndex) {
      case 0:
        yield PostAboutTabClickState();
        break;
      case 1:
        yield PostDetailsTabClickState();
        break;
      case 2:
        yield PostGalleryTabClickState();
        break;
      case 3:
        yield PostUpdatesTabClickState();
        break;
    }
  }
}
