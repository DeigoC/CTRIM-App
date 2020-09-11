import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationHandler{

  final BuildContext _context;

  NotificationHandler(this._context);

  void handleOnMessage(Map<String,dynamic> message){
    final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
    final  Map<String, dynamic> notificationLabels = Map<String, dynamic>.from(message['notification']);
    if(_hasPost(notificationData)){
      String postID = notificationData['postID'];
      showDialog(
        context: _context,
        builder: (_){
          return AlertDialog(
            title: Text('Highlighted Post Notification!',textScaleFactor: 1.2,textAlign: TextAlign.center,),
            content: RichText(
              text: TextSpan(
                text: notificationLabels['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: BlocProvider.of<AppBloc>(_context).onDarkTheme ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "\n\n${notificationLabels['body']}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal, 
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: BlocProvider.of<AppBloc>(_context).onDarkTheme ? Colors.white : Colors.black,
                    ),
                    
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text('Close'),
                onPressed: (){
                  Navigator.of(_context).pop();
                },
              ),
              FlatButton(
                child: Text('View Post'),
                onPressed: (){
                  Navigator.of(_context).pop();
                  BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(postID));
                },
              ),
            ],
          );
        }
      );
    }
  }

  void handleOnResume(Map<String,dynamic> message){
    final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
    if(_hasPost(notificationData)) _openPost(notificationData['postID']);
  }

  void handleOnLaunch(Map<String,dynamic> message){
    final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
    if(_hasPost(notificationData)) _openPost(notificationData['postID']);
  }

  bool _hasPost(Map<String, dynamic> notificationData){
    if(notificationData.keys.contains('postID')) return true;
    return false;
  }

  void _openPost(String postID){
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(postID));
  }
}