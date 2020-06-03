part of 'event_bloc.dart';

abstract class EventState extends Equatable {
  @override
  List<Object> get props => [];

  const EventState();
}

class EventInitial extends EventState {}

class EventButtonChangeState extends EventState{}
class EventEnableSaveButton extends EventButtonChangeState{}
class EventDisableButton extends EventButtonChangeState{}

// * Department Clicks
class EventDepartmentClickState extends EventState{}

class EventDepartmentChurchEnabled extends EventDepartmentClickState{}
class EventDepartmentChurchDisabled extends EventDepartmentClickState{}

class EventDepartmentYouthEnabled extends EventDepartmentClickState{}
class EventDepartmentYouthDisabled extends EventDepartmentClickState{}

class EventDepartmentWomenEnabled extends EventDepartmentClickState{}
class EventDepartmentWomenDisabled extends EventDepartmentClickState{}

// * Tab clicks
class EventTabClick extends EventState{}

class EventMainTabClick extends EventTabClick{}

class EventScheduleTabClick extends EventTabClick{}

class EventGalleryTabClick extends EventTabClick{}

class EventUpdatesTabClick extends EventTabClick{}

