import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppStorage{
  
  FirebaseStorage _firebaseStorage =  FirebaseStorage(storageBucket: 'gs://ctrim-app.appspot.com/');

  Future<Null> uploadNewPostFiles(Post post) async{
    StorageUploadTask task;
    if(post.temporaryFiles.length != 0){
      int index =0;
      await Future.forEach(post.temporaryFiles.keys, (file) async{
        String filePath = 'posts/${post.id}/item_$index';
        task = _firebaseStorage.ref().child(filePath).putFile(file);
        index++;
        await  task.onComplete.then((_) async{
         await _firebaseStorage.ref().child(filePath).getDownloadURL().then((url){
          post.gallerySources[url] = post.temporaryFiles[file];
         });
        });
      });
    }
  }
}