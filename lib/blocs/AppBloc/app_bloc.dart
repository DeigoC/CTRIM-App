import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/auth.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/UserFileDocument.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ctrim_app_v1/App.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  
  final AuthService _auth = AuthService();
  final UserFileDocument _userFileDocument = UserFileDocument();

  // ! Bloc Fields
  final GlobalKey<NavigatorState> navigatorKey;
  bool _onDark = false;
  bool get onDarkTheme => _onDark;

  User _currentUser = User(id: '0', likedPosts: [], adminLevel: 0);
  User get currentUser => _currentUser;
  
  void setCurrentUser(User user){
    _currentUser = user;
  }

  AppBloc(this.navigatorKey);

  static openURL(String url, BuildContext context) async{
    if(await canLaunch(url)){
      await launch(url);
    }else{
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Couldn't open link!"),
      ));
    }
  }

  // ! Mapping events to states
  @override
  AppState get initialState => AppInitial();

  @override
  Stream<AppState> mapEventToState(AppEvent event,) async* {
    if (event is TabButtonClicked)  yield* _mapTabEventToState(event);
    else if (event is NavigationPopAction) navigatorKey.currentState.pop();
    else if (event is AppNavigateToPageEvent) _openPageFromEvent(event);
    else if (event is AppSettingsEvent) yield* _mapSettingsEventToState(event);
    else if (event is AppCurrentUserEvent) yield* _mapCurrentUserEventToState(event);
    else if(event is AppStartupLoadUserEvent) yield* _appStartupLoad();
    else if(event is AppCurrentUserLogsOutEvent) yield* _currentUserLogsOut();
    else if(event is AppUploadCompressingImageEvent){
      yield AppEmptyState();
      yield AppCompressingImageTaskState(itemNo: event.itemNo, totalLength: event.totalLength);
    }
    else if(event is AppUploadTaskStartedEvent){
      yield AppEmptyState();
      yield AppMapUploadTaskToDialogueState(task: event.task, itemNo: event.itemNo, totalLength: event.totalLength);
    } 
    else if(event is AppRebuildSliverAppBarEvent) yield AppRebuildSliverAppBarState();
  }
 
  Stream<AppState> _mapCurrentUserEventToState(AppCurrentUserEvent event) async* {
    if (event is AppPostLikeClickedEvent) {
      bool alreadySaved = _currentUser.likedPosts.contains(event.post.id);
      if (alreadySaved) _currentUser.likedPosts.remove(event.post.id);
      else _currentUser.likedPosts.add(event.post.id);

      _saveCurrentUser();

      yield AppCurrentUserLikedPostState();
      yield AppCurrentUserState();
    }else if(event is AppCurrentUserLoggedInEvent){
      _currentUser = event.user;
      yield* _mapTabEventToState(TabButtonClicked(4));
    }
  }

  void _openPageFromEvent(AppNavigateToPageEvent event) {
    NavigatorState state = navigatorKey.currentState;
    if (event is AppToViewPostPageEvent) state.pushNamed(ViewEventRoute, arguments: {'postID': event.postID});
    else if(event is AppToHomePageEvent) state.pushNamed(HomeRoute);
    else if (event is AppToAddPostPageEvent) state.pushNamed(AddEventRoute);
    else if (event is AppToViewAllPostsForLocationEvent) state.pushNamed(ViewAllEventsForLocationRoute,arguments: 
    {'locationID':event.locationID});
    else if (event is AppToViewLocationOnMapEvent) state.pushNamed(ViewLocationOnMapRoute, arguments: 
    {'location':event.location});
    else if (event is AppToRegisterUserEvent) state.pushNamed(RegisterUserRoute);
    else if (event is AppToViewAllUsersEvent) state.pushNamed(ViewAllUsersRoute);
    else if (event is AppToEditUserEvent) state.pushNamed(EditUserRoute, arguments: {'user': event.user});
    else if (event is AppToAddLocationEvent) state.pushNamed(AddLocationRoute, arguments: {'postBloc': event.postBloc});
    else if (event is AppToEditLocationEvent) state.pushNamed(EditLocationRoute,
    arguments: {'location': event.location});
    else if (event is AppToSelectLocationForPostEvent) state.pushNamed(SelectLocationForEventRoute,
    arguments: {'postBloc': event.postBloc});
    else if (event is AppToCreateAlbumEvent)state.pushNamed(CreateAlbumRoute, arguments: {'postBloc': event.postBloc});
    else if (event is AppToAddGalleryFileEvent)state.pushNamed(AddGalleryFilesRoute,
    arguments: {'postBloc': event.postBloc});
    else if (event is AppToPostBodyEditorEvent)state.pushNamed(EventBodyEditorRoute,
    arguments: {'postBloc': event.postBloc});
    else if (event is AppToUserLoginEvent)state.pushNamed(UserLoginRoute);
    else if (event is AppToViewImageVideoPageEvent)state.pushNamed(ViewImageVideoRoute, arguments: {
        'initialPage': event.initialPage,'imgSources': event.imageSorces});
    else if (event is AppToViewMyPostsPageEvent)state.pushNamed(ViewMyPostsRoute);
    else if (event is AppToEditPostPageEvent)state.pushNamed(EditPostRoute, arguments: {'postID': event.postID});
    else if (event is AppToEditAlbumEvent)state.pushNamed(EditAlbumRoute, arguments: {'postBloc': event.postBloc});
    else if (event is AppToSearchPostsPageEvent)state.pushNamed(SearchPostsRoute);
    else if (event is AppToMyDetailsEvent)state.pushNamed(MyDetailsRoute);
    else if (event is AppToLikedPostsPageEvent)state.pushNamed(MyLikedPostsRoute);
    else if(event is AppToViewChurchEvent) state.pushNamed(ViewChurchPageRoute, arguments: 
    {'article':event.aboutArticle});
    else if(event is AppToViewPastorEvent) state.pushNamed(ViewAboutPastorsRoute, arguments: {
      'article':event.aboutArticle});
    else if(event is AppToEditAboutArticleEvent) state.pushNamed(EditAboutArticleRoute);
    else if(event is AppToEditAboutBodyEvent) state.pushNamed(AboutBodyEditorPageRoute);
    else if(event is AppToViewUserPageEvent) state.pushNamed(ViewUserPageRoute, arguments: {'user':event.user});
  }

  Stream<AppState> _appStartupLoad() async*{
    await _userFileDocument.attpemtToLoginSavedUser().then((user){
      _currentUser = user;
    });
    yield _currentUser.onDarkTheme ? _changeThemeToDarkState():_changeThemeToLightState();
    _openPageFromEvent(AppToHomePageEvent());
  }

  Stream<AppState> _currentUserLogsOut() async*{
    _auth.logoutCurrentUser();
    await _userFileDocument.deleteSaveData().then((_)async{
      await _userFileDocument.attpemtToLoginSavedUser().then((user){
        _currentUser = user;
      });
    });
    yield AppRebuildSettingsDrawerState();
  }

  Stream<AppState> _mapTabEventToState(TabButtonClicked event) async* {
    switch (event.selectedIndex) {
      case 0:
        yield AppPostsTabClickedState();
        break;
      /* case 1:
        yield AppGalleryTabClickedState();
        break; */
      case 1:
        yield AppLocationsTabClickedState();
        break;
      case 2:
        yield AppAboutTabClickedState();
        break;
      case 3:
        yield AppSettingsTabClickedState();
        break;
    }
  }

  Stream<AppState> _mapSettingsEventToState(AppSettingsEvent event) async* {
    if (event is AppChangeThemeToDarkEvent)
      yield _changeThemeToDarkState();
    else if (event is AppChangeThemeToLightEvent)
      yield _changeThemeToLightState();
  }

  AppState _changeThemeToDarkState() {
    _onDark = true;
    _currentUser.onDarkTheme = true;
    _saveCurrentUser();
    return AppThemeToDarkState();
  }

  AppState _changeThemeToLightState() {
    _onDark = false;
    _currentUser.onDarkTheme = false;
    _saveCurrentUser();
    return AppThemeToLightState();
  }

  void _saveCurrentUser(){
    if(_currentUser.id != '0'){
      UserDBManager dbManager = UserDBManager();
      dbManager.updateUser(_currentUser);
    }else{
      UserFileDocument userFileDocument = UserFileDocument();
      userFileDocument.saveGuestUserData(_currentUser);
    }
  }

}
