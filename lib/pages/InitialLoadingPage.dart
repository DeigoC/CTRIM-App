import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialLoadingPage extends StatefulWidget {
  @override
  _InitialLoadingPageState createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends State<InitialLoadingPage> {

  @override
  void initState() {
    UserDBManager()..fetchUsers().then((allUsers){
      BlocProvider.of<AppBloc>(context).add(AppStartupLoadUserEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20,),
            Text('Initialising User',style: TextStyle(fontSize: 34, color: Colors.white),),
          ],
        ),
      ),
    );
  }
}