part of 'timeline_bloc.dart';

abstract class TimelineEvent extends Equatable {
  @override
  List<Object> get props => [];
  const TimelineEvent();
}

// ! Post Related
class TimelineFetchAllPostsEvent extends TimelineEvent {}

class TimelineAddNewPostEvent extends TimelineEvent {
  final Post post;
  TimelineAddNewPostEvent(this.post);
}

class TimelineTagClickedEvent extends TimelineEvent {
  final String tag;
  TimelineTagClickedEvent(this.tag);
}

class TimelinePostUpdateEvent extends TimelineEvent{
  final Post post;
  final String uid, updateLog;
  TimelinePostUpdateEvent(this.post, this.uid, this.updateLog);
}

class TimelineUpdatePostEvent extends TimelinePostUpdateEvent {
  final Post post;
  final String uid, updateLog;
  TimelineUpdatePostEvent({this.post, this.uid, this.updateLog}) : 
  super(post, uid, updateLog);
}

class TimelineDeletePostEvent extends TimelinePostUpdateEvent{
  final Post post;
  final String uid;
  TimelineDeletePostEvent({this.post, this.uid})
  :super(post, uid, 'Post Deleted');
}

// ! User related
class TimelineUserUpdatedEvent extends TimelineEvent {
  final User updatedUser;
  TimelineUserUpdatedEvent(this.updatedUser);
}

class TimelineDisplayCurrentUserLikedPosts extends TimelineEvent {
  final List<String> likedPosts;
  TimelineDisplayCurrentUserLikedPosts(this.likedPosts);
}

// ! Search Post
class TimelineSearchPostEvent extends TimelineEvent {}

class TimelineSearchTextChangeEvent extends TimelineSearchPostEvent {
  final String searchString;
  TimelineSearchTextChangeEvent(this.searchString);
}

// ! Search Location
class TimelineLocationSearchTextChangeEvent extends TimelineEvent {
  final String searchString;
  TimelineLocationSearchTextChangeEvent(this.searchString);
}

// ! Search Album
class TimelineAlbumSearchEvent extends TimelineEvent {}

class TimelineAlbumSearchTextChangeEvent extends TimelineAlbumSearchEvent {
  final String newSearch;
  TimelineAlbumSearchTextChangeEvent(this.newSearch);
}
