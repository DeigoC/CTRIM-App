import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PostNotification{

  final CollectionReference _ref = FirebaseFirestore.instance.collection('postNotification');
  final String serverToken =
  'AAAAf4pYxOg:APA91bEAwojWDqTMKdg4VH2DsPOMWE8QTiD0CuTUV8VIEer79fwHbkUldhSM9vqmyqJdD4Ks4bMyJ-U5AjZXdK9VcYkNhiLrb97f-tV5QiNKcHTii7SOEoK-CmO3OoyKFGuJtM7p4Lhj';

  Future addTokenToPostNotifications(String postID) async{
    final String token = await FirebaseMessaging().getToken();
    List<String> postTokens = await _fetchAllTokensForPost(postID);
    if(!postTokens.contains(token)){
      postTokens.add(token);
      await updatePostNotification(postID, postTokens);
    } 
  }

  Future removeTokenFromPostNotifications(String postID) async{
    final String token = await FirebaseMessaging().getToken();
    List<String> postTokens = await _fetchAllTokensForPost(postID);
    if(postTokens.contains(token)){
      postTokens.remove(token);
      await updatePostNotification(postID, postTokens);
    }
  }

  Future notifyAllTokensAboutUpdate(PostNotificationMessage postNotificationMessage) async{
    List<String> tokens = await _fetchAllTokensForPost(postNotificationMessage.postID);
    tokens.forEach((token) {
      _sendMessageToToken(postNotificationMessage, token);
    });
  }

  // ? Remember to add images in the future
  Future _sendMessageToToken(PostNotificationMessage postNotificationMessage, String token) async{
    Map<String,String> notification = {
      'body': postNotificationMessage.body,
      'title': postNotificationMessage.title,
    };
    if(postNotificationMessage.imageSrc!= null) notification['image'] = postNotificationMessage.imageSrc;
    
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode({
        'notification': notification,
        'priority': 'high',
        'data':{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'postID': postNotificationMessage.postID,
        },
        'to' : token,
      }),
    );
  }

  Future<List<String>> _fetchAllTokensForPost(String postID) async{
    var doc = await _ref.doc(postID).get();
    if(!doc.exists) return []; // ? Changed Idk if this is ok
    return List<String>.from(doc.data()['tokens'], growable: true); 
  }

  Future updatePostNotification(String postID, List<String> tokens) async{
    await _ref.doc(postID).set({'tokens':tokens});
  }
}

class PostNotificationMessage{
  final String title, body, postID, imageSrc;
  PostNotificationMessage({
    @required this.body, 
    @required this.postID, 
    @required this.title,
    this.imageSrc,
  });
}