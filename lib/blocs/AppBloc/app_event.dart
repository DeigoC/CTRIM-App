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
  final BuildContext context;
  AppPostLikeClickedEvent({@required this.post, @required this.context});
}

class AppCurrentUserLoggedInEvent extends AppCurrentUserEvent{
  final User user;
  AppCurrentUserLoggedInEvent(this.user);
}

class AppStartupLoadUserEvent extends AppEvent{}

class AppCurrentUserLogsOutEvent extends AppEvent{}

class AppRebuildSliverAppBarEvent extends AppEvent{}

// ! Uploading?
class AppUploadTaskStartedEvent extends AppEvent{
  final UploadTask task;
  final AppUploadItem appUploadItem;
  AppUploadTaskStartedEvent({
    @required this.task,  
    @required this.appUploadItem,
  });
}

class AppUploadCompressingImageEvent extends AppEvent{
  final AppUploadItem appUploadItem;
  AppUploadCompressingImageEvent({@required this.appUploadItem});
}

class AppUploadCompressingVideoEvent extends AppEvent{
  final AppUploadItem appUploadItem;
  AppUploadCompressingVideoEvent({@required this.appUploadItem});
}

// ! Navigation Events
class AppNavigateToPageEvent extends AppEvent {}

class AppToHomePageEvent extends AppNavigateToPageEvent{}

// ! Posts
class AppToViewPostPageEvent extends AppNavigateToPageEvent {
  final String postID;
  AppToViewPostPageEvent(this.postID);
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
  final String postID;
  AppToEditPostPageEvent(this.postID);
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
class AppToSearchLocationEvent extends AppNavigateToPageEvent{
  final PostBloc postBloc;
  AppToSearchLocationEvent(this.postBloc);
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
class AppToEditUserBodyPageEvent extends AppNavigateToPageEvent{
  final AdminBloc adminBloc;
  AppToEditUserBodyPageEvent(this.adminBloc);
}

// ! Gallery
class AppToCreateAlbumEvent extends AppNavigateToPageEvent {
  final PostBloc postBloc;
  AppToCreateAlbumEvent(this.postBloc);
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

// ! Settings Events
class AppSettingsEvent extends AppEvent {}
class AppChangeThemeToDarkEvent extends AppSettingsEvent {}
class AppChangeThemeToLightEvent extends AppSettingsEvent {}
