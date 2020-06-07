part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
  const PostEvent();
}

class PostTabClickEvent extends PostEvent{
  final int selectedIndex;
  PostTabClickEvent(this.selectedIndex);
}

class PostTextChangeEvent extends PostEvent{
  final String title, body;
  PostTextChangeEvent({this.title, this.body});
}

class PostDepartmentClickEvent extends PostEvent{
  final Department department;
  final bool selected;
  PostDepartmentClickEvent(this.department, this.selected);
}

class PostSaveBodyDocumentEvent extends PostEvent{}

// * Schedule Events
class PostScheduleTabEvent extends PostEvent{}
class PostSelectPostDateEvent extends PostScheduleTabEvent{}
class PostSelectPostTimeEvent extends PostScheduleTabEvent{}
class PostSetPostDateEvent extends PostScheduleTabEvent{
  final DateTime selectedDate;
  PostSetPostDateEvent(this.selectedDate);
}
class PostSetPostTimeEvent extends PostScheduleTabEvent{
  final TimeOfDay selectedTOD;
  PostSetPostTimeEvent(this.selectedTOD);
}

