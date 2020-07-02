import 'dart:io';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
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
                  widget._postBloc.add(PostTextChangeEvent());
                  Navigator.of(context).pop();
                }),
                ],
              );
            }
          );
        }else return true;
        return result;
      },
        child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Album'),
          actions: _onDeleteMode ? _buildDeleteActions() : _buildNormalActions(),
        ),
       body: _buildBody(),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
       floatingActionButton: _onDeleteMode ? _buildDeleteButton(): null,
      ),
    );
  }
  
  List<Widget> _buildNormalActions(){
      return [ PopupMenuButton(
        itemBuilder: (_){
          return [
            PopupMenuItem(
              child: ListTile(
                title: Text('Add'),
                leading: Icon(Icons.add_photo_alternate),
                onTap: ()=>  BlocProvider.of<AppBloc>(context).add(AppToAddGalleryFileEvent(widget._postBloc)),
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                title: Text('Remove'),
                leading: Icon(Icons.delete_sweep),
                onTap: (){
                  setState(() {_onDeleteMode = true; });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ];
        },
      ),
    ];
  }

  List<Widget> _buildDeleteActions(){
    return [
      FlatButton(
        child: Text('Cancel'),
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
      child: RaisedButton(
        child: Text('Remove ${_selectedFiles.length} items'),
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

        // TODO need to rework this so that it can be selected to delete

        List<Widget> newChildren = sources.keys.map((src){
          String type = sources[src];
          if(type == 'vid') return _buildVideoSrcContainer(src);
          return _buildPictureSrcContainer(src);
        }).toList();
        
        newChildren.addAll(files.keys.map((file){
          String type = files[file];
          if(type == 'vid') return _buildVideoFileContainer(file);
          return _buildPictureFileContainer(file);
        }).toList());

        return ListView(
        children: [
          Wrap(children: newChildren),
        ],
    );
      }
     );
  }

  Padding _buildVideoSrcContainer(String src){
    return null;
  }

  Padding _buildVideoFileContainer(File file){
    return null;
  }

  Padding _buildPictureFileContainer(File file){
    double pictureSize = MediaQuery.of(context).size.width * 0.32;
    double paddingSize = MediaQuery.of(context).size.width * 0.01;
    bool selected = _selectedFiles.contains(file.path);
    return Padding(
       padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
       child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: pictureSize,
          height: pictureSize,
          decoration: BoxDecoration(
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)
          ),
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
       ),
    );
  }

  Padding _buildPictureSrcContainer(String src){
    double pictureSize = MediaQuery.of(context).size.width * 0.32;
    double paddingSize = MediaQuery.of(context).size.width * 0.01;
    bool selected = _selectedFiles.contains(src);
    return Padding(
       padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
       child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: pictureSize,
          height: pictureSize,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(src), fit: BoxFit.cover)
          ),
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
       ),
    );
  }

}