import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';

class UserDBManager{

  final CollectionReference _ref = FirebaseFirestore.instance.collection('users');
  static List<User> _mainFeedUsers;
  static List<User> get mainFeedUsers => _mainFeedUsers;

  Future<List<User>> fetchAllUsers() async{
    var collections = await _ref.get();
    List<User> results = collections.docs.map((doc) => User.fromMap(doc.id, doc.data())).toList();
    return results;
  }

  Future<List<User>> fetchMainFeedUsers(List<String> ids) async{
    _mainFeedUsers = await fetchListOfUsersByID(ids);
    return _mainFeedUsers;
  }

  Future<List<User>> fetchListOfUsersByID(List<String> ids) async{
    List<User> results =[];
    await Future.forEach(ids, (id)async{
      results.add(await fetchUserByID(id));
    });
    return results;
  }

  Future<List<User>> fetchLevel3Users() async{
    var collections = await _ref.where('AdminLevel',isEqualTo: 3).limit(5).get();
    List<User> results = collections.docs.map((doc) => User.fromMap(doc.id, doc.data())).toList();
    return results;
  }

  Future<Null> addUser(User user) async{
    await _ref.get().then((collection){
      List<int> allIDs = collection.docs.map((e) => int.parse(e.id)).toList();
      allIDs.sort();

      user.id = (allIDs.last + 1).toString();
    });
    await _ref.doc(user.id).set(user.toJson());
  }

  Future<Null> updateUser(User user) async{
    await _ref.doc(user.id).set(user.toJson());
  }

  Future<User> fetchUserByID(String id) async{
    var doc = await _ref.doc(id).get();
    return User.fromMap(doc.id, doc.data());
  }

  // ? Might not need
  Future<User> fetchUserByAuthID(String authID) async{
    var col = await _ref.where('AuthID',isEqualTo: authID).limit(1).get();
    var doc = col.docs.first; 
    return User.fromMap(doc.id, doc.data());
  }
  
  Future<User> fetchUserByEmail(String email) async{
    var col = await _ref.where('Email',isEqualTo: email).limit(1).get();
    if(col.docs.length==0) return null;
    var doc = col.docs.first; 
    return User.fromMap(doc.id, doc.data());
  }
}