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