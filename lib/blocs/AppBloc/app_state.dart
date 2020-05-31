part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => [];

  const AppState();
}

class AppInitial extends AppState {}

class AppClosedPage extends AppState {}

class AppOpenViewEventPage extends AppState {}

// * Tabs Being clicked
class AppTabClicked extends AppState {}

class AppGalleryTabClicked extends AppTabClicked{}

class AppEventsTabClicked extends AppTabClicked{}

class AppLocationsTabClicked extends AppTabClicked{}

class AppAboutTabClicked extends AppTabClicked{}

class AppSettingsTabClicked extends AppTabClicked{}
