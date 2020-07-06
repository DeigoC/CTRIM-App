import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class PostDBManager{

  static final CollectionReference _ref = Firestore.instance.collection('posts');

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
      post.id = (int.parse(collection.documents.last.documentID) + 1).toString();
    });
    await _ref.document(post.id).setData(post.toJson());
  }

  Future<Null> updatePost(Post post) async{
    await _ref.document(post.id).setData(post.toJson());
  }

}