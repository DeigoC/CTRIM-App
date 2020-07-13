part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object> get props => [];
  const AdminState();
}

class AdminInitial extends AdminState {}

// ! Login state
class AdminLoginState extends AdminState {}

// ! Login state - Buttons
class AdminLoginButtonState extends AdminLoginState {}

class AdminLoginDisableContinueState extends AdminLoginButtonState {}

class AdminLoginEnableContinueState extends AdminLoginButtonState {}

class AdminLoginDisableLoginState extends AdminLoginButtonState {}

class AdminLoginEnableLoginState extends AdminLoginButtonState {}

// ! Login - Errors
class AdminLoginErrorState extends AdminLoginState{}

class AdminLoginEmailNotRecognisedState extends AdminLoginErrorState {}

class AdminLoginIncorrectPasswordState extends AdminLoginErrorState{}

class AdminLoginUserDisabledState extends AdminLoginErrorState{}

class AdminLoginTooManyRequestsState extends AdminLoginErrorState{}

class AdminLoginOperationNotAllowedState extends AdminLoginErrorState{}

class AdminLoginUnknownErrorState extends AdminLoginErrorState{}

// ! Login - other
class AdminLoginContinueToPasswordState extends AdminLoginState {}

class AdminLognReturnToEmailState extends AdminLoginState {}

class AdminLoginCompletedState extends AdminLoginState{
  final User user;
  AdminLoginCompletedState(this.user);
}

class AdminLoginLoadingState extends AdminLoginState{}

// ! User modification states
class AdminUserImageUploadingState extends AdminState{}
class AdminUserImageUploadCompleteState extends AdminState{}

class AdminUserModificationState extends AdminState {}

class AdminUserAdminLevelChangedState extends AdminUserModificationState {}

class AdminUserModEnableSaveButtonState extends AdminUserModificationState {}

class AdminUserModDisableButtonState extends AdminUserModificationState {}

class AdminUserModEmailAlreadyExistsState extends AdminUserModificationState {}

class AdminUserModPasswordTooSmallState extends AdminUserModificationState {}

class AdminUserModAddNewUserState extends AdminUserModificationState {
  final User newUser;
  AdminUserModAddNewUserState(this.newUser);
}

class AdminUserModUpdateUserState extends AdminUserModificationState {
  final User updatedUser;
  AdminUserModUpdateUserState(this.updatedUser);
}
