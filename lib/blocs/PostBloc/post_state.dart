part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  @override
  List<Object> get props => [];

  const PostState();
}

class PostInitial extends PostState {}

class PostButtonChangeState extends PostState{}
class PostEnableSaveButtonState extends PostButtonChangeState{}
class PostDisableSaveButtonState extends PostButtonChangeState{}

class PostUpdateBodyState extends PostState{}

// * Department Clicks
class PostDepartmentClickState extends PostState{}

class PostDepartmentChurchEnabledState extends PostDepartmentClickState{}
class PostDepartmentYouthEnabledState extends PostDepartmentClickState{}
class PostDepartmentWomenEnabledState extends PostDepartmentClickState{}

class PostDepartmentChurchDisabledState extends PostDepartmentClickState{}
class PostDepartmentYouthDisabledState extends PostDepartmentClickState{}
class PostDepartmentWomenDisabledState extends PostDepartmentClickState{}

// * Tab clicks
class PostTabClickState extends PostState{}
class PostAboutTabClickState extends PostTabClickState{}
class PostDetailsTabClickState extends PostTabClickState{}
class PostGalleryTabClickState extends PostTabClickState{}
class PostUpdatesTabClickState extends PostTabClickState{}

// * Schedule States
class PostScheduleState extends PostState{}
class PostSelectDateState extends PostScheduleState{}
class PostSelectTimeState extends PostScheduleState{}
class PostDateSelectedState extends PostScheduleState{}