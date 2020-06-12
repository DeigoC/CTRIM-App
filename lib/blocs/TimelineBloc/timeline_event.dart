part of 'timeline_bloc.dart';

abstract class TimelineEvent extends Equatable {
  @override
  List<Object> get props => [];
  const TimelineEvent();
}

class TimelineFetchAllPostsEvent extends TimelineEvent{}
