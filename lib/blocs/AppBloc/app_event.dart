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
class ToRegisterUser extends NavigateToPageEvent{}
class ToViewAllUsers extends NavigateToPageEvent{}
class ToEditUser extends NavigateToPageEvent{}
class ToAddLocation extends NavigateToPageEvent{}
class ToEditLocation extends NavigateToPageEvent{}
class ToSelectLocationForEvent extends NavigateToPageEvent{}
class ToEditAlbum extends NavigateToPageEvent{}
class ToAddGalleryFile extends NavigateToPageEvent{}
class ToEventBodyEditor extends NavigateToPageEvent{
  final EventBloc eventBloc;
  ToEventBodyEditor(this.eventBloc);
}


// * Settings Events
class SettingsEvent extends AppEvent{}

class ChangeThemeToDark extends SettingsEvent{}

class ChangeThemeToLight extends SettingsEvent{}