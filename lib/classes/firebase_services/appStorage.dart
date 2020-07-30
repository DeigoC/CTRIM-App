import 'dart:io';
import 'dart:typed_data';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AppStorage{
  
  StorageReference _ref =  FirebaseStorage(storageBucket: 'gs://ctrim-app.appspot.com/').ref();

  final AppBloc _appBloc;
  AppStorage(this._appBloc);


  Future<Null> uploadNewPostFiles(Post post) async{
    StorageUploadTask task;
    int index =0;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        String filePath = 'posts/${post.id}/item_$index';
        task = _ref.child(filePath).putFile(File(fileSrc));
        
        //TODO apply this to all upload tasks
        _appBloc.add(AppUploadTaskStartedEvent(task: task, itemNo: index + 1,totalLength: post.temporaryFiles.length));
        
        await  task.onComplete.then((_) async{
         await _ref.child(filePath).getDownloadURL().then((url) async{
          post.gallerySources[url] = post.temporaryFiles[fileSrc];
          if(post.temporaryFiles[fileSrc] == 'vid'){
            post.thumbnails[url] = await _uploadAndGetVideoThumbnailSrc(fileSrc, filePath);
          }
         });
         index++;
        });
      });
    }
    post.noOfGalleryItems = index;
  }

  Future<String> _uploadAndGetVideoThumbnailSrc(String fileSrc, String filePath) async{
    Uint8List data = await VideoThumbnail.thumbnailData(video: fileSrc);
    String newFilePath = filePath +'_thumbnail';

    StorageUploadTask task;

    String directory;
    await getApplicationDocumentsDirectory().then((d) => directory = d.path);
    await File('$directory/thing.png').create(recursive: true)
    .then((thumbnail) async{
      final buffer = data.buffer;
      var anotherFile = await thumbnail.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      task =_ref.child(newFilePath).putFile(anotherFile);
    });

    await task.onComplete;
    return (await _ref.child(newFilePath).getDownloadURL()).toString();
  }

  Future<Null> uploadEditPostNewFiles(Post post,) async{
    StorageUploadTask task;
    int index = post.noOfGalleryItems;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (file) async{
        String filePath = 'posts/${post.id}/item_$index';
        task = _ref.child(filePath).putFile(file);
        
         _appBloc.add(AppUploadTaskStartedEvent(task: task, itemNo: index + 1,totalLength: post.temporaryFiles.length));

        await task.onComplete.then((_) async{
          await _ref.child(filePath).getDownloadURL().then((url){
            post.gallerySources[url] = post.temporaryFiles[file];
          });
          index++;
        });
      });
    }
    post.noOfGalleryItems = index;
  }

  Future<String> uploadAndGetUserImageSrc(User user, File file) async{
    String downloadSrc;
    String fullname = user.forename + ' ' + user.surname;
    String filePath = 'users/${user.id}-$fullname';
    StorageUploadTask task = _ref.child(filePath).putFile(file);
    await task.onComplete.then((_) async{
      await _ref.child(filePath).getDownloadURL().then((url){
        downloadSrc = url;
      });
    });
    return downloadSrc;
  }

  Future<String> uploadAndGetLocationImageSrc(Location location, File file) async{
    String downloadSrc;
    String filePath = 'locations/${location.id}';
    StorageUploadTask task = _ref.child(filePath).putFile(file);
    await task.onComplete;
    await _ref.child(filePath).getDownloadURL().then((url){
      downloadSrc = url;
    });
    return downloadSrc;
  }

}