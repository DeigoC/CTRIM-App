import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  
  // * Admin Variables

  List<User> _users =[];
  void setUsers(List<User> users){
    _users = users;
  }
  
  User _selectedUser, _originalUser;
  User get selectedUser => _selectedUser;

  void setupUserToRegister(){
    _selectedUser = User(
      id: (int.parse(_users.last.id) + 1).toString(),
      forename: '',
      surname: '',
      email: '',
      contactNo: ''
    );
  }

  void setupUserToEdit(User user){
    _originalUser = User(
      id: user.id,
      forename: user.forename,
      surname: user.surname,
      email: user.email,
      contactNo: user.contactNo,
      adminLevel: user.adminLevel
    );
    _selectedUser = User(
      id: user.id,
      forename: user.forename,
      surname: user.surname,
      email: user.email,
      contactNo: user.contactNo,
      adminLevel: user.adminLevel,
    );
  }

  String _loginEmail = '', _loginPassword ='', _creationPassword = '';

  AdminBloc(this._users);

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
      yield _canContinueToPasswordState(event);
    }else if(event is AdminReturnToLoginEmailEvent){
      yield AdminLognReturnToEmailState();
    }else if(event is AdminModifyingUserEvent) yield* _mapUserModificationEventToState(event);
  }

  Stream<AdminState> _mapUserModificationEventToState(AdminModifyingUserEvent event) async*{
    if(event is AdminUserAdminLevelChangeEvent){
      _selectedUser.adminLevel = event.selectedLevel;
      yield AdminUserAdminLevelChangedState();
      yield _canEnableAddUserButton();
      yield _canEnableUpdateUserButton(); // ? Weird?
    }
    else if(event is AdminUserModTextChangeEvent){
      _selectedUser.forename = event.forename??_selectedUser.forename;
      _selectedUser.surname = event.surname??_selectedUser.surname;
      _selectedUser.contactNo = event.contactNo??_selectedUser.contactNo;
      _selectedUser.email = event.email??_selectedUser.email;
      _creationPassword = event.password??_creationPassword;
      yield _canEnableAddUserButton();
    }
    else if(event is AdminUserModEditTextChangeEvent){
      _selectedUser.forename = event.forename??_selectedUser.forename;
      _selectedUser.surname = event.surname??_selectedUser.surname;
      _selectedUser.contactNo = event.contactNo??_selectedUser.contactNo;
      yield _canEnableUpdateUserButton();
    }
    else if(event is AdminUserModAddNewUserClickEvent){
      //TODO need to check for Auth checks
      if(_emailAlreadyExists()){
        yield AdminUserModEmailAlreadyExistsState();
      }else if(_creationPassword.length < 6){
        yield AdminUserModPasswordTooSmallState();
      }else{
        yield AdminUserModAddNewUserState(_selectedUser);
      }
      yield _canEnableAddUserButton();
    }
  }

  bool _emailAlreadyExists(){
    if(_users.firstWhere((u) => u.email.compareTo(_selectedUser.email)==0,orElse: ()=>null) != null) return true;
    return false;
  }

  AdminState _canEnableUpdateUserButton(){
    if((_selectedUser.forename.compareTo(_originalUser.forename) != 0 || 
      _selectedUser.surname.compareTo(_originalUser.surname) !=0 ||
      _selectedUser.contactNo.compareTo(_originalUser.contactNo) != 0 ||
      _selectedUser.adminLevel != _originalUser.adminLevel) &&
      (_selectedUser.forename.trim().isNotEmpty && _selectedUser.surname.trim().isNotEmpty)){
          return AdminUserModEnableSaveButtonState();
        }
      return AdminUserModDisableButtonState();
  }

  AdminState _canEnableAddUserButton(){
    if(_selectedUser.forename.trim().isEmpty||_selectedUser.surname.trim().isEmpty
    ||_selectedUser.email.trim().isEmpty||_creationPassword.isEmpty
    || _selectedUser.adminLevel==null) return AdminUserModDisableButtonState();
    return AdminUserModEnableSaveButtonState();
  }

  AdminState _canContinueToPasswordState(AdminContinueClickEvent event){
    User u = _users.firstWhere((user) => user.email.compareTo(_loginEmail)==0,
    orElse: ()=> null);
    if(u != null){
      return AdminLoginContinueToPasswordState();
    }
    return AdminLoginEmailNotRecognisedState();
      
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
