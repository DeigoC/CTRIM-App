part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
   @override
  List<Object> get props => [];
  const AppEvent();
}

class NavigationPopAction extends AppEvent{}
class TabButtonClicked extends AppEvent{
  final int selectedIndex;
  TabButtonClicked(this.selectedIndex);
}

// * Navigation Events
class AppNavigateToPageEvent extends AppEvent{}

// ! Posts
class AppToViewPostPageEvent extends AppNavigateToPageEvent{
  final Post post;
  AppToViewPostPageEvent(this.post);
}
class AppToAddPostPageEvent extends AppNavigateToPageEvent{}
class AppToViewAllPostsForLocationEvent extends AppNavigateToPageEvent{}
class AppToPostBodyEditorEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToPostBodyEditorEvent(this.postBloc);
}
class AppToViewMyPostsPageEvent extends AppNavigateToPageEvent{}
class AppToEditPostPageEvent extends AppNavigateToPageEvent{
  final Post post;
  AppToEditPostPageEvent(this.post);
}
class AppToSearchPostsPageEvent extends AppNavigateToPageEvent{}

// ! Locations
class AppToViewLocationOnMapEvent extends AppNavigateToPageEvent{}
class AppToAddLocationEvent extends AppNavigateToPageEvent{}
class AppToEditLocationEvent extends AppNavigateToPageEvent{
  final Location location;
  AppToEditLocationEvent(this.location);
}
class AppToSelectLocationForPostEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToSelectLocationForPostEvent(this.postBloc);
}

// ! User
class AppToRegisterUserEvent extends AppNavigateToPageEvent{}
class AppToViewAllUsersEvent extends AppNavigateToPageEvent{}
class AppToEditUserEvent extends AppNavigateToPageEvent{}
class AppToUserLoginEvent extends AppNavigateToPageEvent{}

// ! Gallery
class AppToCreateAlbumEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToCreateAlbumEvent(this.postBloc);
}
class AppToViewPostAlbumEvent extends AppNavigateToPageEvent{
  final Post post;
  AppToViewPostAlbumEvent(this.post);
}

class AppToEditAlbumEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToEditAlbumEvent(this.postBloc);
}
class AppToAddGalleryFileEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToAddGalleryFileEvent(this.postBloc);
}
class AppToViewImageVideoPage extends AppNavigateToPageEvent{
  final Map<String,String> imageSorces;
  final int initialPage;
  AppToViewImageVideoPage(this.imageSorces, this.initialPage);
}


// * Settings Events
class AppSettingsEvent extends AppEvent{}

class AppChangeThemeToDarkEvent extends AppSettingsEvent{}

class AppChangeThemeToLightEvent extends AppSettingsEvent{}