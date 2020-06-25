part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
    @override
  List<Object> get props => [];
  const AdminState();
}

class AdminInitial extends AdminState {}

class AdminLoginState extends AdminState{}

class AdminLoginButtonState extends AdminLoginState{}
class AdminLoginDisableContinueState extends AdminLoginButtonState{}
class AdminLoginEnableContinueState extends AdminLoginButtonState{}
class AdminLoginDisableLoginState extends AdminLoginButtonState{}
class AdminLoginEnableLoginState extends AdminLoginButtonState{}

class AdminLoginEmailNotRecognisedState extends AdminLoginState{}
class AdminLoginContinueToPasswordState extends AdminLoginState{}
class AdminLognReturnToEmailState extends AdminLoginState{}

class AdminUserModificationState extends AdminState{}
class AdminUserAdminLevelChangedState extends AdminUserModificationState{}
class AdminUserModEnableSaveButtonState extends AdminUserModificationState{}
class AdminUserModDisableButtonState extends AdminUserModificationState{}
class AdminUserModEmailAlreadyExistsState extends AdminUserModificationState{}
class AdminUserModPasswordTooSmallState extends AdminUserModificationState{}
class AdminUserModAddNewUserState extends AdminUserModificationState{
  final User newUser;
  AdminUserModAddNewUserState(this.newUser);
}
class AdminUserModUpdateUser extends AdminUserModificationState{
  final User updatedUser;
  AdminUserModUpdateUser(this.updatedUser);
}