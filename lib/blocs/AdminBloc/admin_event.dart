part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
    @override
  List<Object> get props => [];
  const AdminEvent();
}

class AdminLoginEvent extends AdminEvent{}
class AdminContinueLoginEvent extends AdminLoginEvent{}
class AdminLoginTextChangeEvent extends AdminLoginEvent{
  final String email, password;
  AdminLoginTextChangeEvent({this.email, this.password});
}
class AdminContinueClickEvent extends AdminLoginEvent{}
class AdminReturnToLoginEmailEvent extends AdminLoginEvent{}

