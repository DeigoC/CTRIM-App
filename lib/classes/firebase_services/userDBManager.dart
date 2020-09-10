import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';

class UserDBManager{

  // ! This class will hold all the users staticly
  //static List<User> _allUsers;
  //static List<User> get allUsers => _allUsers;

  static final CollectionReference _ref = Firestore.instance.collection('users');
  static List<User> _mainFeedUsers;
  static List<User> get mainFeedUsers => _mainFeedUsers;

  Future<List<User>> fetchAllUsers() async{
    var collections = await _ref.getDocuments();
    List<User> results = collections.documents.map((doc) => User.fromMap(doc.documentID, doc.data)).toList();
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
    var collections = await _ref.where('AdminLevel',isEqualTo: 3).limit(5).getDocuments();
    List<User> results = collections.documents.map((doc) => User.fromMap(doc.documentID, doc.data)).toList();
    return results;
  }

  Future<Null> addUser(User user) async{
    await _ref.getDocuments().then((collection){
      List<int> allIDs = collection.documents.map((e) => int.parse(e.documentID)).toList();
      allIDs.sort();

      user.id = (allIDs.last + 1).toString();
    });
    await _ref.document(user.id).setData(user.toJson());
  }

  Future<Null> updateUser(User user) async{
    await _ref.document(user.id).setData(user.toJson());
  }

  Future<User> fetchUserByID(String id) async{
    var doc = await _ref.document(id).get();
    return User.fromMap(doc.documentID, doc.data);
  }

  // ? Might not need
  Future<User> fetchUserByAuthID(String authID) async{
    var col = await _ref.where('AuthID',isEqualTo: authID).limit(1).getDocuments();
    var doc = col.documents.first; 
    return User.fromMap(doc.documentID, doc.data);
  }
  
  Future<User> fetchUserByEmail(String email) async{
    var col = await _ref.where('Email',isEqualTo: email).limit(1).getDocuments();
    if(col.documents.length==0) return null;
    var doc = col.documents.first; 
    return User.fromMap(doc.documentID, doc.data);
  }
}