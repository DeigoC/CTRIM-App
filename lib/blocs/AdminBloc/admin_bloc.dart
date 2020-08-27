import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/UserFileDocument.dart';
import 'package:equatable/equatable.dart';
import 'package:ctrim_app_v1/classes/firebase_services/auth.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  // ! Admin Variables

  final AuthService _auth = AuthService();
  final UserDBManager _userDBManager = UserDBManager();
  final AppStorage _appStorage;

  List<User> _users = [];
  void setUsers(List<User> users) {
    _users = users;
  }

  User _selectedUser, _originalUser;
  User get selectedUser => _selectedUser;

  String _loginEmail = '', _loginPassword = '', _creationPassword = '', _confirmPassword = '';

  AdminBloc(this._users, AppBloc appBloc):_appStorage = AppStorage(appBloc);

  void setupUserToRegister() {
    _selectedUser = User(
        id: (int.parse(_users.last.id) + 1).toString(),
        forename: '',
        surname: '',
        email: '',
        adminLevel: 1,
        likedPosts: [],
        socialLinks: {});
  }

  void setupUserToEdit(User user) {
    _originalUser = User(
        id: user.id,
        forename: user.forename,
        surname: user.surname,
        email: user.email,
        socialLinks: Map<String,String>.from(user.socialLinks),
        likedPosts: List.from(user.likedPosts),
        role: user.role,
        adminLevel: user.adminLevel,
        body: user.body,
      );
    _selectedUser = User(
      id: user.id,
      authID: user.authID,
      role: user.role,
      onDarkTheme: user.onDarkTheme,
      forename: user.forename,
      surname: user.surname,
      email: user.email,
      socialLinks: Map<String,String>.from(user.socialLinks),
      likedPosts: List.from(user.likedPosts),
      imgSrc: user.imgSrc,
      adminLevel: user.adminLevel,
      body: user.body,
    );
  }

  // ! Mapping events to state
  @override
  AdminState get initialState => AdminInitial();

  @override
  Stream<AdminState> mapEventToState(AdminEvent event,) async* {
    if (event is AdminLoginTextChangeEvent) yield* _mapLoginTextChangeEventToState(event);
    else if (event is AdminContinueClickEvent) {
      yield _canContinueToPasswordState(event);
      yield AdminLoginState();
    } else if(event is AdminSendRecoveryEmailEvent){
      yield* _sendPasswordRecoveryEmail(event);
    }
    else if (event is AdminReturnToLoginEmailEvent) yield AdminLognReturnToEmailState();
    else if (event is AdminRebuildSocialLinksEvent){
      yield AdminUserRebuildSocialLinkState();
      yield AdminUserModificationState();
    }
    else if (event is AdminModifyingUserEvent) yield* _mapUserModificationEventToState(event);
    else if (event is AdminLoginButtonClickedEvent) yield* _mapAdminLoginClickedToState(event);
    else if (event is AdminSaveMyDetailsEvent) yield* _mapSaveUserDetailsToState(event);
    else if (event is AdminBodyChangedEvent){
      _selectedUser.body = event.body;
      yield AdminEmptyState();
      yield AdminUserRebuildBodyState();
    }
  }

  Stream<AdminState> _mapSaveUserDetailsToState(AdminSaveMyDetailsEvent event) async*{
    yield AdminUserImageUploadingState();
    _selectedUser.imgSrc = event.hasDeletedSrc ? '':_selectedUser.imgSrc;
    _selectedUser.role = event.role;
    if(event.file != null) _selectedUser.imgSrc = await _appStorage.uploadAndGetUserImageSrc(_selectedUser, event.file);

    await _userDBManager.updateUser(_selectedUser);
    yield AdminUserModUpdateUserState(_selectedUser);
    yield AdminUserImageUploadCompleteState();
  }

  Stream<AdminState> _mapAdminLoginClickedToState(AdminLoginButtonClickedEvent event)async*{
    yield AdminLoginLoadingState();
    AdminState theResult;

    await _auth.loginWithEmail(email: _loginEmail, password: _loginPassword)
    .then((user){
      UserFileDocument()..saveLoginData(_loginEmail, _loginPassword);
      theResult = AdminLoginCompletedState(user);
    })
    .catchError((error) {
      theResult = _mapErrorCodeToState(error.code);
    });
    yield AdminLoginPopLoginDialogState();
    yield theResult;
  }

  AdminLoginErrorState _mapErrorCodeToState(String errorCode){
    switch(errorCode){
      case "ERROR_INVALID_EMAIL": return AdminLoginEmailNotRecognisedState();
      case "ERROR_WRONG_PASSWORD": return AdminLoginIncorrectPasswordState();
      case "ERROR_USER_DISABLED": return AdminLoginUserDisabledState();
      case "ERROR_TOO_MANY_REQUESTS": return AdminLoginTooManyRequestsState();
      case "ERROR_OPERATION_NOT_ALLOWED": return AdminLoginOperationNotAllowedState();
      default: return AdminLoginUnknownErrorState();
    }
  }

  Stream<AdminState> _mapUserModificationEventToState(AdminModifyingUserEvent event) async* {
    if (event is AdminUserAdminLevelChangeEvent) {
      _selectedUser.adminLevel = event.selectedLevel;
      yield AdminUserAdminLevelChangedState();
      yield _canEnableAddUserButton();
      if(_originalUser != null) yield _canEnableUpdateUserButton(); 
    } else if (event is AdminUserModTextChangeEvent) {
      _selectedUser.forename = event.forename ?? _selectedUser.forename;
      _selectedUser.surname = event.surname ?? _selectedUser.surname;
      _selectedUser.email = event.email ?? _selectedUser.email.trim();
      _creationPassword = event.password ?? _creationPassword;
      _confirmPassword = event.confirmPassword??_confirmPassword;
      yield _canEnableAddUserButton();
    } else if (event is AdminUserModEditTextChangeEvent) {
      _selectedUser.forename = event.forename ?? _selectedUser.forename;
      _selectedUser.surname = event.surname ?? _selectedUser.surname;
      yield _canEnableUpdateUserButton();
    } else if (event is AdminUserModAddNewUserClickEvent) {
      if (_emailAlreadyExists()) yield AdminUserModEmailAlreadyExistsState();
      else if (_creationPassword.length < 6) yield AdminUserModPasswordTooSmallState();
      else if(_confirmPassword.compareTo(_creationPassword)!=0) yield AdminLoginConfirmationPasswordWrongState();
      else yield* _attemptToRegisterUser();
    }
  }

  Stream<AdminState> _attemptToRegisterUser() async*{
    yield AdminLoginAttempToRegisterUserState();
    await _auth.registerUserWithEmailAndPassword(_selectedUser.email, _creationPassword)
    .then((authUser){
      _selectedUser.authID = authUser.uid;
      _userDBManager.addUser(_selectedUser);
    }).catchError((error){
      print('----------------ERROR WHEN REGISTERING: \n' + error.toString());
    });
    yield AdminUserModAddNewUserState(_selectedUser);
  }

  bool _emailAlreadyExists() {
    if (_users.firstWhere((u) => u.email.compareTo(_selectedUser.email) == 0,orElse: () => null) !=null) return true;
    return false;
  }

  Stream<AdminState> _sendPasswordRecoveryEmail(AdminSendRecoveryEmailEvent event) async*{
    await _auth.sendPasswordRecovery(event.email);
    yield AdminLoginRecoveryEmailSentState();
  }

  AdminState _canEnableUpdateUserButton() {
    if ((_selectedUser.forename.compareTo(_originalUser.forename) != 0 ||
            _selectedUser.surname.compareTo(_originalUser.surname) != 0 ||
            _selectedUser.adminLevel != _originalUser.adminLevel) &&
        (_selectedUser.forename.trim().isNotEmpty &&
            _selectedUser.surname.trim().isNotEmpty)) {
      return AdminUserModEnableSaveButtonState();
    }
    return AdminUserModDisableButtonState();
  }

  AdminState _canEnableAddUserButton() {
    if (_selectedUser.forename.trim().isEmpty ||
        _selectedUser.surname.trim().isEmpty ||
        _selectedUser.email.trim().isEmpty ||
        _creationPassword.isEmpty ||
        _confirmPassword.isEmpty ||
        _selectedUser.adminLevel == null)
      return AdminUserModDisableButtonState();
    return AdminUserModEnableSaveButtonState();
  }

  AdminState _canContinueToPasswordState(AdminContinueClickEvent event) {
    User u = _users.firstWhere((user) => user.email.compareTo(_loginEmail) == 0, orElse: () => null);
    if (u != null) return AdminLoginContinueToPasswordState();
    return AdminLoginEmailNotRecognisedState();
  }

  Stream<AdminLoginState> _mapLoginTextChangeEventToState(AdminLoginTextChangeEvent event) async* {
    _loginEmail = event.email ?? _loginEmail;
    _loginPassword = event.password ?? _loginPassword;
    if (_loginEmail.isEmpty) yield AdminLoginDisableContinueState();
    else  yield AdminLoginEnableContinueState();
    if (_loginPassword.isEmpty) yield AdminLoginDisableLoginState();
    else yield AdminLoginEnableLoginState();
    
  }
}
