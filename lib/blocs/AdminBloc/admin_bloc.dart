import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  
  // * Admin Variables

  List<String> _users =[
    'test@email.com'
  ];
  List<String> get users => _users;
  
  String _loginEmail = '', _loginPassword ='';
  String get loginEmail => _loginEmail;

  // * Bloc Events
  @override
  AdminState get initialState => AdminInitial();

  @override
  Stream<AdminState> mapEventToState(
    AdminEvent event,
  ) async* {
    if(event is AdminLoginTextChangeEvent){
      yield* _mapLoginTextChangeEventToState(event);
    }else if(event is AdminContinueClickEvent){
      if(_users.contains(_loginEmail)) yield AdminLoginContinueToPasswordState();
      else yield AdminLoginEmailNotRecognisedState();
    }else if(event is AdminReturnToLoginEmailEvent){
      yield AdminLognReturnToEmailState();
    }
  }

  Stream<AdminLoginState> _mapLoginTextChangeEventToState(AdminLoginTextChangeEvent event) async*{
    _loginEmail = event.email.trim() ?? _loginEmail;
    _loginPassword = event.password ?? _loginPassword;
    if(_loginEmail.isEmpty){
      yield AdminLoginDisableContinueState();
    }else{
      yield AdminLoginEnableContinueState();
    }
    if(_loginPassword.isEmpty){
      yield AdminLoginDisableLoginState();
    }else{
      yield AdminLoginEnableContinueState();
    }
  }

}
