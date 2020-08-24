import 'dart:convert';

import 'package:http/http.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' as dartIO show Platform ;

class NotificationHandler{

  final BuildContext _context;
  final CollectionReference _ref = Firestore.instance.collection('deviceTokens');

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

  // ! out of place but whatever
  final String serverToken = 
  'AAAAf4pYxOg:APA91bEAwojWDqTMKdg4VH2DsPOMWE8QTiD0CuTUV8VIEer79fwHbkUldhSM9vqmyqJdD4Ks4bMyJ-U5AjZXdK9VcYkNhiLrb97f-tV5QiNKcHTii7SOEoK-CmO3OoyKFGuJtM7p4Lhj';
  final Client client = Client();

  Future<Null> addTokenDevice(String token) async{
    if(dartIO.Platform.isAndroid){
      List<String> allAndroidTokens = await _fetchAllAndroidTokens();
      if(!allAndroidTokens.contains(token)){
        allAndroidTokens.add(token);
        _updateAndroidTokens(allAndroidTokens);
      }
    }
    
  }

  Future<List<String>> _fetchAllAndroidTokens() async{
    var collection = await _ref.document('android').get();
    List<String> result = List.from(collection.data['tokens'],growable: true);
    return result;
  }

  Future<Null> _updateAndroidTokens(List<String> tokens) async{
    _ref.document('android').setData({'tokens':tokens});
  }

  Future<Null> notifyUsersAboutPost(Post post) async{
    _fetchAllAndroidTokens().then((allTokens){
      allTokens.forEach((token) {
        _sendNoticication(post: post, token: token);
      });
    });
  }

  Future<Response> _sendNoticication({@required Post post, @required String token}){
    Map<String,String> notification ={
      'body': post.description,
      'title':post.title,
    };

    if(post.firstImageSrc != null){
      notification['image'] = post.firstImageSrc;
    }
    
    return client.post(
      'https://fcm.googleapis.com/fcm/send',
      body: json.encode({
        'notification':notification,
        'to':token,
        'data':{
          'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
          'postID':post.id,
        },
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      }
    );
  }
}