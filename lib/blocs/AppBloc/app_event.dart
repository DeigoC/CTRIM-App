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
class AppToViewPostPageEvent extends AppNavigateToPageEvent{}
class AppToAddPostPageEvent extends AppNavigateToPageEvent{}
class AppToViewAllPostsForLocationEvent extends AppNavigateToPageEvent{}
class AppToViewLocationOnMapEvent extends AppNavigateToPageEvent{}
class AppToRegisterUserEvent extends AppNavigateToPageEvent{}
class AppToViewAllUsersEvent extends AppNavigateToPageEvent{}
class AppToEditUserEvent extends AppNavigateToPageEvent{}
class AppToAddLocationEvent extends AppNavigateToPageEvent{}
class AppToEditLocationEvent extends AppNavigateToPageEvent{}
class AppToSelectLocationForPostEvent extends AppNavigateToPageEvent{}
class AppToEditAlbumEvent extends AppNavigateToPageEvent{}
class AppToAddGalleryFileEvent extends AppNavigateToPageEvent{}
class AppToPostBodyEditorEvent extends AppNavigateToPageEvent{
  final PostBloc eventBloc;
  AppToPostBodyEditorEvent(this.eventBloc);
}


// * Settings Events
class AppSettingsEvent extends AppEvent{}

class AppChangeThemeToDarkEvent extends AppSettingsEvent{}

class AppChangeThemeToLightEvent extends AppSettingsEvent{}