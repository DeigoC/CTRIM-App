import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ctrim_app_v1/App.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  
  final GlobalKey<NavigatorState> navigatorKey;
  bool _onDark = false;
  bool get onDarkTheme => _onDark;
  AppBloc(this.navigatorKey);

  @override
  AppState get initialState => AppInitial();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if(event is TabButtonClicked){
      yield* _mapTabEventToState(event);
    }
    else if(event is NavigationPopAction) navigatorKey.currentState.pop();
    else if(event is NavigateToPageEvent) _openPageFromEvent(event);
    else if(event is SettingsEvent) yield* _mapSettingsEventToState(event);
  }

  void _openPageFromEvent(NavigateToPageEvent event){
    NavigatorState state = navigatorKey.currentState;
    if(event is ToViewEventPage) state.pushNamed(ViewEventRoute);
    else if(event is ToAddEventPage) state.pushNamed(AddEventRoute);
    else if(event is ToViewAllEventsForLocation) state.pushNamed(ViewAllEventsForLocationRoute);
    else if(event is ToViewLocationOnMap) state.pushNamed(ViewLocationOnMapRoute); 
    else if(event is ToRegisterUser) state.pushNamed(RegisterUserRoute);
    else if(event is ToViewAllUsers) state.pushNamed(ViewAllUsersRoute);
    else if(event is ToEditUser) state.pushNamed(EditUserRoute);
    else if(event is ToAddLocation) state.pushNamed(AddLocationRoute);
    else if(event is ToEditLocation) state.pushNamed(EditLocationRoute);
    else if(event is ToSelectLocationForEvent) state.pushNamed(SelectLocationForEventRoute);
    else if(event is ToEditAlbum) state.pushNamed(EditAlbumRoute);
    else if(event is ToAddGalleryFile) state.pushNamed(AddGalleryFilesRoute);
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

  Stream<AppState> _mapSettingsEventToState(SettingsEvent event) async*{
    if(event is ChangeThemeToDark) yield _changeThemeToDarkState();
    else if(event is ChangeThemeToLight) yield _changeThemeToLightState();
  }

  AppState _changeThemeToDarkState(){
    _onDark = true;
    return AppThemeToDark();
  }

   AppState _changeThemeToLightState(){
    _onDark = false;
    return AppThemeToLight();
  }

}
