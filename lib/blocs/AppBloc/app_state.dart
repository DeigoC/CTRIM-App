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
class AppMapUploadTaskToDialogueState extends AppState{
  final StorageUploadTask task;
  final int itemNo,totalLength;
  final String fileName;
  AppMapUploadTaskToDialogueState({
    @required this.task,
    @required this.itemNo, 
    @required this.totalLength,
    @required this.fileName,
  });
}

class AppCompressingImageTaskState extends AppState{
  final int itemNo,totalLength;
  final String fileName;
  AppCompressingImageTaskState({
    @required this.itemNo, 
    @required this.totalLength,
    @required this.fileName,
  });
}

class AppCompressingVideoTaskState extends AppState{
  final String fileName;
  final int itemNo, totalLength;
  AppCompressingVideoTaskState({
    @required this.fileName,
    @required this.totalLength,
    @required this.itemNo,
  });
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
