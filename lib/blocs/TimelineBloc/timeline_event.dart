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
