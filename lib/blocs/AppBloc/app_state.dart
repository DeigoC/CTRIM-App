part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => [];

  const AppState();
}

class AppInitial extends AppState {}

class AppEmptyState extends AppState{}

class AppClosePageState extends AppState {}

class AppOpenViewEventPageState extends AppState {}

class AppRebuildSettingsDrawerState extends AppState{}

class AppAttemptingToLogoutUserState extends AppState{}

class AppRebuildSliverAppBarState extends AppState{}

// ! Uploading Task

abstract class AppUploadTaskState extends AppState{
  final AppUploadItem appUploadItem;
  AppUploadTaskState(this.appUploadItem);
}

class AppMapUploadTaskToDialogueState extends AppUploadTaskState{
  final StorageUploadTask task;
  final AppUploadItem appUploadItem;
  AppMapUploadTaskToDialogueState({
    @required this.task,
    @required this.appUploadItem,
  }):super(appUploadItem);
}

class AppCompressingImageTaskState extends AppUploadTaskState{
  final AppUploadItem appUploadItem;
  AppCompressingImageTaskState({@required this.appUploadItem,}):super(appUploadItem);
}

class AppCompressingVideoTaskState extends AppUploadTaskState{
  final AppUploadItem appUploadItem;
  AppCompressingVideoTaskState({@required this.appUploadItem,}):super(appUploadItem);
}

// ! Tabs Being clicked
class AppTabClickedState extends AppState {}

class AppGalleryTabClickedState extends AppTabClickedState {}

class AppPostsTabClickedState extends AppTabClickedState {}

class AppLocationsTabClickedState extends AppTabClickedState {}

class AppAboutTabClickedState extends AppTabClickedState {}

class AppSettingsTabClickedState extends AppTabClickedState {}

// ! Settings State
class SettingsState extends AppState {}

class AppThemeToLightState extends SettingsState {}

class AppThemeToDarkState extends SettingsState {}

class AppCurrentUserState extends AppState {}

class AppCurrentUserLikedPostState extends AppState {}
