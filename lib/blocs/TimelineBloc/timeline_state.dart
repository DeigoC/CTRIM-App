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

class TimelineDisplayFilteredFeedState extends TimelineState{
  final List<TimelinePost> feedData;
  TimelineDisplayFilteredFeedState(this.feedData);
}
class TimelinePinPostSnackbarState extends TimelineState{}
class TimelineUnpinPostSnackbarState extends TimelineState{}

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

class TimelineLocationTabUpdatedState extends TimelineState{}

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