part of 'timeline_bloc.dart';

abstract class TimelineState extends Equatable {
  @override
  List<Object> get props => [];
  const TimelineState();
}

// ! Post Related
class TimelineInitial extends TimelineState {}
class TimelineEmptyState extends TimelineState {}
class TimelineLoadingFeedState extends TimelineState{}

abstract class TimelineFeedState extends TimelineState{
  final List<TimelinePost> feedData;
  TimelineFeedState(this.feedData);
}

class TimelineFetchedFeedState extends TimelineFeedState {
  final List<TimelinePost> feedData;
  TimelineFetchedFeedState(this.feedData):super(feedData);
}

class TimelineFetchedFeedWithTagsState extends TimelineFeedState{
  final List<TimelinePost> feedData;
  TimelineFetchedFeedWithTagsState(this.feedData):super(feedData);
}

class TimelineRebuildFeedState extends TimelineState{}
class TimelineTagChangedState extends TimelineState {}
class TimelineNewPostUploadedState extends TimelineState{}
class TimelineAttemptingToUploadNewPostState extends TimelineState{}

class TimelineRebuildMyPostsPageState extends TimelineState {
  final TimelinePost updatedOriginalTP;
  TimelineRebuildMyPostsPageState(this.updatedOriginalTP);
}

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


// ! User related
class TimelineRebuildUserListState extends TimelineState{}

// ! About tab
class TimelineRebuildAboutTabState extends TimelineState{}