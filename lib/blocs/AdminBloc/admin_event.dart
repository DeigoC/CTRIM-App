part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object> get props => [];
  const AdminEvent();
}

// ! Login events
class AdminLoginEvent extends AdminEvent {}

class AdminContinueLoginEvent extends AdminLoginEvent {}

class AdminLoginTextChangeEvent extends AdminLoginEvent {
  final String email, password;
  AdminLoginTextChangeEvent({this.email, this.password});
}

class AdminContinueClickEvent extends AdminLoginEvent {}

class AdminReturnToLoginEmailEvent extends AdminLoginEvent {}

class AdminLoginButtonClickedEvent extends AdminLoginEvent{}

// ! Adding/Editing user
class AdminSaveMyDetailsEvent extends AdminEvent{
  final NotusDocument document;
  final File file;
  final bool hasDeletedSrc;
  AdminSaveMyDetailsEvent({this.document, this.file,this.hasDeletedSrc});
}

class AdminRebuildSocialLinksEvent extends AdminEvent{}

class AdminModifyingUserEvent extends AdminEvent {}

class AdminUserAdminLevelChangeEvent extends AdminModifyingUserEvent {
  final int selectedLevel;
  AdminUserAdminLevelChangeEvent(this.selectedLevel);
}

class AdminUserModTextChangeEvent extends AdminModifyingUserEvent {
  final String forename, surname, email, password, contactNo;
  AdminUserModTextChangeEvent(
      {this.forename, this.surname, this.email, this.password, this.contactNo});
}

class AdminUserModEditTextChangeEvent extends AdminModifyingUserEvent {
  final String forename, surname, contactNo;
  AdminUserModEditTextChangeEvent(
      {this.forename, this.surname, this.contactNo});
}

class AdminUserModAddNewUserClickEvent extends AdminModifyingUserEvent {}

class AdminUserModUpdateUserClickEvent extends AdminModifyingUserEvent {}
