part of 'timeline_bloc.dart';

abstract class TimelineEvent extends Equatable {
  @override
  List<Object> get props => [];
  const TimelineEvent();
}

class TimelineFetchAllPostsEvent extends TimelineEvent{}

class TimelineAddNewPostEvent extends TimelineEvent{
  final Post post;
  TimelineAddNewPostEvent(this.post);
}

class TimelineUpdatePostEvent extends TimelineEvent{
  final Post post;
  final String uid;
  TimelineUpdatePostEvent(this.post, this.uid);
}

class TimelineTagClickedEvent extends TimelineEvent{
  final String tag;
  TimelineTagClickedEvent(this.tag);
}

class TimelineSearchPostEvent extends TimelineEvent{}

class TimelineSearchTextChangeEvent extends TimelineSearchPostEvent{
  final String searchString;
  TimelineSearchTextChangeEvent(this.searchString);
}

class TimelineLocationSearchTextChangeEvent extends TimelineEvent{
  final String searchString;
  TimelineLocationSearchTextChangeEvent(this.searchString);
}

class TimelineAlbumSearchEvent extends TimelineEvent{}
class TimelineAlbumSearchTextChangeEvent extends TimelineAlbumSearchEvent{
  final String newSearch;
  TimelineAlbumSearchTextChangeEvent(this.newSearch);
}

class TimelineUserUpdatedEvent extends TimelineEvent{
  final User updatedUser;
  TimelineUserUpdatedEvent(this.updatedUser);
}

class TimelineDisplayCurrentUserLikedPosts extends TimelineEvent{
  final List<String> likedPosts;
  TimelineDisplayCurrentUserLikedPosts(this.likedPosts);
}
