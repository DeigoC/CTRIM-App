import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/aboutDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/timelinePostDBManager.dart';
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
    _loadAllData();
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

  Future<Null> _loadAllData() async{
    LocationDBManager locationDBManager = LocationDBManager();
    UserDBManager userDBManager = UserDBManager();
    PostDBManager postDBManager = PostDBManager();
    TimelinePostDBManager timelinePostDBManager = TimelinePostDBManager();
    AboutDBManager aboutDBManager = AboutDBManager();
    
    await aboutDBManager.fetchAllPosts();
    await locationDBManager.fetchAllLocations();
    await postDBManager.fetchAllPosts();
    await timelinePostDBManager.fetchAllTimelinePosts();
    userDBManager.fetchAllUsers().then((_){
      BlocProvider.of<AppBloc>(context).add(AppStartupLoadUserEvent());
    });
  }
}