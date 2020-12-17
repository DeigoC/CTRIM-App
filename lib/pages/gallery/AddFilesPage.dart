import 'dart:async';
import 'dart:io';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

class AddGalleryFilesPage extends StatefulWidget {
  final PostBloc _postBloc;
  AddGalleryFilesPage(this._postBloc);
  @override
  _AddGalleryFilesPageState createState() => _AddGalleryFilesPageState();
}

class _AddGalleryFilesPageState extends State<AddGalleryFilesPage> {
  
  List<String> _videoTypes = [ 'mp4', 'mkv', 'flv', 'mov'];
  List<String> _imageTypes = ['jpg', 'png', 'gif', 'svg'];
  List<File> _selectedFiles = [];
  bool _selectingFiles = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _selectedFiles.forEach((file) {
          String fileType = basename(file.path).split('.').last.toLowerCase();
          String type = (_videoTypes.contains(fileType)) ? 'vid' : 'img';

          if(_isFileValid(file, type)) widget._postBloc.files[file.path] = type;
        });
        widget._postBloc.add(PostFilesReceivedEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Add Files'),),
        floatingActionButton:_buildFAB(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildFAB(){
    if(_selectingFiles) return null;
    else if(Platform.isAndroid){
      return FloatingActionButton(
        tooltip: 'Browse Files',
        onPressed: () {
          setState(() { _selectingFiles = true; });
          _pickFiles().then((newFiles) {
            setState(() {
              _selectingFiles = false;
              _selectedFiles.addAll(newFiles.map<File>((e) => File(e.path)).toList());
            });
          });
        },
        child: Icon(Icons.add_photo_alternate),
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'iosSelectVideo',
            child: Icon(Icons.video_library),
            onPressed: (){
              setState(() { _selectingFiles = true; });
              _pickFiles(pickingImages: false).then((newFiles) {
                setState(() {
                  _selectingFiles = false;
                  _selectedFiles.addAll(newFiles.map<File>((e) => File(e.path)).toList());
                });
              });
            }
          ),
          SizedBox(width: 8,),
          FloatingActionButton(
            heroTag: 'iosSelectImage',
            child: Icon(Icons.image),
            onPressed: (){
              setState(() { _selectingFiles = true; });
              _pickFiles(pickingImages: true).then((newFiles) {
                setState(() {
                  _selectingFiles = false;
                  _selectedFiles.addAll(newFiles.map<File>((e) => File(e.path)).toList());
                });
              });
            }
          ),
        ],
      );
    }
  }

  Widget _buildBody() {
    if(_selectingFiles) return Center(child: CircularProgressIndicator(),);
    
    else if (_selectedFiles.length == 0) return Center(
      child: Text('Max Image Size: 5.0 MB\nMax Video Size: 200.0 MB',textAlign: TextAlign.center,),
    );
    
    return ListView.builder(
      itemCount: _selectedFiles.length,
      itemBuilder: (_, i) {
        File file = _selectedFiles[i];
        String fileType = basename(file.path).split('.').last.toLowerCase();

        return Dismissible(
          background: Container(color: Colors.red,),
          key: ValueKey(file),
          onDismissed: (_) {setState(() {_selectedFiles.removeAt(i);});},
          child: AddingFileItem(file: file, fileType: fileType),
        );
      },
    );
  }

  // TODO Needs different technique with iOS
  Future<List<PlatformFile>> _pickFiles({bool pickingImages = false}) async {
    FilePickerResult results;

    if(Platform.isIOS){
       results = await FilePicker.platform.pickFiles(
        type: pickingImages ?  FileType.image : FileType.video,
        allowMultiple: true,
      );
    }else{
      results = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: _imageTypes + _videoTypes,
      );
    }

    _removeDuplicateFiles(results.files);
    return results.files;
  }

  void _removeDuplicateFiles(List<PlatformFile> files) {
    if(files !=null){
      List<PlatformFile> filesToRemove = [];
      files.forEach((file) {
      _selectedFiles.forEach((selectedFile) {
        if (basename(selectedFile.path).compareTo(basename(file.path)) == 0) {
          filesToRemove.add(file);
        }
      });
    });
    filesToRemove.forEach((toBeRemoved) {
      files.remove(toBeRemoved);
    });
    }
  }

  bool _isFileValid(File file, String type){
    if(type == 'vid'){
      if((file.lengthSync() / (1026*1000)) >200.0) return false;
    }else{
      if((file.lengthSync() / (1026*1000)) >5.0) return false;
    }
    return true;
  }
}

class AddingFileItem extends StatefulWidget {
  final File file;
  final String fileType;
  AddingFileItem({
    @required this.file,
    @required this.fileType,
  });
  @override
  _AddingFileItemState createState() => _AddingFileItemState();
}

class _AddingFileItemState extends State<AddingFileItem> {
  
  final List<String> _imageTypes = ['jpg', 'png', 'gif', 'svg'];
  double _containerSize;
  VideoPlayerController _videoPlayerController;
  bool _compressing = false;

  @override
  void initState() {
    if(!_imageTypes.contains(widget.fileType.toLowerCase())){
      _videoPlayerController = VideoPlayerController.file(widget.file);
      _videoPlayerController.initialize().then((_){
        if(mounted){ setState(() { });}
      });
    } 

    super.initState();
  }

  @override
  void dispose() { 
    if(_videoPlayerController != null) _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _containerSize = MediaQuery.of(context).size.width * 0.3;
    return Card(
      child: Row(
        children: [
          _buildFileContainer(),
          SizedBox(width: 8,),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(basename(widget.file.path), textAlign: TextAlign.center,),
                  _getFileSizeText(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFileContainer(){
    if(_imageTypes.contains(widget.fileType.toLowerCase())) return _buildImageFileContainer();
    return _buildVideoFileContainer();
  }

  Container _buildImageFileContainer(){
    return Container(
      width: _containerSize,
      height: _containerSize,
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(widget.file),fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  ClipRRect _buildVideoFileContainer(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _compressVideoTest();
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
        child: Container(
        width: _containerSize,
        height: _containerSize,
        child: Stack(
          alignment: Alignment.center,
          children:[
             VideoPlayer(_videoPlayerController),
             Icon(Icons.play_circle_outline, color: Colors.white,),
          ]
        ),
      ),
    );
  }

  Text _getFileSizeText(){
    double sizeMB = (widget.file.lengthSync() / (1026*1000));
    bool isVideo = _videoPlayerController != null;
    bool isSizeValid = true;
    if(isVideo){
      isSizeValid = sizeMB <= 200.0;
    }else{
      isSizeValid = sizeMB <= 5.0;
    }

    return Text(sizeMB.toStringAsFixed(2) + ' MB', style: isSizeValid ? 
    null:TextStyle(color: Colors.red, fontWeight: FontWeight.bold),);
  }

  void _compressVideoTest(){
    if(!_compressing){
      /* var thing = VideoCompress.compressVideo(widget.file.path);
      setState(() { _compressing = true; });
      thing.then((value) {
        print('-----------------VIDEO COMPRESSED!');
      }); */
     
      /* var thing = _flutterVideoCompress.compressVideo(widget.file.path);
      setState(() { _compressing = true; });
      thing.then((value){
        print('----------------------VIDEO COMPRESSED!');
      }); */

    }
    
  }
}

