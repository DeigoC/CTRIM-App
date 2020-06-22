part of 'timeline_bloc.dart';

abstract class TimelineState extends Equatable {
   @override
  List<Object> get props => [];
  const TimelineState();
}

class TimelineInitial extends TimelineState {}

class TimelineEmptyState extends TimelineState{}
class TimelineDisplayFeedState extends TimelineState {
  final List<TimelinePost> timelines;
  final List<Post> posts;
  final List<User> users;
  TimelineDisplayFeedState({@required this.timelines, @required this.posts, @required this.users});
}

class TimelineTagChangedState extends TimelineState{}

class TimelineSearchState extends TimelineState{}
class TimelineDisplaySearchFeedState extends TimelineSearchState{
  final List<TimelinePost> timelines;
  final List<Post> posts;
  final List<User> users;
  TimelineDisplaySearchFeedState({@required this.timelines, @required this.posts, @required this.users});
}

class TimelineDisplayEmptyFeedState extends TimelineSearchState{}

class TimelineDisplayEmptySearchState extends TimelineSearchState{}

class TimelineDisplayLocationSearchResultsState extends TimelineState{
  final List<Location> locations;
  TimelineDisplayLocationSearchResultsState(this.locations);
}
