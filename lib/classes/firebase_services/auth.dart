import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';

class AuthService{

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Map<String,String> currentFirebaseUser = {'email':'', 'password':''};
  final UserDBManager _userDBManager = UserDBManager();
  

  Future<User> loginWithEmail({@required String email, @required String password}) async{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      /* .catchError((error){
        print('---------------HERE: THIS ERROR IS '+error.toString());
        throw error;
      }); */
      User u = _userDBManager.getUserByAuthUID(result.user.uid);
      currentFirebaseUser['email'] = email;
      currentFirebaseUser['password'] = password;
      return u;
  }

  Future logoutCurrentUser() async{
    await _auth.signOut();
  }
}