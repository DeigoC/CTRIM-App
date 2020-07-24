import 'dart:io';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

class AddGalleryFiles extends StatefulWidget {
  final PostBloc _postBloc;
  AddGalleryFiles(this._postBloc);
  @override
  _AddGalleryFilesState createState() => _AddGalleryFilesState();
}

class _AddGalleryFilesState extends State<AddGalleryFiles> {
  
  List<String> _videoTypes = [
    'mp4',
    'mkv',
    'flv',
  ];
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

          if(_isFileValid(file, type)){
             widget._postBloc.files[file] = type;
          }
        });
        widget._postBloc.add(PostFilesReceivedEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Files'),
        ),
        floatingActionButton: _selectingFiles ? null: FloatingActionButton(
          onPressed: () {
            setState(() { _selectingFiles = true; });
            _pickFiles().then((newFiles) {
              setState(() {
                _selectingFiles = false;
                _selectedFiles.addAll(newFiles);
              });
            });
          },
          child: Icon(Icons.add_photo_alternate),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if(_selectingFiles){
      return Center(child: CircularProgressIndicator(),);
    }
    else if (_selectedFiles.length == 0) {
      return Center(child: Text('Max Image Size: 2.0 MB\nMax Video Size: 75.0 MB',textAlign: TextAlign.center,),);
    }
    return ListView.builder(
      itemCount: _selectedFiles.length,
      itemBuilder: (_, i) {
        File file = _selectedFiles[i];
        String fileType = basename(file.path).split('.').last.toLowerCase();

        return Dismissible(
          background: Container(
            color: Colors.red,
          ),
          key: ValueKey(file),
          onDismissed: (_) {
            setState(() {_selectedFiles.removeAt(i);});
          },
          child: AddingFileItem(file: file, fileType: fileType),
        );
      },
    );
  }

  // ! Needs different technique with iOS
  Future<List<File>> _pickFiles() async {
    List<File> results;
    results = await FilePicker.getMultiFile(
      type: FileType.custom,
      allowedExtensions: _videoTypes + _imageTypes,
    );
    _removeDuplicateFiles(results);
    return results;
  }

  void _removeDuplicateFiles(List<File> files) {
    List<File> filesToRemove = [];
    files.forEach((file) {
      _selectedFiles.forEach((selectedFile) {
        if (basename(selectedFile.path).compareTo(basename(file.path)) == 0) {
          print('----------------------REMOVING THIS ONE!');
          filesToRemove.add(file);
        }
      });
    });
    filesToRemove.forEach((toBeRemoved) {
      files.remove(toBeRemoved);
    });
  }

  bool _isFileValid(File file, String type){
    if(type == 'vid'){
      if((file.lengthSync() / (1026*1000)) >75.0) return false;
    }else{
      if((file.lengthSync() / (1026*1000)) >2.0) return false;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(basename(widget.file.path), overflow: TextOverflow.ellipsis,),
                _getFileSizeText(),
              ],
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

  Widget _buildImageFileContainer(){
    return Container(
      width: _containerSize,
      height: _containerSize,
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(widget.file),fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildVideoFileContainer(){
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
      isSizeValid = sizeMB <= 75.0;
    }else{
      isSizeValid = sizeMB <= 2.0;
    }

    return Text(sizeMB.toStringAsFixed(2) + ' MB', style: isSizeValid ? 
    null:TextStyle(color: Colors.red, fontWeight: FontWeight.bold),);
  }
}
