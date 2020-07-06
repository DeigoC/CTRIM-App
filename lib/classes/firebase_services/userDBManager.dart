import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';

class UserDBManager{

  // ! This class will hold all the users staticly
  static List<User> _allUsers =[
    User(
      // * password1
      id: '1',
      forename: 'Diego',
      surname: 'Collado',
      email: 'diego@email.com',
      adminLevel: 3,
      contactNo: '012301230',
      authID: 'FWifjH3EcfR2u5xiPDsEFewLtro2',
      likedPosts: [],
    ),
    User(
      id: '3',
      forename: 'Claudette',
      surname: 'Collado',
      email: 'claudette@email',
      adminLevel: 2,
      contactNo: '0111111111111110',
      likedPosts: [],
    ),
    User(
      id: '2',
      forename: 'Dana',
      surname: 'Collado',
      email: 'DaNa@email',
      adminLevel: 1,
      contactNo: '0111111111111110',
      likedPosts: [],
    ),
  ];

  static List<User> get allUsers => _allUsers;

  static final CollectionReference _ref = Firestore.instance.collection('users');

  Future<List<User>> fetchAllUsers() async{
    var collections = await _ref.getDocuments();
    _allUsers = collections.documents.map((doc) => User.fromMap(doc.documentID, doc.data)).toList();
    return _allUsers;
  }

  Future<Null> addUser(User user) async{
    await _ref.document(user.id).setData(user.toJson());
  }

  Future<Null> updateUser(User user) async{
    await _ref.document(user.id).setData(user.toJson());
  }

  User getUserByID(String id) {
    return _allUsers.firstWhere((u) => u.id.compareTo(id)==0,orElse: ()=>null);
  }

  User getUserByAuthUID(String authID){
    return _allUsers.firstWhere((u) => u.authID.compareTo(authID)==0,orElse: ()=> null);
  }

}