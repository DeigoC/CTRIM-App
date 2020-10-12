import 'dart:io' show Platform;

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationHandler{

  // * Android custom message looks like
  /*
    {notification: 
      {title: Worship Concert 2020!, body: Removed the description changes. This is a test btw}, 
      data: {postID: 14, click_action: FLUTTER_NOTIFICATION_CLICK}
    }
  */

  // * iOS custom message looks like
  /*
    insert here
  */

  final BuildContext _context;

  NotificationHandler(this._context);

  void handleOnMessage(Map<String,dynamic> message){
    if(Platform.isAndroid) _handleAndroidOnMessage(message);
    else _handleiOSOnMessage(message);
  }

  void _handleAndroidOnMessage(Map<String,dynamic> message){
    final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
    final  Map<String, dynamic> notificationLabels = Map<String, dynamic>.from(message['notification']);
   
    if(notificationData.keys.contains('postID')){
      _displayPostHighlight(
        postID: notificationData['postID'],
        title: notificationLabels['title'],
        body: notificationLabels['body'],
      );
    }
  }

  void _handleiOSOnMessage(Map<String,dynamic> message){
    final  Map<String, dynamic> notificationLabels = Map<String, dynamic>.from(message['aps']['alert']);
    if(message.keys.contains('postID')){
      _displayPostHighlight(
        postID: message['postID'],
        title: notificationLabels['title'],
        body: notificationLabels['body'],
      );
    }
  }

  void _displayPostHighlight({String postID, String title, String body}){
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (_){
          return AlertDialog(
            title: Text('Received Notification!',textScaleFactor: 1.2,textAlign: TextAlign.center,),
            content: RichText(
              text: TextSpan(
                text: title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: BlocProvider.of<AppBloc>(_context).onDarkTheme ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "\n\n$body",
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

  void handleOnResume(Map<String,dynamic> message){
    if(Platform.isAndroid){
      final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
      if(notificationData.keys.contains('postID')) _openPost(notificationData['postID']);
    }else{
      if(message.keys.contains('postID')) _openPost(message['postID']);
    }
    
  }

  void handleOnLaunch(Map<String,dynamic> message){
    if(Platform.isAndroid){
      final Map<String, dynamic> notificationData = Map<String, dynamic>.from(message['data']);
      if(notificationData.keys.contains('postID')) _openPost(notificationData['postID']);
    }else{
      if(message.keys.contains('postID')) _openPost(message['postID']);
    }
  }

  void _openPost(String postID){
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(postID));
  }
}