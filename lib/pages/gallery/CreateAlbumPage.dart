import 'dart:io';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/galleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAlbum extends StatefulWidget {
  final PostBloc _postBloc;
  EditAlbum(this._postBloc);
  @override
  _EditAlbumState createState() => _EditAlbumState();
}

class _EditAlbumState extends State<EditAlbum> {
  
  List<File> _selectedFiles = [];
  bool _onDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _onDeleteMode ? _buildDeleteActions() : _buildNormalActions(),
      ),
     body: _buildBody(),
     floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
     floatingActionButton: _onDeleteMode ? _buildDeleteButton(): null,
    );
  }

  List<Widget> _buildNormalActions(){
    return [
      MyRaisedButton(
        externalPadding: EdgeInsets.all(8),
        isDestructive: true,
        label: 'Remove',
        onPressed: () {
          setState(() {_onDeleteMode = true; });
        },
      ),
      MyRaisedButton(
        externalPadding: EdgeInsets.all(8),
        label: 'Add',
        onPressed: () {
           BlocProvider.of<AppBloc>(context).add(AppToAddGalleryFileEvent(widget._postBloc));
        }),
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
        label: 'Delete ${_selectedFiles.length} items',
        isDestructive: true,
        onPressed: (){
          widget._postBloc.add(PostFilesRemoveSelectedEvent(_selectedFiles));
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
        List<Widget> newChildren = files.keys.map((file){
          String type = files[file];
          if(type == 'vid') return _buildVideoContainer(file);
          return _buildPictureContainer(file);
        }).toList();
        
       return  SingleChildScrollView(
          child: Wrap(children: newChildren,),
        );

      /* return ListView(
      children: [
        Wrap(children: newChildren),
      ],
      ); */
      }
     );
   
  }

  GalleryItem _buildVideoContainer(File file){
    bool selected = _selectedFiles.contains(file);
    return GalleryItem.file(
      type: 'vid', file: file,
      child: InkWell(
        onTap: (){
          if(_onDeleteMode){
            setState(() {
            if(selected)_selectedFiles.remove(file);
            else _selectedFiles.add(file);
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

  Widget _buildPictureContainer(File file){
    /* return GalleryItem.file(
      type: 'img',
      file: file,
    ); */
    bool selected = _selectedFiles.contains(file);
    return GalleryItem.file(
      type: 'img',
      file: file,
      child: InkWell(
        onTap: (){
          if(_onDeleteMode){
            setState(() {
            if(selected)_selectedFiles.remove(file);
            else _selectedFiles.add(file);
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

    /* return Padding(
       padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
       child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: pictureSize,
          height: pictureSize,
          child: InkWell(
            onTap: (){
              if(_onDeleteMode){
                setState(() {
                if(selected)_selectedFiles.remove(file);
                else _selectedFiles.add(file);
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
       ),
    ); */
  }
}