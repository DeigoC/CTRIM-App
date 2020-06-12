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

class PostSaveBodyDocumentEvent extends PostEvent{
  final String bodyContent;
  PostSaveBodyDocumentEvent(this.bodyContent);
}

// * Details Events
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
class PostDateNotApplicableClick extends PostScheduleTabEvent{}

// * Detail List Events
class PostDetailListEvent extends PostEvent{}
class PostDetailListTextChangeEvent extends PostDetailListEvent{
  final String leading, trailing;
  PostDetailListTextChangeEvent({this.leading, this.trailing});
}

class PostDetailListItemRemovedEvent extends PostDetailListEvent{
  final List<String> item;
  PostDetailListItemRemovedEvent(this.item);
}

class PostDetailListReorderEvent extends PostDetailListEvent{
  final int oldIndex, newIndex;
  PostDetailListReorderEvent({@required this.oldIndex, @required this.newIndex});
}

class PostDetailListAddItemEvent extends PostDetailListEvent{}

class PostDetailListSaveEditEvent extends PostDetailListEvent{
  final int itemIndex;
  PostDetailListSaveEditEvent(this.itemIndex);
}

// * Gallery Events
class PostGalleryEvent extends PostEvent{}
class PostFilesReceivedEvent extends PostGalleryEvent{}
class PostFilesRemoveSelectedEvent extends PostGalleryEvent{
  final List<File> selectedFiles;
  PostFilesRemoveSelectedEvent(this.selectedFiles);
}