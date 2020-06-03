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
class NavigateToPageEvent extends AppEvent{}

class ToViewEventPage extends NavigateToPageEvent{}

class ToAddEventPage extends NavigateToPageEvent{}

class ToViewAllEventsForLocation extends NavigateToPageEvent{}

class ToViewLocationOnMap extends NavigateToPageEvent{}

// * Settings Events
class SettingsEvent extends AppEvent{}

class ChangeThemeToDark extends SettingsEvent{}

class ChangeThemeToLight extends SettingsEvent{}