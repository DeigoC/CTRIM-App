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
  final String authorID;
  TimelineAddNewPostEvent(this.post,this.authorID);
}

class TimelineTagClickedEvent extends TimelineEvent {
  final String tag;
  TimelineTagClickedEvent(this.tag);
}

class TimelinePostUpdateEvent extends TimelineEvent{
  final Post post;
  final String uid, updateLog, thumbnailSrc;
  final Map<String, String> gallerySrc;
  TimelinePostUpdateEvent({this.post, this.uid, this.updateLog,this.thumbnailSrc, this.gallerySrc});
}

class TimelineUpdatePostEvent extends TimelinePostUpdateEvent {
  final Post post;
  final String uid, updateLog, thumbnailSrc;
  final Map<String, String> gallerySrc;
  TimelineUpdatePostEvent({this.post, this.uid, this.updateLog, this.gallerySrc, this.thumbnailSrc}) : 
  super();
}

class TimelineDeletePostEvent extends TimelinePostUpdateEvent{
  final Post post;
  final String uid, updateLog, thumbnailSrc;
  final Map<String, String> gallerySrc;
  TimelineDeletePostEvent({this.post, this.uid, this.updateLog = 'Post Deleted', this.gallerySrc, this.thumbnailSrc})
  :super();
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

class TimelineUserDisabledEvent extends TimelineEvent{
  final User user;
  TimelineUserDisabledEvent(this.user);
}

class TimelineUserEnabledEvent extends TimelineEvent{
  final User user;
  TimelineUserEnabledEvent(this.user);
}

// ! Search Post
class TimelineSearchPostEvent extends TimelineEvent {}

class TimelineSearchTextChangeEvent extends TimelineSearchPostEvent {
  final String searchString;
  TimelineSearchTextChangeEvent(this.searchString);
}

// ! Location related
class TimelineLocationSearchTextChangeEvent extends TimelineEvent {
  final String searchString;
  TimelineLocationSearchTextChangeEvent(this.searchString);
}

class TimelineLocationUpdateOccuredEvent extends TimelineEvent{}

// ! Search Album
class TimelineAlbumSearchEvent extends TimelineEvent {}

class TimelineAlbumSearchTextChangeEvent extends TimelineAlbumSearchEvent {
  final String newSearch;
  TimelineAlbumSearchTextChangeEvent(this.newSearch);
}

// ! About tab
class TimelineAboutTabEvent extends TimelineEvent{}

class TimelineRebuildAboutTabEvent extends TimelineAboutTabEvent{}