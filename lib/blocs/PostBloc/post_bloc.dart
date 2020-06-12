import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {

  bool _areAnyTextFieldsEmpty = true;
  Post _post = Post();

  // ! Post Fields - About Tab
  String get eventTitle => _post.title; 
  NotusDocument getEditorDoc(){
    if(_post.body == null){
      List<dynamic> initialWords = [{"insert":"Body Starts here\n"}];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(_post.body);
    return NotusDocument.fromJson(jsonDecoded);
    
  }

  Map<Department, bool> selectedTags = {
    Department.CHURCH : false,
    Department.YOUTH : false,
    Department.WOMEN : false,
  };

  // ! Post Fields - Details Tab
  DateTime get getSelectedDate => _post.getEventDate;
  String get getSelectedDateString => _post.getEventDate == null ? 'Pending' :
  DateFormat('EEE, dd MMM yyyy').format(_post.getEventDate);
  bool get getIsDateNotApplicable => _post.isDateNotApplicable;

  String get getSelectedTimeString => _post.getEventDate == null ? 'Pending' :
  DateFormat('h:mm a').format(_post.getEventDate);

  List<List<String>> get detailTable => _post.detailTable;
 String _leadingDetailItem ='', _trailingDetailItem ='';
 void prepareNewDetailListItem(){
   _leadingDetailItem ='';
   _trailingDetailItem ='';
 }

 void prepareDetailItemEdit(List<String> item){
   _leadingDetailItem = item[0];
   _trailingDetailItem = item[1];
 }
  
  // ! Post Fields - Gallery Tab
  Map<File,String> get files => _post.temporaryFiles;


  // ! Bloc Stuff
  
  @override
  PostState get initialState => PostInitial();

  @override
  Stream<PostState> mapEventToState(
    PostEvent event,
  ) async* {
    if(event is PostTabClickEvent){
       yield* _mapTabClickEventToState(event);
    }

    else if(event is PostTextChangeEvent){
      yield* _mapTextChangeToState(event);
    }

    else if(event is PostDepartmentClickEvent){
      yield* _mapDepartmentClickToState(event);
    }

    else if(event is PostScheduleTabEvent){
      yield* _mapScheduleTabEventsToState(event);
    }

    else if(event is PostSaveBodyDocumentEvent){
      _post.body = event.bodyContent;
      yield PostUpdateBodyState();
      yield* _canEnableSaveButton();
    }

    else if (event is PostDetailListEvent){
      yield* _mapDetailListEventToState(event);
    }

    else if(event is PostGalleryEvent){
      yield* _mapGalleryEventsToState(event);
    }
  }
  
  Stream<PostState> _mapGalleryEventsToState(PostGalleryEvent event) async*{
    if(event is PostFilesReceivedEvent) yield PostFilesReceivedState();
    else if(event is PostFilesRemoveSelectedEvent){
      event.selectedFiles.forEach((file) {
        _post.temporaryFiles.remove(file);
      });
      yield PostFilesReceivedState(); // TODO may have to change this
    }
  }

  Stream<PostState> _mapDetailListEventToState(PostDetailListEvent event) async*{
    if(event is PostDetailListReorderEvent){
      int newIndex = event.newIndex;
      // ! when at max or more, set to max
      if(newIndex >= _post.detailTable.length) newIndex = _post.detailTable.length - 1;
      var temp = _post.detailTable.removeAt(event.oldIndex);
      _post.detailTable.insert(newIndex, temp);
      yield PostDetailListReorderState();
      yield PostDetailListState();
    }else if(event is PostDetailListTextChangeEvent){
      _leadingDetailItem = event.leading ?? _leadingDetailItem;
      _trailingDetailItem = event.trailing ?? _trailingDetailItem;
      if(_leadingDetailItem.isNotEmpty || _trailingDetailItem.isNotEmpty) yield PostDetailListSaveEnabledState();
      else yield PostDetailListSaveDisabledState();
    }else if(event is PostDetailListItemRemovedEvent){
      _post.detailTable.remove(event.item);
      yield PostDetailListReorderState();
    }else if(event is PostDetailListAddItemEvent){
      _post.detailTable.add([_leadingDetailItem, _trailingDetailItem]);
      yield PostDetailListReorderState();
    }else if(event is PostDetailListSaveEditEvent){
      _post.detailTable[event.itemIndex] = [_leadingDetailItem, _trailingDetailItem];
    }
  }

  Stream<PostState> _mapScheduleTabEventsToState(PostScheduleTabEvent event) async*{
    if(event is PostSelectPostDateEvent){
      yield PostSelectDateState();
    }else if (event is PostSelectPostTimeEvent){
      yield PostSelectTimeState();
    }else if(event is PostSetPostDateEvent){
      if(event.selectedDate != null) _post.setEventDate(event.selectedDate);
      yield PostDateSelectedState();
    }else if (event is PostSetPostTimeEvent){
      _post.setTimeOfDay(event.selectedTOD);
       yield PostDateSelectedState();// ? Need to change this name perhaps
    }else if(event is PostDateNotApplicableClick){
      if(_post.isDateNotApplicable){
        _post.isDateNotApplicable = false;
        yield PostDateIsNOTApplicableState();
      }else{
        _post.isDateNotApplicable = true;
        yield PostDateIsApplicableState();
      }
    }
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapDepartmentClickToState(PostDepartmentClickEvent event) async*{
    if(event.selected){
      _post.selectedTags.add(event.department);
    }else{
      _post.selectedTags.remove(event.department);
    }

    selectedTags[event.department] = event.selected;
    bool selected = event.selected;
    switch(event.department){
      case Department.CHURCH:
        if(selected) yield PostDepartmentChurchEnabledState();
        else yield PostDepartmentChurchDisabledState();
        break;

      case Department.YOUTH:
        if(selected) yield PostDepartmentYouthEnabledState();
        else yield PostDepartmentYouthDisabledState();
        break;

      case Department.WOMEN:
        if(selected) yield PostDepartmentWomenEnabledState();
        else yield PostDepartmentWomenDisabledState();
        break;
    }
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapTextChangeToState(PostTextChangeEvent event) async*{
    _post.title = event.title?? _post.title;
    if(_post.title.trim().isEmpty)_areAnyTextFieldsEmpty = true;
    else _areAnyTextFieldsEmpty = false;
     yield* _canEnableSaveButton();
  }

  Stream<PostState> _canEnableSaveButton() async*{
    if(_areAnyTextFieldsEmpty || _post.selectedTags.length == 0 ||
    _post.getEventDate == null|| _post.body.isEmpty){
       yield PostDisableSaveButtonState();
    }else{
      yield PostEnableSaveButtonState();
    }
  }

  Stream<PostState> _mapTabClickEventToState(PostTabClickEvent event) async*{
    switch(event.selectedIndex){
      case 0: yield PostAboutTabClickState();
      break;
      case 1: yield PostDetailsTabClickState();
      break;
      case 2: yield PostGalleryTabClickState();
      break;
      case 3: yield PostUpdatesTabClickState();
      break;
    }
  }

}
