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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _selectedFiles.forEach((file) {
          String fileType = basename(file.path).split('.').last.toLowerCase();
          String type = (_videoTypes.contains(fileType)) ? 'vid' : 'img';
          widget._postBloc.files[file] = type;
        });
        widget._postBloc.add(PostFilesReceivedEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Files'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _pickFiles().then((newFiles) {
              setState(() {
                _selectedFiles.addAll(newFiles);
              });
            });
          },
          label: Text('Add Images And Videos'),
          icon: Icon(Icons.add_photo_alternate),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedFiles.length == 0) {
      return Center(
        child: Text('Insert info here'),
      );
    }
    return ListView.builder(
      itemCount: _selectedFiles.length,
      itemBuilder: (_, i) {
        File file = _selectedFiles[i];
        String fileType = basename(file.path).split('.').last.toLowerCase();
        double photoSize = MediaQuery.of(_).size.width * 0.2;
        Widget leading = _imageTypes.contains(fileType)
            ? AddingFileItem(
              file: file,
              fileType: fileType,
            )
            : Container(width: photoSize,height: photoSize, child: Icon(Icons.video_library),);
        
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

  //TODO needs different technique with iOS
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
    if(_videoPlayerController != null){
      _videoPlayerController.dispose();
    }
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
                Text('Type: ' + widget.fileType),
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
}
