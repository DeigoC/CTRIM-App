import 'dart:io';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/galleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAlbumPage extends StatefulWidget {
  final PostBloc _postBloc;
  EditAlbumPage(this._postBloc);
  @override
  _EditAlbumPageState createState() => _EditAlbumPageState();
}

class _EditAlbumPageState extends State<EditAlbumPage> {
  
  List<String> _selectedFiles = [];
  bool _onDeleteMode = false;
 
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        bool result = false;
        
        widget._postBloc.add(PostTextChangeEvent());
        if(widget._postBloc.hasAlbumChanged){
            await showDialog(
            context: context,
            builder: (_){
              return AlertDialog(
                title: Text('Leave Page'),
                content: Text('Do you want to keep or discard changes?'),
                actions: [
                FlatButton(child: Text('Discard'), onPressed: (){
                  result = true;
                  widget._postBloc.add(PostDiscardGalleryChnagesEvent());
                  Navigator.of(context).pop();
                }),
                FlatButton(child: Text('Keep'), onPressed: (){
                  result = true;
                  Navigator.of(context).pop();
                }),
                ],
              );
            }
          );
          widget._postBloc.add(PostTextChangeEvent());
        }else return true;

        return result;
      },
        child: Scaffold(
        appBar: AppBar(
          actions: _onDeleteMode ? _buildDeleteActions() : _buildNormalActions(),
        ),
       body: _buildBody(),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
       floatingActionButton: _onDeleteMode ? _buildDeleteButton(): null,
      ),
    );
  }
  
  List<Widget> _buildNormalActions(){
    return [
      MyRaisedButton(
        label: 'Add',
        externalPadding: EdgeInsets.all(8),
        onPressed:()=> BlocProvider.of<AppBloc>(context).add(AppToAddGalleryFileEvent(widget._postBloc)),
      ),
      MyRaisedButton(
        label: 'Remove',
        isDestructive: true,
        externalPadding: EdgeInsets.all(8),
        onPressed:(){ setState(() {_onDeleteMode = true; });} 
      ),
    ];
  }

  List<Widget> _buildDeleteActions(){
    return [
      MyRaisedButton(
        externalPadding: EdgeInsets.all(8),
        label: 'Cancel',
        onPressed: () {
          setState(() {
            _onDeleteMode = false;
            _selectedFiles = [];
          });
        },
      ),
    ];
  }

  SizedBox _buildDeleteButton(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: MyRaisedButton(
        label: 'Remove ${_selectedFiles.length} items',
        isDestructive: true,
        onPressed: (){
          widget._postBloc.add(PostRemoveSelectedFilesAndSrcEvent(_selectedFiles));
          setState(() {
            _onDeleteMode = false;
          });
        },
      ),
    );
  }

  Widget _buildBody(){
    return BlocBuilder(
      bloc: widget._postBloc,
      condition: (_, currentState){
        if(currentState is PostFilesReceivedState) return true;
        return false;
      },
      builder:(_,state){
        Map<File, String> files = widget._postBloc.files;
        Map<String, String> sources = widget._postBloc.gallerySrc;
        List<String> sourcesOrdered = sources.keys.toList();
        sourcesOrdered.sort();

        List<Widget> newChildren = sourcesOrdered.map((src){
          String type = sources[src];
          if(type == 'vid') return _buildVideoSrcContainer(src);
          return _buildPictureSrcContainer(src);
        }).toList();
        
        newChildren.addAll(files.keys.map((file){
          String type = files[file];
          if(type == 'vid') return _buildVideoFileContainer(file);
          return _buildPictureFileContainer(file);
        }).toList());

        return SingleChildScrollView(
          child: Wrap(children: newChildren),
        );
      }
     );
  }

  GalleryItem _buildVideoSrcContainer(String src){
    bool selected = _selectedFiles.contains(src);
    return GalleryItem(
      thumbnails: widget._postBloc.newPost.thumbnails,
      onTap: null,
      heroTag: src,// ? Not required
      src: src,
      type: 'vid',
      child: InkWell(
        onTap: (){
           if(_onDeleteMode){
          setState(() {
             if(selected)_selectedFiles.remove(src);
              else _selectedFiles.add(src);
          });
        }
        },
          child: Opacity(
            opacity: selected ? 1:0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),
                Icon(Icons.done, color: Colors.white,)
              ],
            ),
          ),
      ),
    );
  }

  GalleryItem _buildVideoFileContainer(File file){
    bool selected = _selectedFiles.contains(file.path);
    return GalleryItem.file(
      thumbnails: widget._postBloc.newPost.thumbnails,
      file: file,
      type: 'vid',
      child: InkWell(
        onTap: (){
           if(_onDeleteMode){
          setState(() {
             if(selected)_selectedFiles.remove(file.path);
              else _selectedFiles.add(file.path);
          });
        }
        },
          child: Opacity(
            opacity: selected ? 1:0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),
                Icon(Icons.done, color: Colors.white,)
              ],
            ),
          ),
      ),
    );
  }

  GalleryItem _buildPictureFileContainer(File file){
    bool selected = _selectedFiles.contains(file.path);
    return GalleryItem.file(
      thumbnails: widget._postBloc.newPost.thumbnails,
      type: 'img', 
      file: file,
      child: InkWell(
        onTap: (){
          if(_onDeleteMode){
            setState(() {
            if(selected)_selectedFiles.remove(file.path);
            else _selectedFiles.add(file.path);
          }); 
          }
        },
        child: Opacity(
          opacity: selected ? 1:0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black.withOpacity(0.3),
              ),
              Icon(Icons.done, color: Colors.white,)
            ],
          ),
        ),
      ),
    );
  }

  GalleryItem _buildPictureSrcContainer(String src){
    bool selected = _selectedFiles.contains(src);
    return GalleryItem(
      thumbnails: widget._postBloc.newPost.thumbnails,
      heroTag: src,
      onTap: null,
      type: 'img', 
      src: src,
      child: InkWell(
        onTap: (){
          if(_onDeleteMode){
            setState(() {
            if(selected)_selectedFiles.remove(src);
            else _selectedFiles.add(src);
          }); 
          }
        },
        child: Opacity(
          opacity: selected ? 1:0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(color: Colors.black.withOpacity(0.3),),
              Icon(Icons.done, color: Colors.white,)
            ],
          ),
        ),
      ),
    );
  }
}