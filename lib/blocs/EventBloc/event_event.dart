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
  TextChangeEvent({this.title, this.body});
}

class DepartmentClickEvent extends EventEvent{
  final Department department;
  final bool selected;
  DepartmentClickEvent(this.department, this.selected);
}

class SaveNewBodyDocumentEvent extends EventEvent{}

// * Schedule Events
class ScheduleTabEvent extends EventEvent{}
class SelectEventDateEvent extends ScheduleTabEvent{}
class SelectEventTimeEvent extends ScheduleTabEvent{}
class SetEventDateEvent extends ScheduleTabEvent{
  final DateTime selectedDate;
  SetEventDateEvent(this.selectedDate);
}
class SetEventTimeEvent extends ScheduleTabEvent{
  final TimeOfDay selectedTOD;
  SetEventTimeEvent(this.selectedTOD);
}

