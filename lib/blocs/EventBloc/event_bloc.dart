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
    if(event.title.trim().isEmpty || event.body.trim().isEmpty){
      _areAnyTextFieldsEmpty = true;
    }else{
      _areAnyTextFieldsEmpty = false;
    }
     yield* _canEnableSaveButton();
  }

  Stream<EventState> _canEnableSaveButton() async*{
    if(_areAnyTextFieldsEmpty || !selectedDepartments.values.contains(true)){
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
