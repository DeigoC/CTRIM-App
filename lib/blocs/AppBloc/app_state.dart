part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => [];

  const AppState();
}

class AppInitial extends AppState {}

class AppClosePageState extends AppState {}
class AppOpenViewEventPageState extends AppState {}

// * Tabs Being clicked
class AppTabClickedState extends AppState {}
class AppGalleryTabClickedState extends AppTabClickedState{}
class AppPostsTabClickedState extends AppTabClickedState{}
class AppLocationsTabClickedState extends AppTabClickedState{}
class AppAboutTabClickedState extends AppTabClickedState{}
class AppSettingsTabClickedState extends AppTabClickedState{}

// * Settings State
class SettingsState extends AppState {}
class AppThemeToLightState extends SettingsState{}
class AppThemeToDarkState extends SettingsState{}

class AppCurrentUserState extends AppState{}
class AppCurrentUserLikedPostState extends AppState{}