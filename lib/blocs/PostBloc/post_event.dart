part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
  const PostEvent();
}

class PostTabClickEvent extends PostEvent {
  final int selectedIndex;
  PostTabClickEvent(this.selectedIndex);
}

class PostTextChangeEvent extends PostEvent {
  final String title, description;
  PostTextChangeEvent({this.title, this.description});
}

class PostDepartmentClickEvent extends PostEvent {
  final PostTag department;
  final bool selected;
  PostDepartmentClickEvent(this.department, this.selected);
}

class PostSaveBodyDocumentEvent extends PostEvent {
  final String bodyContent;
  PostSaveBodyDocumentEvent(this.bodyContent);
}

// ! Details Events
class PostScheduleTabEvent extends PostEvent {}

// * Time related
class PostSetStartPostDateEvent extends PostScheduleTabEvent {
  final DateTime selectedDate;
  PostSetStartPostDateEvent(this.selectedDate);
}
class PostSetStartPostTimeEvent extends PostScheduleTabEvent {
  final TimeOfDay selectedTOD;
  PostSetStartPostTimeEvent(this.selectedTOD);
}
class PostSetEndPostDateEvent extends PostScheduleTabEvent {
  final DateTime selectedDate;
  PostSetEndPostDateEvent(this.selectedDate);
}
class PostSetEndPostTimeEvent extends PostScheduleTabEvent {
  final TimeOfDay selectedTOD;
  PostSetEndPostTimeEvent(this.selectedTOD);
}


class PostAllDayDateClickEvent extends PostScheduleTabEvent{}
class PostDateNotApplicableClickEvent extends PostScheduleTabEvent {}

// * End of time related classes
class PostSelectedLocationEvent extends PostEvent {
  final String locationID, addressLine;
  PostSelectedLocationEvent({this.locationID, this.addressLine});
}

// ! Detail List Events
class PostDetailListEvent extends PostEvent {}

class PostDetailListTextChangeEvent extends PostDetailListEvent {
  final String leading, trailing;
  PostDetailListTextChangeEvent({this.leading, this.trailing});
}

class PostDetailListItemRemovedEvent extends PostDetailListEvent {
  final Map<String,String> item;
  PostDetailListItemRemovedEvent(this.item);
}

class PostDetailListReorderEvent extends PostDetailListEvent {
  final int oldIndex, newIndex;
  PostDetailListReorderEvent(
      {@required this.oldIndex, @required this.newIndex});
}

class PostDetailListAddItemEvent extends PostDetailListEvent {}

class PostDetailListSaveEditEvent extends PostDetailListEvent {
  final int itemIndex;
  PostDetailListSaveEditEvent(this.itemIndex);
}

// ! Gallery Events
class PostGalleryEvent extends PostEvent {}

class PostFilesReceivedEvent extends PostGalleryEvent {}

class PostFilesRemoveSelectedEvent extends PostGalleryEvent {
  final List<File> selectedFiles;
  PostFilesRemoveSelectedEvent(this.selectedFiles);
}

class PostRemoveSelectedFilesAndSrcEvent extends PostGalleryEvent {
  final List<String> selectedFilesAndSrcs;
  PostRemoveSelectedFilesAndSrcEvent(this.selectedFilesAndSrcs);
}

class PostDiscardGalleryChnagesEvent extends PostGalleryEvent{}