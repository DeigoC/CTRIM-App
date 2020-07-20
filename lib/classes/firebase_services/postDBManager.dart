import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class PostDBManager{

  final CollectionReference _ref = Firestore.instance.collection('posts');
  final AppStorage _appStorage;

  PostDBManager(AppBloc appBloc): _appStorage = AppStorage(appBloc);

  static List<Post> _allPosts;
  static List<Post> get allPosts => _allPosts;

  Future<List<Post>> fetchAllPosts() async{
    var collection = await _ref.getDocuments();
    _allPosts = collection.documents.map((doc) => Post.fromMap(doc.documentID, doc.data)).toList();
    return _allPosts;
  }

  Post getPostByID(String id){
    return _allPosts.firstWhere((p) => p.id.compareTo(id)==0,orElse: ()=>null);
  }

  Future<Null> addPost(Post post) async{
    await _ref.getDocuments().then((collection){
      List<int> allIDs = collection.documents.map((e) => int.parse(e.documentID)).toList();
      allIDs.sort();
      post.id = (int.parse(collection.documents.last.documentID) + 1).toString();
    });
    
    await _appStorage.uploadNewPostFiles(post);

    await _ref.document(post.id).setData(post.toJson());
    post.temporaryFiles.clear();
    _allPosts.add(post);
  }

  Future<Null> updatePost(Post post) async{
    await _appStorage.uploadEditPostNewFiles(post);
    post.temporaryFiles.clear();
    await _ref.document(post.id).setData(post.toJson());
  }

}