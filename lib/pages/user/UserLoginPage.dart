import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
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
    _adminBloc = AdminBloc(BlocProvider.of<TimelineBloc>(context).allUsers);
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
      appBar: AppBar(title: Text('Admin Login'), centerTitle: true,),
      body: Builder(
        builder:(_){
          _context = _;
          return BlocConsumer(
            bloc: _adminBloc,
            listener: (_,state){
              if(state is AdminLoginEmailNotRecognisedState) _showEmailNotRecognised();
            },
            buildWhen: (previousState, currentState){
              if(currentState is AdminLoginContinueToPasswordState) return true;
              else if( currentState is AdminLognReturnToEmailState) return true;
              return false;
            },
            builder:(_, state){
              return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildChildren(state),
            );
            } 
          );
        } 
      ),
    );
  }

  List<Widget> _buildChildren(AdminState state){
    if(state is AdminLoginContinueToPasswordState){
      // ! Entering PASSWORD
      return [
        Row(
          children: [
            Expanded(
              child: MyTextField(
                label: 'Email', 
                controller: _tecEmail,
                readOnly: true,
                ),
            ),
            FlatButton(
              child: Text('Not you?'),
              onPressed: ()=> _adminBloc.add(AdminReturnToLoginEmailEvent()),
            ),
          ],
        ),
        SizedBox(height: 8),
       MyTextField(
        label: 'Password', 
        controller: null,
        onTextChange: (newPassword) => _adminBloc.add(AdminLoginTextChangeEvent(password: newPassword)),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: FlatButton(
          child: Text('Forgot Password'),
          onPressed: (){},
        ),
      ),
      RaisedButton(
        onPressed: (){},
        child: Text('LOGIN'),
      ),
      ];
    }
    // ! Entering Email
    return [
       MyTextField(
        label: 'Email', 
        controller: _tecEmail,
        onTextChange: (newEmail) => _adminBloc.add(AdminLoginTextChangeEvent(
          email: newEmail
        )),
      ),
      BlocBuilder(
        bloc: _adminBloc,
        condition: (prev, currentState){
          if(currentState is AdminLoginDisableContinueState || currentState is AdminLoginEnableContinueState) return true;
          return false;
        },
        builder:(_,state){
          return RaisedButton(
            onPressed: (state is AdminLoginEnableContinueState) ? () => _adminBloc.add(AdminContinueClickEvent()) : null,
            child: Text('CONTINUE'),
          );
        } 
      ),
    ];
  }

  void _showEmailNotRecognised(){
    Scaffold.of(_context).showSnackBar(SnackBar(
      content: Text('Email not recognised'),
      behavior: SnackBarBehavior.fixed,
      duration: Duration(minutes: 5),
      action: SnackBarAction(label: 'OK', onPressed: () => null),
    ));
  }
}