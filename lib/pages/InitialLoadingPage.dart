import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/aboutDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/locationDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/postDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/timelinePostDBManager.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
      backgroundColor: LightPrimaryColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'openningIcon',
              child: Icon(FontAwesome5Solid.church, color: Colors.white,size: MediaQuery.of(context).size.width * 0.4,)),
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _loadAllData() async{
    try{
      LocationDBManager locationDBManager = LocationDBManager(BlocProvider.of<AppBloc>(context));
      UserDBManager userDBManager = UserDBManager();
      PostDBManager postDBManager = PostDBManager(BlocProvider.of<AppBloc>(context));
      TimelinePostDBManager timelinePostDBManager = TimelinePostDBManager();
      AboutDBManager aboutDBManager = AboutDBManager();
      
      await aboutDBManager.fetchAllPosts();
      await locationDBManager.fetchAllLocations();
      await postDBManager.fetchAllPosts();
      await timelinePostDBManager.fetchAllTimelinePosts();
      userDBManager.fetchAllUsers().then((_){
        BlocProvider.of<AppBloc>(context).add(AppStartupLoadUserEvent());
      });
    }catch(e){
      _showStartupErrorException();
    }
  }

  void _showStartupErrorException(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return AlertDialog(
          title: Text('Start up error!'),
          content: Text('A problem occured when opening the app, please check that the app is up to date.' +
          '\n\nThe app may or may not function after this point.'),
          actions: [
            MyFlatButton(
              label: 'OK',
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }
}