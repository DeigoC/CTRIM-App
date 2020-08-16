import 'package:cloud_firestore/cloud_firestore.dart';

class IDTracker{

  final CollectionReference _ref = Firestore.instance.collection('idTracker');

  Future<String> getAndUpdateNewPostID() async{
    var doc = await _ref.document('posts').get();
    int latestID = doc.data['latestID'];
    String newPostID = (latestID + 1).toString();
    _ref.document('posts').setData({'latestID':latestID+1});
    return newPostID;
  }

  Future<String> getAndUpdateNewLocationID() async{
    var doc = await _ref.document('locations').get();
    int latestID = doc.data['latestID'];
    String newPostID = (latestID + 1).toString();
    _ref.document('locations').setData({'latestID':latestID+1});
    return newPostID;
  }
}