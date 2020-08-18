import 'dart:io';
import 'dart:typed_data';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AppStorage{
  
  StorageReference _ref =  FirebaseStorage(storageBucket: 'gs://ctrim-app.appspot.com/').ref();
  String directory ='';

  final AppBloc _appBloc;

  AppStorage(this._appBloc){
    getApplicationDocumentsDirectory().then((d) => directory =d.path);
  }

  Future<Null> uploadNewPostFiles(Post post) async{
    StorageUploadTask task;
    int index =0, itemNo=1, totalLength=post.temporaryFiles.length;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        File itemToSend = File(fileSrc);
        itemNo = index + 1;
        String filePath = 'posts/${post.id}/item_$index';

        if(post.temporaryFiles[fileSrc]=='img'){
          _appBloc.add(AppUploadCompressingImageEvent(itemNo: itemNo, totalLength: totalLength));
          itemToSend = await _compressImage(fileSrc);
        }
        
        task = _ref.child(filePath).putFile(itemToSend);
        _appBloc.add(AppUploadTaskStartedEvent(task: task, itemNo: itemNo,totalLength: totalLength));
        
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

  Future<File> _compressImage(String originalFilePath) async{
    String targetPath = directory+'/compressionImage.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      originalFilePath, 
      targetPath,
    );
    return result;
  } 

  Future<String> _uploadAndGetVideoThumbnailSrc(String fileSrc, String filePath) async{
    Uint8List data = await VideoThumbnail.thumbnailData(video: fileSrc);
    String newFilePath = filePath +'_thumbnail';

    StorageUploadTask task;

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
    int index = post.noOfGalleryItems, itemNo=1, totalLength=post.temporaryFiles.length;
    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        File itemToSend = File(fileSrc);
        String filePath = 'posts/${post.id}/item_$index';
        itemNo = index - totalLength;

        if(post.temporaryFiles[fileSrc]=='img'){
          _appBloc.add(AppUploadCompressingImageEvent(itemNo: itemNo, totalLength: totalLength));
          itemToSend = await _compressImage(fileSrc);
        }

        task = _ref.child(filePath).putFile(itemToSend);
        _appBloc.add(AppUploadTaskStartedEvent(task: task, itemNo: itemNo,totalLength: totalLength));

        await task.onComplete.then((_) async{
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