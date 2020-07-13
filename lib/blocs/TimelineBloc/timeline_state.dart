part of 'timeline_bloc.dart';

abstract class TimelineState extends Equatable {
  @override
  List<Object> get props => [];
  const TimelineState();
}

// ! Post Related
class TimelineInitial extends TimelineState {}
class TimelineEmptyState extends TimelineState {}
class TimelineDisplayFeedState extends TimelineState {
  final List<TimelinePost> timelines;
  final List<Post> posts;
  final List<User> users;
  TimelineDisplayFeedState(
      {@required this.timelines, @required this.posts, @required this.users});
}
class TimelineTagChangedState extends TimelineState {}
class TimelineNewPostUploadedState extends TimelineState{}
class TimelineAttemptingToUploadNewPostState extends TimelineState{}


// ! Search Post
class TimelineSearchState extends TimelineState {}

class TimelineDisplaySearchFeedState extends TimelineSearchState {
  final List<TimelinePost> timelines;
  final List<Post> posts;
  final List<User> users;
  TimelineDisplaySearchFeedState(
      {@required this.timelines, @required this.posts, @required this.users});
}

class TimelineDisplayEmptyFeedState extends TimelineSearchState {}

class TimelineDisplayEmptySearchState extends TimelineSearchState {}

// ! Search Location
class TimelineDisplayLocationSearchResultsState extends TimelineState {
  final List<Location> locations;
  TimelineDisplayLocationSearchResultsState(this.locations);
}

// ! Album Search
class TimelineAlbumSearchState extends TimelineState {}

class TimelineAlbumDisplaySearchResultsState extends TimelineAlbumSearchState {
  final List<Post> queryResults;
  TimelineAlbumDisplaySearchResultsState(this.queryResults);
}

class TimelineRebuildMyPostsPageState extends TimelineState {
  final Map<Post, TimelinePost> postTime;
  TimelineRebuildMyPostsPageState(this.postTime);
}

// ! User related
class TimelineRebuildUserListState extends TimelineState{}
