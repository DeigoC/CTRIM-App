part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  @override
  List<Object> get props => [];
  const AppEvent();
}

class NavigationPopAction extends AppEvent {}

class TabButtonClicked extends AppEvent {
  final int selectedIndex;
  TabButtonClicked(this.selectedIndex);
}

class AppCurrentUserEvent extends AppEvent {}

class AppPostLikeClickedEvent extends AppCurrentUserEvent {
  final Post post;
  AppPostLikeClickedEvent(this.post);
}

class AppCurrentUserLoggedInEvent extends AppCurrentUserEvent{
  final User user;
  AppCurrentUserLoggedInEvent(this.user);
}

class AppStartupLoadUserEvent extends AppEvent{}

class AppCurrentUserLogsOutEvent extends AppEvent{}

// ! Uploading?
class AppUploadTaskStartedEvent extends AppEvent{
  final StorageUploadTask task;
  final int itemNo, totalLength;
  AppUploadTaskStartedEvent({@required this.task,  @required this.itemNo,@required this.totalLength});
}

class AppUploadCompressingImageEvent extends AppEvent{
  final int itemNo, totalLength;
  AppUploadCompressingImageEvent({@required this.itemNo,@required this.totalLength});
}

// ! Navigation Events
class AppNavigateToPageEvent extends AppEvent {}

class AppToHomePageEvent extends AppNavigateToPageEvent{}

// ! Posts
class AppToViewPostPageEvent extends AppNavigateToPageEvent {
  final Post post;
  AppToViewPostPageEvent(this.post);
}
class AppToAddPostPageEvent extends AppNavigateToPageEvent {}

class AppToViewAllPostsForLocationEvent extends AppNavigateToPageEvent {
  final String locationID;
  AppToViewAllPostsForLocationEvent(this.locationID);
}

class AppToPostBodyEditorEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToPostBodyEditorEvent(this.postBloc);
}
class AppToViewMyPostsPageEvent extends AppNavigateToPageEvent {}
class AppToEditPostPageEvent extends AppNavigateToPageEvent {
  final Post post;
  AppToEditPostPageEvent(this.post);
}
class AppToSearchPostsPageEvent extends AppNavigateToPageEvent {}

// ! Locations
class AppToViewLocationOnMapEvent extends AppNavigateToPageEvent {
  final Location location;
  AppToViewLocationOnMapEvent(this.location);
}
class AppToAddLocationEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToAddLocationEvent(this.postBloc);
}
class AppToEditLocationEvent extends AppNavigateToPageEvent {
  final Location location;
  AppToEditLocationEvent(this.location);
}
class AppToSelectLocationForPostEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToSelectLocationForPostEvent(this.postBloc);
}

// ! User
class AppToRegisterUserEvent extends AppNavigateToPageEvent {}
class AppToViewAllUsersEvent extends AppNavigateToPageEvent {}
class AppToEditUserEvent extends AppNavigateToPageEvent {
  final User user;
  AppToEditUserEvent(this.user);
}
class AppToUserLoginEvent extends AppNavigateToPageEvent {}
class AppToMyDetailsEvent extends AppNavigateToPageEvent {}
class AppToLikedPostsPageEvent extends AppNavigateToPageEvent {}

// ! Gallery
class AppToCreateAlbumEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToCreateAlbumEvent(this.postBloc);
}
class AppToViewPostAlbumEvent extends AppNavigateToPageEvent {
  final Post post;
  AppToViewPostAlbumEvent(this.post);
}
class AppToEditAlbumEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToEditAlbumEvent(this.postBloc);
}
class AppToAddGalleryFileEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToAddGalleryFileEvent(this.postBloc);
}
class AppToViewImageVideoPageEvent extends AppNavigateToPageEvent {
  final Map<String, ImageTag> imageSorces;
  final int initialPage;
  AppToViewImageVideoPageEvent(this.imageSorces, this.initialPage);
}
class AppToSearchAlbumPageEvent extends AppNavigateToPageEvent {}

// ! About Pages
class AppToViewChurchEvent extends AppNavigateToPageEvent{
  final AboutArticle aboutArticle;
  AppToViewChurchEvent(this.aboutArticle);
}

class AppToViewPastorEvent extends AppNavigateToPageEvent{
  final AboutArticle aboutArticle;
  AppToViewPastorEvent(this.aboutArticle);
}
class AppToEditAboutArticleEvent extends AppNavigateToPageEvent{}
class AppToEditAboutBodyEvent extends AppNavigateToPageEvent{}
class AppToViewUserPageEvent extends AppNavigateToPageEvent{
  final User user;
  AppToViewUserPageEvent(this.user);
}

// ! Settings Events
class AppSettingsEvent extends AppEvent {}
class AppChangeThemeToDarkEvent extends AppSettingsEvent {}
class AppChangeThemeToLightEvent extends AppSettingsEvent {}
