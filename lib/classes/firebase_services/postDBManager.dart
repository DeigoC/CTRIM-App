import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/firebase_services/idTracker.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class PostDBManager{

  final CollectionReference _ref = FirebaseFirestore.instance.collection('posts');
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
    .where('SelectedTags',arrayContainsAny: tags)
    .get();
    
    List<Post> results = collection.docs.map((doc) => Post.fromMap(doc.id, doc.data())).toList();
    return results;
  }

  Future<Post> fetchPostByID(String id) async{
    var doc = await _ref.doc(id).get();
    return Post.fromMap(doc.id, doc.data());
  }

  Future<Null> addPost(Post post) async{
    post.id = await IDTracker().getAndUpdateNewPostID();
    await _appStorage.uploadNewPostFiles(post);
    await _ref.doc(post.id).set(post.toJson());
    post.temporaryFiles.clear();
  }

  Future<Null> updatePost(Post post) async{
    await _appStorage.uploadEditPostNewFiles(post);
    post.temporaryFiles.clear();
    _removeUnusedThumbnails(post);
    await _ref.doc(post.id).set(post.toJson());
  }

  void _removeUnusedThumbnails(Post post){
    List<String> gallerySrcs = post.gallerySources.keys.toList(), srcsToRemove =[];
    post.thumbnails.keys.forEach((src) {
      if(!gallerySrcs.contains(src)) srcsToRemove.add(src);
    });
    srcsToRemove.forEach((src) => post.thumbnails.remove(src));
  }

}