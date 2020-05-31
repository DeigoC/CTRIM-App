import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => AppInitial();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    
    if(event is TabButtonClicked){
      yield* _mapTabEventToState(event);
    }

    else if (event is OpenViewEventPage){
      yield AppOpenViewEventPage();
    }
  }


  Stream<AppState> _mapTabEventToState(TabButtonClicked event) async*{
    switch(event.selectedIndex){
      case 0: yield AppEventsTabClicked();
      break;
      case 1: yield AppGalleryTabClicked();
      break;
      case 2: yield AppLocationsTabClicked();
      break;
      case 3: yield AppAboutTabClicked();
      break;
      case 4: yield AppSettingsTabClicked();
      break;
    }
  }
}
