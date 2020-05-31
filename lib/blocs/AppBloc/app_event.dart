part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
   @override
  List<Object> get props => [];
  const AppEvent();
}

class OpenViewEventPage extends AppEvent{}

class TabButtonClicked extends AppEvent{
  final int selectedIndex;
  TabButtonClicked(this.selectedIndex);
}
