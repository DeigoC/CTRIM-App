import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  AdminBloc _adminBloc;
  BuildContext _context;

  @override
  void initState() {
    _adminBloc = AdminBloc(BlocProvider.of<AppBloc>(context));
    _adminBloc.setupUserToRegister();
    super.initState();
  }

  @override
  void dispose() {
    _adminBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminBloc>(
      create: (_) => _adminBloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Register User'),),
        body: Builder(builder: (_) {
          _context = _;
          return _buildBody();
        }),
      ),
    );
  }

  Widget _buildBody() {
    SizedBox padding = SizedBox(height: 8,);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('ID: ' + _adminBloc.selectedUser.id,style: TextStyle(fontSize: 18),),
        ),
        padding,
        MyTextField(
          label: 'Forename',
          controller: null,
          hint: 'Required',
          onTextChange: (newString) =>
              _adminBloc.add(AdminUserModTextChangeEvent(forename: newString)),
        ),
        padding,
        MyTextField(
          label: 'Surname',
          controller: null,
          hint: 'Required',
          onTextChange: (newString) =>
              _adminBloc.add(AdminUserModTextChangeEvent(surname: newString)),
        ),
        padding,
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _buildAdminLevelSelector(),
        ),
        SizedBox(height: 32,),
        MyTextField(
          label: 'Email',
          controller: null,
          hint: 'Required',
          textInputType: TextInputType.emailAddress,
          onTextChange: (newString) =>
              _adminBloc.add(AdminUserModTextChangeEvent(email: newString)),
        ),
        padding,
        MyTextField(
          label: 'Password',
          controller: null,
          hint: 'At least 6 chars.',
          obsucureText: true,
          onTextChange: (newString) =>
              _adminBloc.add(AdminUserModTextChangeEvent(password: newString)),
        ),
        padding,
        MyTextField(
          label: 'Confirm Password',
          controller: null,
          hint: 'Required',
          obsucureText: true,
          onTextChange: (newString) =>
              _adminBloc.add(AdminUserModTextChangeEvent(confirmPassword: newString)),
        ),
        padding,
        Container(
            padding: EdgeInsets.all(8),
            child: BlocConsumer(
              cubit: _adminBloc,
              listener: (_, state) {
                if (state is AdminUserModAddNewUserState) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if (state is AdminUserModPasswordTooSmallState) {
                  Scaffold.of(_context).showSnackBar(SnackBar(
                    content:Text('Password too small (at least 6 characters)!'),
                  ));
                } else if (state is AdminLoginConfirmationPasswordWrongState){
                  Scaffold.of(_context).showSnackBar(SnackBar(
                    content: Text('Confirmation Password is not correct!'),
                  ));
                } else if (state is AdminUserModEmailAlreadyExistsState) {
                  Scaffold.of(_context).showSnackBar(SnackBar(
                    content: Text('User with this email already exists!'),
                  ));
                }else if(state is AdminLoginAttempToRegisterUserState){
                  ConfirmationDialogue().uploadTaskStarted(context: context);
                }
              },
              buildWhen: (_, state) {
                if (state is AdminUserModEnableSaveButtonState) return true;
                else if (state is AdminUserModDisableButtonState) return true;
                return false;
              },
              builder: (_, state) {
                return RaisedButton(
                  child: Text('Register User'),
                  onPressed: (state is AdminUserModEnableSaveButtonState)
                      ? () =>_adminBloc.add(AdminUserModAddNewUserClickEvent())
                      : null,
                );
              }))
      ],
    );
  }

  Widget _buildAdminLevelSelector(){
    if(AdminCheck().isCurrentUserAboveLvl2(context)){
      return AdminDropdownList();
    }
    return Container();
  }
}
