import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';

class UserDBManager{

  // ! This class will hold all the users staticly
  static List<User> _allUsers;

  static List<User> get allUsers => _allUsers;

  static final CollectionReference _ref = Firestore.instance.collection('users');

  Future<List<User>> fetchAllUsers() async{
    var collections = await _ref.getDocuments();
    print('-------------body contains: ' + collections.documents.first.data['Body']);
    _allUsers = collections.documents.map((doc) => User.fromMap(doc.documentID, doc.data)).toList();
    return _allUsers;
  }

  Future<Null> addUser(User user) async{
    await _ref.getDocuments().then((collection){
      List<int> allIDs = collection.documents.map((e) => int.parse(e.documentID)).toList();
      allIDs.sort();

      user.id = (allIDs.last + 1).toString();
    });
    await _ref.document(user.id).setData(user.toJson());
    _allUsers.add(user);
  }

  Future<Null> updateUser(User user) async{
    await _ref.document(user.id).setData(user.toJson());
    _updateListUser(user);
  }

  User getUserByID(String id) {
    return _allUsers.firstWhere((u) => u.id.compareTo(id)==0,orElse: ()=>null);
  }

  User getUserByAuthUID(String authID){
    return _allUsers.firstWhere((u) => u.authID.compareTo(authID)==0,orElse: ()=> null);
  }

  void _updateListUser(User user){
    int index = _allUsers.indexWhere((u) => u.id.compareTo(user.id)==0);
    _allUsers[index] = user;
  }
}