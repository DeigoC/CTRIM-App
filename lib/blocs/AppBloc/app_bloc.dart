import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
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
    else if(event is AppNavigateToPageEvent) _openPageFromEvent(event);
    else if(event is AppSettingsEvent) yield* _mapSettingsEventToState(event);
  }

  void _openPageFromEvent(AppNavigateToPageEvent event){
    NavigatorState state = navigatorKey.currentState;
    if(event is AppToViewPostPageEvent) state.pushNamed(ViewEventRoute);
    else if(event is AppToAddPostPageEvent) state.pushNamed(AddEventRoute);
    else if(event is AppToViewAllPostsForLocationEvent) state.pushNamed(ViewAllEventsForLocationRoute);
    else if(event is AppToViewLocationOnMapEvent) state.pushNamed(ViewLocationOnMapRoute);
    else if(event is AppToRegisterUserEvent) state.pushNamed(RegisterUserRoute);
    else if(event is AppToViewAllUsersEvent) state.pushNamed(ViewAllUsersRoute);
    else if(event is AppToEditUserEvent) state.pushNamed(EditUserRoute);
    else if(event is AppToAddLocationEvent) state.pushNamed(AddLocationRoute);
    else if(event is AppToEditLocationEvent) state.pushNamed(EditLocationRoute);
    else if(event is AppToSelectLocationForPostEvent) state.pushNamed(SelectLocationForEventRoute);
    else if(event is AppToEditAlbumEvent) state.pushNamed(EditAlbumRoute);
    else if(event is AppToAddGalleryFileEvent) state.pushNamed(AddGalleryFilesRoute);
    else if(event is AppToPostBodyEditorEvent) state.pushNamed(EventBodyEditorRoute,arguments: {'postBloc':event.postBloc});
    else if(event is AppToUserLoginEvent) state.pushNamed(UserLoginRoute);
  }

  Stream<AppState> _mapTabEventToState(TabButtonClicked event) async*{
    switch(event.selectedIndex){
      case 0: yield AppPostsTabClickedState();
      break;
      case 1: yield AppGalleryTabClickedState();
      break;
      case 2: yield AppLocationsTabClickedState();
      break;
      case 3: yield AppAboutTabClickedState();
      break;
      case 4: yield AppSettingsTabClickedState();
      break;
    }
  }

  Stream<AppState> _mapSettingsEventToState(AppSettingsEvent event) async*{
    if(event is AppChangeThemeToDarkEvent) yield _changeThemeToDarkState();
    else if(event is AppChangeThemeToLightEvent) yield _changeThemeToLightState();
  }

  AppState _changeThemeToDarkState(){
    _onDark = true;
    return AppThemeToDarkState();
  }

   AppState _changeThemeToLightState(){
    _onDark = false;
    return AppThemeToLightState();
  }

}
