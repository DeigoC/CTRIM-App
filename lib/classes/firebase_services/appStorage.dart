import 'dart:io';
import 'dart:typed_data';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart';

class AppStorage{
  
  final StorageReference _ref =  FirebaseStorage(storageBucket: 'gs://ctrim-app.appspot.com/').ref();
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
        String fileName = basename(itemToSend.path);

        // * Compress the item
        if(post.temporaryFiles[fileSrc]=='img'){
          _appBloc.add(AppUploadCompressingImageEvent(
            itemNo: itemNo, 
            totalLength: totalLength,
            fileName: fileName
          ));
          itemToSend = await _compressImage(fileSrc);
        }else if(post.temporaryFiles[fileSrc]=='vid'){
          _appBloc.add(AppUploadCompressingVideoEvent(
            fileName: fileName,
            itemNo: itemNo,
            totalLength: totalLength,
          ));
          itemToSend = await _compressVideo(fileSrc);
        }
        
        // * Upload the item
        task = _ref.child(filePath).putFile(itemToSend);
        _appBloc.add(AppUploadTaskStartedEvent(
          task: task, 
          itemNo: itemNo,
          totalLength: totalLength,
          fileName: fileName,
        ));
        
        // * Fetch the new item's download link
        await  task.onComplete.then((_) async{
         await _ref.child(filePath).getDownloadURL().then((url) async{
          post.gallerySources[url] = post.temporaryFiles[fileSrc];

          // * Upload and get video thumbnail
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

  Future<Null> uploadEditPostNewFiles(Post post,) async{
    StorageUploadTask task;
    int index = post.noOfGalleryItems, itemNo=1, totalLength=post.temporaryFiles.length;

    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        File itemToSend = File(fileSrc);
        String filePath = 'posts/${post.id}/item_$index';
        String fileName = basename(itemToSend.path);

        // * Compress the item
        if(post.temporaryFiles[fileSrc]=='img'){
          _appBloc.add(AppUploadCompressingImageEvent(
            itemNo: itemNo, 
            totalLength: totalLength,
            fileName: fileName
          ));
          itemToSend = await _compressImage(fileSrc);
        }else if(post.temporaryFiles[fileSrc]=='vid'){
          _appBloc.add(AppUploadCompressingVideoEvent(
            fileName: fileName,
            itemNo: itemNo,
            totalLength: totalLength,
          ));
          itemToSend = await _compressVideo(fileSrc);
        }

        // * Upload the item
        task = _ref.child(filePath).putFile(itemToSend);
        _appBloc.add(AppUploadTaskStartedEvent(
          task: task, 
          itemNo: itemNo,
          totalLength: totalLength,
          fileName: fileName,
        ));

        // * Fetch the new item's download link
        await task.onComplete.then((_) async{
          await _ref.child(filePath).getDownloadURL().then((url) async{
            post.gallerySources[url] = post.temporaryFiles[fileSrc];
            
            // * Upload and get video thumbnail
            if(post.temporaryFiles[fileSrc] == 'vid'){
              post.thumbnails[url] = await _uploadAndGetVideoThumbnailSrc(fileSrc, filePath);
            }
          });
          index++; itemNo++;
        });
      });
    }
    post.noOfGalleryItems = index;
  }

  void deleteFile(String filePath){
    _ref.child(filePath).delete();
  }

  Future<String> uploadAndGetUserImageSrc(User user, File file) async{
    String downloadSrc;
    String fullname = user.forename + ' ' + user.surname;
    String filePath = 'users/${user.id}-$fullname';

    _appBloc.add(AppUploadCompressingImageEvent(
      itemNo: 1, 
      totalLength: 1,
      fileName: basename(file.path),
    ));
    file = await _compressImage(file.path);

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
    
    _appBloc.add(AppUploadCompressingImageEvent(
      itemNo: 1, 
      totalLength: 1,
      fileName: basename(file.path),
    ));
    file = await _compressImage(file.path);

    StorageUploadTask task = _ref.child(filePath).putFile(file);
    await task.onComplete;
    await _ref.child(filePath).getDownloadURL().then((url){
      downloadSrc = url;
    });
    return downloadSrc;
  }

  Future<File> _compressImage(String originalFilePath) async{
    String targetPath = directory+'/compressionImage.jpg';
    
    var result = await FlutterImageCompress.compressAndGetFile(
      originalFilePath, 
      targetPath,
      quality: 75,
    );
    return result;
  } 

  Future<String> _uploadAndGetVideoThumbnailSrc(String fileSrc, String filePath) async{
    Uint8List data = await VideoThumbnail.thumbnailData(
      video: fileSrc,
      timeMs: 3000,
    );
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

  Future<File> _compressVideo(String fileSrc) async{
    final compressedInfo = await VideoCompress.compressVideo(
      fileSrc,
      quality: VideoQuality.LowQuality,
    );
    return compressedInfo.file;
  }

}