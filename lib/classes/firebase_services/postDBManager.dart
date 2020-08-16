import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/firebase_services/idTracker.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class PostDBManager{

  final CollectionReference _ref = Firestore.instance.collection('posts');
  final AppStorage _appStorage;

  PostDBManager(AppBloc appBloc): _appStorage = AppStorage(appBloc);

  Future<List<Post>> fetchPostsByIDs(List<String> postIDs) async{
    List<Post> results = [];
    await Future.forEach(postIDs, (id)async{
      Post p = await fetchPostByID(id);
      results.add(p);
    });
    return results;
  }

  Future<List<Post>> fetchPostsByTags(List<String> tags) async{
    var collection = await _ref
    .limit(10)
    .where('Deleted',isEqualTo: false)
    .where('SelectedTags',arrayContainsAny: tags)// change maybe?
    .getDocuments();
    
    List<Post> results = collection.documents.map((doc) => Post.fromMap(doc.documentID, doc.data)).toList();
    return results;
  }

  Future<Post> fetchPostByID(String id) async{
    var doc = await _ref.document(id).get();
    return Post.fromMap(doc.documentID, doc.data);
  }

  Future<Null> addPost(Post post) async{
    post.id = await IDTracker().getAndUpdateNewPostID();

    await _appStorage.uploadNewPostFiles(post);

    await _ref.document(post.id).setData(post.toJson());
    post.temporaryFiles.clear();
  }

  Future<Null> updatePost(Post post) async{
    await _appStorage.uploadEditPostNewFiles(post);
    post.temporaryFiles.clear();
    await _ref.document(post.id).setData(post.toJson());
  }

}