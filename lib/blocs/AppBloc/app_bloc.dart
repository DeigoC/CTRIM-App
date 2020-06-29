import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ctrim_app_v1/App.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  // ! Bloc Fields
  final GlobalKey<NavigatorState> navigatorKey;
  bool _onDark = false;
  bool get onDarkTheme => _onDark;
  User _currentUser = User(id: '1', likedPosts: []);
  User get currentUser => _currentUser;

  AppBloc(this.navigatorKey);

  // ! Mapping events to states
  @override
  AppState get initialState => AppInitial();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is TabButtonClicked) {
      yield* _mapTabEventToState(event);
    } else if (event is NavigationPopAction)
      navigatorKey.currentState.pop();
    else if (event is AppNavigateToPageEvent)
      _openPageFromEvent(event);
    else if (event is AppSettingsEvent)
      yield* _mapSettingsEventToState(event);
    else if (event is AppCurrentUserEvent)
      yield* _mapCurrentUserEventToState(event);
  }

  Stream<AppState> _mapCurrentUserEventToState(
      AppCurrentUserEvent event) async* {
    if (event is AppPostLikeClicked) {
      bool alreadySaved = _currentUser.likedPosts.contains(event.post.id);
      if (alreadySaved)
        _currentUser.likedPosts.remove(event.post.id);
      else
        _currentUser.likedPosts.add(event.post.id);
      yield AppCurrentUserLikedPostState();
      yield AppCurrentUserState();
    }
  }

  void _openPageFromEvent(AppNavigateToPageEvent event) {
    NavigatorState state = navigatorKey.currentState;
    if (event is AppToViewPostPageEvent)
      state.pushNamed(ViewEventRoute, arguments: {'post': event.post});
    else if (event is AppToAddPostPageEvent)
      state.pushNamed(AddEventRoute);
    else if (event is AppToViewAllPostsForLocationEvent)
      state.pushNamed(ViewAllEventsForLocationRoute);
    else if (event is AppToViewLocationOnMapEvent)
      state.pushNamed(ViewLocationOnMapRoute);
    else if (event is AppToRegisterUserEvent)
      state.pushNamed(RegisterUserRoute);
    else if (event is AppToViewAllUsersEvent)
      state.pushNamed(ViewAllUsersRoute);
    else if (event is AppToEditUserEvent)
      state.pushNamed(EditUserRoute, arguments: {'user': event.user});
    else if (event is AppToAddLocationEvent)
      state.pushNamed(AddLocationRoute);
    else if (event is AppToEditLocationEvent)
      state.pushNamed(EditLocationRoute,
          arguments: {'location': event.location});
    else if (event is AppToSelectLocationForPostEvent)
      state.pushNamed(SelectLocationForEventRoute,
          arguments: {'postBloc': event.postBloc});
    else if (event is AppToCreateAlbumEvent)
      state
          .pushNamed(CreateAlbumRoute, arguments: {'postBloc': event.postBloc});
    else if (event is AppToAddGalleryFileEvent)
      state.pushNamed(AddGalleryFilesRoute,
          arguments: {'postBloc': event.postBloc});
    else if (event is AppToPostBodyEditorEvent)
      state.pushNamed(EventBodyEditorRoute,
          arguments: {'postBloc': event.postBloc});
    else if (event is AppToUserLoginEvent)
      state.pushNamed(UserLoginRoute);
    else if (event is AppToViewImageVideoPageEvent)
      state.pushNamed(ViewImageVideoRoute, arguments: {
        'initialPage': event.initialPage,
        'imgSources': event.imageSorces
      });
    else if (event is AppToViewMyPostsPageEvent)
      state.pushNamed(ViewMyPostsRoute);
    else if (event is AppToEditPostPageEvent)
      state.pushNamed(EditPostRoute, arguments: {'post': event.post});
    else if (event is AppToEditAlbumEvent)
      state.pushNamed(EditAlbumRoute, arguments: {'postBloc': event.postBloc});
    else if (event is AppToViewPostAlbumEvent)
      state.pushNamed(ViewPostAlbumRoute, arguments: {'post': event.post});
    else if (event is AppToSearchPostsPageEvent)
      state.pushNamed(SearchPostsRoute);
    else if (event is AppToSearchAlbumPageEvent)
      state.pushNamed(SearchAlbumRoute);
    else if (event is AppToMyDetailsEvent)
      state.pushNamed(MyDetailsRoute);
    else if (event is AppToLikedPostsPageEvent)
      state.pushNamed(MyLikedPostsRoute);
  }

  Stream<AppState> _mapTabEventToState(TabButtonClicked event) async* {
    switch (event.selectedIndex) {
      case 0:
        yield AppPostsTabClickedState();
        break;
      case 1:
        yield AppGalleryTabClickedState();
        break;
      case 2:
        yield AppLocationsTabClickedState();
        break;
      case 3:
        yield AppAboutTabClickedState();
        break;
      case 4:
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
    return AppThemeToDarkState();
  }

  AppState _changeThemeToLightState() {
    _onDark = false;
    return AppThemeToLightState();
  }
}
