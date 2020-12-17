import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as authPackage;
import 'package:flutter/material.dart';
import 'package:ctrim_app_v1/classes/firebase_services/userDBManager.dart';

class AuthService{

  static final authPackage.FirebaseAuth _auth = authPackage.FirebaseAuth.instance;
  static Map<String,String> currentFirebaseUser = {'email':'', 'password':''};
  final UserDBManager _userDBManager = UserDBManager();

  Future<User> loginWithEmail({@required String email, @required String password}) async{
      authPackage.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User u = await _userDBManager.fetchUserByAuthID(result.user.uid);
      currentFirebaseUser['email'] = email;
      currentFirebaseUser['password'] = password;
      return u;
  }

  Future logoutCurrentUser() async{
    await _auth.signOut();
  }
 
  Future<authPackage.UserCredential> registerUserWithEmailAndPassword(String email, String password) async{
    authPackage.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result;
  }

  Future sendPasswordRecovery(String email) async{
    await _auth.sendPasswordResetEmail(email: email);
  }
}