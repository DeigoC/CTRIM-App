part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  @override
  List<Object> get props => [];
  const EventEvent();
}

class TabClickEvent extends EventEvent{
  final int selectedIndex;
  TabClickEvent(this.selectedIndex);
}

class TextChangeEvent extends EventEvent{
  final String title, body;
  TextChangeEvent({@required this.title, @required this.body});
}

class DepartmentClickEvent extends EventEvent{
  final Department department;
  final bool selected;
  DepartmentClickEvent(this.department, this.selected);
}

