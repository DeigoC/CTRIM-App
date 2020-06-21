part of 'timeline_bloc.dart';

abstract class TimelineState extends Equatable {
   @override
  List<Object> get props => [];
  const TimelineState();
}

class TimelineInitial extends TimelineState {}

class TimelineDisplayFeedState extends TimelineState {
  final List<TimelinePost> timelines;
  final List<Post> posts;
  final List<User> users;
  TimelineDisplayFeedState({@required this.timelines, @required this.posts, @required this.users});
}

class TimelineTagChangedState extends TimelineState{}
