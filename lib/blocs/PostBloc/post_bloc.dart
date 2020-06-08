import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';
part 'post_event.dart';
part 'post_state.dart';

enum Department{
  CHURCH, YOUTH, WOMEN
}

class PostBloc extends Bloc<PostEvent, PostState> {

  Map<Department, bool> selectedDepartments = {
    Department.CHURCH : false,
    Department.YOUTH : false,
    Department.WOMEN : false,
  };
  bool _areAnyTextFieldsEmpty = true;

  // ! Post Fields - About Tab
  String _eventTitle ='', _eventBody ='';
  String get eventTitle => _eventTitle; 
  String get eventBody => _eventBody;
  String eventBodyContent;
  NotusDocument getEditorDoc(){
    if(eventBodyContent == null){
      List<dynamic> initialWords = [{"insert":"Body Starts here\n"}];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(eventBodyContent);
    return NotusDocument.fromJson(jsonDecoded);
  }

  // ! Post Fields - Details Tab
  DateTime _selectedEventDate;
  DateTime get getSelectedDate => _selectedEventDate;
  String get getSelectedDateString => _selectedEventDate == null ? 'Pending' :
  DateFormat('EEE, dd MMM yyyy').format(_selectedEventDate);
  bool _isDateNotApplicable = false;
  bool get getIsDateNotApplicable => _isDateNotApplicable;

  TimeOfDay _selectedEventTOD;
  String get getSelectedTimeString => _selectedEventTOD == null ? 'Pending' :
  DateFormat('h:mm a').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
  _selectedEventTOD.hour, _selectedEventTOD.minute));

  List<List<String>> _detailTable = [];
 

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
      yield PostUpdateBodyState();
    }
  }

  Stream<PostState> _mapScheduleTabEventsToState(PostScheduleTabEvent event) async*{
    if(event is PostSelectPostDateEvent){
      yield PostSelectDateState();
    }else if (event is PostSelectPostTimeEvent){
      yield PostSelectTimeState();
    }else if(event is PostSetPostDateEvent){
      if(event.selectedDate != null) _selectedEventDate = event.selectedDate;
      yield PostDateSelectedState();
    }else if (event is PostSetPostTimeEvent){
      if(event.selectedTOD != null) _selectedEventTOD = event.selectedTOD;
       yield PostDateSelectedState();// ? Need to change this name perhaps
    }else if(event is PostDateNotApplicableClick){
      if(_isDateNotApplicable){
        _isDateNotApplicable = false;
        yield PostDateIsNOTApplicableState();
      }else{
        _isDateNotApplicable = true;
        yield PostDateIsApplicableState();
      }
    }


    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapDepartmentClickToState(PostDepartmentClickEvent event) async*{
    selectedDepartments[event.department] = event.selected;
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
    _eventTitle = event.title?? _eventTitle;
    _eventBody = event.body?? _eventBody;
    if(_eventTitle.trim().isEmpty ||_eventBody.trim().isEmpty){
      _areAnyTextFieldsEmpty = true;
    }else{
      _areAnyTextFieldsEmpty = false;
    }
     yield* _canEnableSaveButton();
  }

  Stream<PostState> _canEnableSaveButton() async*{
    if(_areAnyTextFieldsEmpty || !selectedDepartments.values.contains(true) ||
    _selectedEventTOD == null || _selectedEventDate == null){
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

  Delta() {}
}
