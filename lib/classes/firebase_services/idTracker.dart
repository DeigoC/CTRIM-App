import 'package:cloud_firestore/cloud_firestore.dart';

class IDTracker{

  final CollectionReference _ref = FirebaseFirestore.instance.collection('idTracker');

  Future<String> getAndUpdateNewPostID() async{
    var doc = await _ref.doc('posts').get();
    int latestID = doc.data()['latestID'];
    String newPostID = (latestID + 1).toString();
    _ref.doc('posts').set({'latestID':latestID+1});
    return newPostID;
  }

  Future<String> getAndUpdateNewLocationID() async{
    var doc = await _ref.doc('locations').get();
    int latestID = doc.data()['latestID'];
    String newPostID = (latestID + 1).toString();
    _ref.doc('locations').set({'latestID':latestID+1});
    return newPostID;
  }
}