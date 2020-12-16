import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  AdminBloc _adminBloc;
  BuildContext _context;

  TextEditingController _tecEmail;

  @override
  void initState() {
    super.initState();
    _adminBloc = AdminBloc(BlocProvider.of<AppBloc>(context));
    _tecEmail = TextEditingController();
  }

  @override
  void dispose() {
    _adminBloc.close();
    _tecEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        centerTitle: true,
      ),
      body: Builder(builder: (_) {
        _context = _;
        return BlocConsumer(
            cubit: _adminBloc,
            listener: (_, state) {
              if (state is AdminLoginErrorState) _mapErrorStatesToSnackbars(state);
              else if(state is AdminLoginCompletedState) _loginCompleted(state);
              else if(state is AdminLoginPopLoginDialogState){
                Navigator.of(context).pop();
              }
              else if(state is AdminLoginLoadingState){
                _showLoadingDialog();
              }else if(state is AdminLoginRecoveryEmailSentState){
                Navigator.of(context).pop();
                Scaffold.of(_context).showSnackBar(SnackBar(
                  content: Text('Password Recovery Email Sent!'),
                ));
              }
            },
            buildWhen: (previousState, currentState) {
              if (currentState is AdminLoginContinueToPasswordState)
                return true;
              else if (currentState is AdminLognReturnToEmailState) return true;
              return false;
            },
            builder: (_, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildChildren(state),
                  ),
                ),
              );
            });
      }),
    );
  }

  List<Widget> _buildChildren(AdminState state) {
    if (state is AdminLoginContinueToPasswordState) {
      // ! Entering PASSWORD
      return [
        Row(
          children: [
            Expanded(
              child: MyTextField(
                label: 'Email',
                controller: _tecEmail,
                readOnly: true,
                buildHelpIcon: false,
                optional: true,
              ),
            ),
            MyFlatButton(
              label: 'Not You?',
              onPressed: () => _adminBloc.add(AdminReturnToLoginEmailEvent())
            ),
          ],
        ),
        SizedBox(height: 8),
        MyTextField(
          label: 'Password',
          textInputType: TextInputType.visiblePassword,
          autoFocus: true,
          controller: null,
          obsucureText: true,
          optional: true,
          buildHelpIcon: false,
          onTextChange: (newPassword) =>_adminBloc.add(AdminLoginTextChangeEvent(password: newPassword)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: MyFlatButton(
            label: 'Forgot Password',
            onPressed: ()=>_showSendRecoveryEmailDialog(),
          )
        ),
        BlocBuilder(
          cubit: _adminBloc,
          buildWhen: (_,state){
            if(state is AdminLoginEnableLoginState || state is AdminLoginDisableLoginState) return true;
            return false;
          },
          builder:(_,state){
            return MyRaisedButton(
              onPressed:(state is AdminLoginEnableLoginState) ? () => _adminBloc.add(AdminLoginButtonClickedEvent()) 
              : null,
              label: 'LOGIN',
              externalPadding: EdgeInsets.symmetric(horizontal: 8),
            );
          } 
        ),
      ];
    }
    // ! Entering Email
    return [
      MyTextField(
        label: 'Email',
        controller: _tecEmail,
        autoFocus: true,
        buildHelpIcon: false,
        optional: true,
        textInputType: TextInputType.emailAddress,
        onTextChange: (newEmail) =>
            _adminBloc.add(AdminLoginTextChangeEvent(email: newEmail)),
      ),
      BlocBuilder(
        cubit: _adminBloc,
        buildWhen: (prev, currentState) {
          if (currentState is AdminLoginDisableContinueState ||currentState is AdminLoginEnableContinueState) return true;
          return false;
        },
        builder: (_, state) {
          return MyRaisedButton(
            externalPadding: EdgeInsets.all(8.0),
            label: 'CONTINUE',
            onPressed: (state is AdminLoginEnableContinueState) ? () => _adminBloc.add(AdminContinueClickEvent()): null,
          );
        }),
    ];
  }

  void _loginCompleted(AdminLoginCompletedState state){
    BlocProvider.of<AppBloc>(context).add(AppCurrentUserLoggedInEvent(state.user));
    Navigator.of(context).pop();
  }

  void _mapErrorStatesToSnackbars(AdminLoginErrorState state){
    if(state is AdminLoginEmailNotRecognisedState) _showErrorSnackbar('Email not Recognised');
    else if(state is AdminLoginIncorrectPasswordState) _showErrorSnackbar('Incorrect Password');
    else if(state is AdminLoginUserDisabledState) _showErrorSnackbar('This user is Disabled');
    else if(state is AdminLoginTooManyRequestsState)_showErrorSnackbar('Too many requests made, try again another time');
    else if(state is AdminLoginOperationNotAllowedState)_showErrorSnackbar('Operation not Available');
    else _showErrorSnackbar('Unknown Error Occurred');
  }

  void _showLoadingDialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return WillPopScope(
          onWillPop: ()async=> false,
          child: Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width*0.3,
              height: MediaQuery.of(context).size.width*0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16,),
                  Text('Loggin in...'),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void _showSendRecoveryEmailDialog(){
    showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Password Recovery'),
          content: Text('Send password recovery email to: ' + _tecEmail.text.trim() + '?'),
          actions: [
            MyFlatButton(
              label: 'Cancel',
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            MyFlatButton(
              label: 'Send Email',
              onPressed: (){
                _adminBloc.add(AdminSendRecoveryEmailEvent(_tecEmail.text.trim()));
              },
            ),
          ],
        );
      }
    );
  }

  void _showErrorSnackbar(String content) {
    Scaffold.of(_context).showSnackBar(SnackBar(
      content: Text('ERROR: '+content),
    ));
  }
}
