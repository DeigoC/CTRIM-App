import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppStorage{
  
  StorageReference _ref =  FirebaseStorage(storageBucket: 'gs://ctrim-app.appspot.com/').ref();

  Future<Null> uploadNewPostFiles(Post post) async{
    StorageUploadTask task;
    int index =0;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (file) async{
        String filePath = 'posts/${post.id}/item_$index';
        task = _ref.child(filePath).putFile(file);
        
        await  task.onComplete.then((_) async{
         await _ref.child(filePath).getDownloadURL().then((url){
          post.gallerySources[url] = post.temporaryFiles[file];
         });
         index++;
        });
      });
    }
    post.noOfGalleryItems = index;
  }

  Future<Null> uploadEditPostNewFiles(Post post,) async{
    StorageUploadTask task;
    int index = post.noOfGalleryItems;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (file) async{
        String filePath = 'posts/${post.id}/item_$index';
        print('-----------------INDEX IS ' + index.toString());
        task = _ref.child(filePath).putFile(file);
        
        await task.onComplete.then((_) async{
          await _ref.child(filePath).getDownloadURL().then((url){
            post.gallerySources[url] = post.temporaryFiles[file];
          });
          index++;
        });
      });
    }
    print('-----------------FINISHED: INDEX IS ' + index.toString());
    post.noOfGalleryItems = index;
  }
}