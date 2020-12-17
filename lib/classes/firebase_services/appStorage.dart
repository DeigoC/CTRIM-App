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

// TODO cleanup code
class AppStorage{
  
  final Reference _ref =  FirebaseStorage.instance.ref();
  final AppBloc _appBloc;
  String directory ='';

  AppStorage(this._appBloc){
    getApplicationDocumentsDirectory().then((d) => directory =d.path);
  }

  // * Posts upload tasks
  Future<Null> uploadNewPostFiles(Post post) async{
    AppUploadItem appUploadItem = AppUploadItem(post: post);

    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        appUploadItem.originalFilePath = fileSrc;
        appUploadItem.setFile(File(fileSrc));
 
        await _compressUploadItem(appUploadItem);
        final UploadTask task = _initialiseUploadingTheItem(appUploadItem);
        await _setUploadItemDownloadLink(task, appUploadItem);
      });
    }
    post.noOfGalleryItems = appUploadItem.index;
  }
  
  Future<Null> uploadEditPostNewFiles(Post post,) async{
    AppUploadItem appUploadItem = AppUploadItem(post: post);

    if(post.temporaryFiles.length != 0){
      await Future.forEach(post.temporaryFiles.keys, (String fileSrc) async{
        appUploadItem.originalFilePath = fileSrc;
        appUploadItem.setFile(File(fileSrc));
        
        await _compressUploadItem(appUploadItem);
        final UploadTask task = _initialiseUploadingTheItem(appUploadItem);
        await _setUploadItemDownloadLink(task, appUploadItem);
      });
    }
    // ? Does the post break when user deletes all items and start uploading again?
    post.noOfGalleryItems = appUploadItem.index;
  }

  Future _compressUploadItem(AppUploadItem appUploadItem) async{
    final Post post = appUploadItem.post;
    final String fileSrc = appUploadItem.file.path;

    if(post.temporaryFiles[fileSrc]=='img'){
      if(_isImageAGif(fileSrc)){
        appUploadItem.isFileAGif = true;
      }else{
        _appBloc.add(AppUploadCompressingImageEvent(appUploadItem: appUploadItem));
        appUploadItem.setFile(await _compressImage(fileSrc));
      }
    }else if(post.temporaryFiles[fileSrc]=='vid'){
      _appBloc.add(AppUploadCompressingVideoEvent(appUploadItem: appUploadItem,));
      appUploadItem.setFile(await _compressVideo(fileSrc));
    }
  }
  
  UploadTask _initialiseUploadingTheItem(AppUploadItem appUploadItem){
    final UploadTask task = _ref.child(appUploadItem.uploadFilePath).putFile(appUploadItem.file);
    _appBloc.add(AppUploadTaskStartedEvent(
      task: task, 
      appUploadItem: appUploadItem,
    )); 
    return task;
  }

  Future _setUploadItemDownloadLink(UploadTask task, AppUploadItem appUploadItem) async{
    Post post = appUploadItem.post;
    final String fileSrc = appUploadItem.originalFilePath;

    await task.then((_) async{
      await _ref.child(appUploadItem.uploadFilePath).getDownloadURL().then((url) async{
        post.gallerySources[url] = post.temporaryFiles[fileSrc];
        
        // * Upload and get video thumbnail
        if(post.temporaryFiles[fileSrc] == 'vid'){
          post.thumbnails[url] = await _uploadAndGetVideoThumbnailSrc(fileSrc, appUploadItem.uploadFilePath);
        }
      });
      appUploadItem.startNewUploadCycle();
    });
  }

  // * Other Upload tasks
  Future<String> uploadAndGetUserImageSrc(User user, File file) async{
    final String filePath = 'users/${user.id}-${user.forename + ' ' + user.surname}';
    final AppUploadItem appUploadItem = AppUploadItem(originalFilePath: file.path);

    _appBloc.add(AppUploadCompressingImageEvent(appUploadItem: appUploadItem));
    file = await _compressImage(file.path);

    final UploadTask task = _ref.child(filePath).putFile(file);
    await task.whenComplete((){});
    return await _ref.child(filePath).getDownloadURL();
  }

  Future<String> uploadAndGetLocationImageSrc(Location location, File file) async{
    final String filePath = 'locations/${location.id}';
    final AppUploadItem appUploadItem = AppUploadItem(originalFilePath: file.path);

    _appBloc.add(AppUploadCompressingImageEvent(appUploadItem: appUploadItem,));
    file = await _compressImage(file.path);

    final UploadTask task = _ref.child(filePath).putFile(file);
    await task.whenComplete((){});
    return await _ref.child(filePath).getDownloadURL();
  }

  Future<String> _uploadAndGetVideoThumbnailSrc(String fileSrc, String filePath) async{
    Uint8List data = await VideoThumbnail.thumbnailData(
      video: fileSrc,
      timeMs: 3000,
    );
    String newFilePath = filePath +'_thumbnail';

    UploadTask task;

    await File('$directory/thing.png').create(recursive: true)
    .then((thumbnail) async{
      final buffer = data.buffer;
      var anotherFile = await thumbnail.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      task =_ref.child(newFilePath).putFile(anotherFile);
    });

    await task.whenComplete((){});
    return (await _ref.child(newFilePath).getDownloadURL()).toString();
  }
  
  // * Other functions
  void deleteFile(String filePath){
    _ref.child(filePath).delete();
  }

  Future<File> _compressImage(String originalFilePath) async{
    if(basename(originalFilePath).split('.').last.compareTo('gif')==0){
      // * Do not change gif files
      return File(originalFilePath);
    }

    String targetPath = directory+'/compressionImage.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      originalFilePath, 
      targetPath,
      quality: 75,
    );
    return result;
  } 

  Future<File> _compressVideo(String fileSrc) async{
    final compressedInfo = await VideoCompress.compressVideo(
      fileSrc,
      quality: VideoQuality.LowQuality,
    );
    return compressedInfo.file;
  }

  bool _isImageAGif(String src) => basename(src).split('.').last.compareTo('gif')==0;

}

class AppUploadItem{
  final Post post;
  String originalFilePath;

  int _index, _itemNo, _totalLength;
  File _file;
  bool isFileAGif = false;

  int get index => _index;
  int get itemNo => _itemNo;
  int get totalLength => _totalLength;
  File get file => _file;
  String get uploadFilePath => 'posts/${post.id}/item_$index' + (isFileAGif ? '.gif':'');
  String get originalFileName => basename(_file.path);

  AppUploadItem({
    this.post,
    this.originalFilePath,
  }){
    _itemNo = 1;
    _index=0;
    if(post != null){
      _index = post.gallerySources.length==0 ? 0 : post.noOfGalleryItems;
      _totalLength = post.temporaryFiles.length;
    }
    if(originalFilePath != null) setFile(File(originalFilePath));
    
  }

  void setFile(File file) => _file = file;

  void startNewUploadCycle(){
    _index++;
    _itemNo++;
    isFileAGif = false;
  }
}