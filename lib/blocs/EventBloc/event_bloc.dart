import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'event_event.dart';
part 'event_state.dart';

enum Department{
  CHURCH, YOUTH, WOMEN
}

class EventBloc extends Bloc<EventEvent, EventState> {

  Map<Department, bool> selectedDepartments = {
    Department.CHURCH : false,
    Department.YOUTH : false,
    Department.WOMEN : false,
  };
  bool _areAnyTextFieldsEmpty = true;

  // * Event Fields
  DateTime _selectedEventDate;
  DateTime get getSelectedDate => _selectedEventDate;
  String get getSelectedDateString => _selectedEventDate == null ? 'Pending' : _selectedEventDate.toString();

  TimeOfDay _selectedEventTOD;
  String get getSelectedTimeString => _selectedEventTOD == null ? 'Pending' : _selectedEventTOD.toString();
  
  String _eventTitle ='', _eventBody ='';
  String get eventTitle => _eventTitle; 
  String get eventBody => _eventBody;
  
  @override
  EventState get initialState => EventInitial();

  @override
  Stream<EventState> mapEventToState(
    EventEvent event,
  ) async* {
    if(event is TabClickEvent){
       yield* _mapTabClickEventToState(event);
    }

    else if(event is TextChangeEvent){
      yield* _mapTextChangeToState(event);
    }

    else if(event is DepartmentClickEvent){
      yield* _mapDepartmentClickToState(event);
    }

    else if(event is ScheduleTabEvent){
      yield* _mapScheduleTabEventsToState(event);
    }
  }

  Stream<EventState> _mapScheduleTabEventsToState(ScheduleTabEvent event) async*{
    if(event is SelectEventDateEvent){
      yield EventSelectDateState();
    }else if (event is SelectEventTimeEvent){
      yield EventSelectTimeState();
    }else if(event is SetEventDateEvent){
      if(event.selectedDate != null) _selectedEventDate = event.selectedDate;
      yield EventDateSelectedState();
    }else if (event is SetEventTimeEvent){
      if(event.selectedTOD != null) _selectedEventTOD = event.selectedTOD;
       yield EventDateSelectedState();// ? Need to change this name perhaps
    }
    yield* _canEnableSaveButton();
  }

  Stream<EventState> _mapDepartmentClickToState(DepartmentClickEvent event) async*{
    selectedDepartments[event.department] = event.selected;
    bool selected = event.selected;
    switch(event.department){
      case Department.CHURCH:
        if(selected) yield EventDepartmentChurchEnabled();
        else yield EventDepartmentChurchDisabled();
        break;

      case Department.YOUTH:
        if(selected) yield EventDepartmentYouthEnabled();
        else yield EventDepartmentYouthDisabled();
        break;

      case Department.WOMEN:
        if(selected) yield EventDepartmentWomenEnabled();
        else yield EventDepartmentWomenDisabled();
        break;
    }
    yield* _canEnableSaveButton();
  }

  Stream<EventState> _mapTextChangeToState(TextChangeEvent event) async*{
    _eventTitle = event.title?? _eventTitle;
    _eventBody = event.body?? _eventBody;
    if(_eventTitle.trim().isEmpty ||_eventBody.trim().isEmpty){
      _areAnyTextFieldsEmpty = true;
    }else{
      _areAnyTextFieldsEmpty = false;
    }
     yield* _canEnableSaveButton();
  }

  Stream<EventState> _canEnableSaveButton() async*{
    if(_areAnyTextFieldsEmpty || !selectedDepartments.values.contains(true) ||
    _selectedEventTOD == null || _selectedEventDate == null){
       yield EventDisableButton();
    }else{
      yield EventEnableSaveButton();
    }
  }

  Stream<EventState> _mapTabClickEventToState(TabClickEvent event) async*{
    switch(event.selectedIndex){
      case 0: yield EventMainTabClick();
      break;
      case 1: yield EventScheduleTabClick();
      break;
      case 2: yield EventGalleryTabClick();
      break;
      case 3: yield EventUpdatesTabClick();
      break;
    }
  }
}
