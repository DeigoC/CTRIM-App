import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/models/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryTabBody extends StatelessWidget {
  
  final Orientation orientation;
  final Map<String,String> gallerySrc;

  static double pictureSize, paddingSize;
  static String _mode = 'addingPost';
  static BuildContext _context;

  GalleryTabBody({@required this.orientation, this.gallerySrc});

  GalleryTabBody.view({
    @required this.orientation, 
    @required this.gallerySrc
  }){
    _mode = 'viewingPost';
  }

  GalleryTabBody.edit({
    @required this.orientation,
    @required this.gallerySrc,
  }){
    _mode = 'editingPost';
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    pictureSize = MediaQuery.of(context).size.width * 0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    paddingSize = MediaQuery.of(context).size.width * 0.01;
    if(orientation == Orientation.landscape){
      // * 4 blocks accross so 5 paddings accross
      pictureSize = MediaQuery.of(context).size.width * 0.2375;
      paddingSize = MediaQuery.of(context).size.width * 0.01;
    }

    if(_mode == 'viewingPost'){
      return SingleChildScrollView(
        child: Wrap(
          children: gallerySrc.keys.map((src){
            String type = gallerySrc[src];
            return type == 'vid' ? _createVideoContainer() : _createImageSrcContainer(src);
          }).toList(),
        ),
      );
    }else if(_mode == 'editingPost'){
      List<Widget> wrapChildren = BlocProvider.of<PostBloc>(context).gallerySrc.keys.map((src){
            String type = BlocProvider.of<PostBloc>(context).gallerySrc[src];
            return type == 'vid' ? _createVideoContainer() : _createImageSrcContainer(src);
          }).toList();

      wrapChildren.addAll(
         BlocProvider.of<PostBloc>(context).files.keys.map((file){
            String type = BlocProvider.of<PostBloc>(context).files[file];
            return type == 'vid' ? _createVideoContainer() : _createImageFileContainer(file);
          }).toList()
      );
      
      return ListView(
      children: [
        FlatButton(child: Text('Add/Edit Album'), onPressed:()=> BlocProvider.of<AppBloc>(context).add(AppToEditAlbumEvent(BlocProvider.of<PostBloc>(context))),),
        SizedBox(height: 20,),
        Wrap(
          children: wrapChildren
        )
      ],
    );
    }
    return ListView(
      children: [
        FlatButton(child: Text('ADD/EDIT'), onPressed:()=> BlocProvider.of<AppBloc>(context).add(AppToCreateAlbumEvent(BlocProvider.of<PostBloc>(context))),),
        SizedBox(height: 20,),
        Wrap(
          children: BlocProvider.of<PostBloc>(context).files.keys.map((file){
            String type = BlocProvider.of<PostBloc>(context).files[file];
            return type == 'vid' ? _createVideoContainer() : _createImageFileContainer(file);
          }).toList(),
        )
      ],
    );
  }

  Widget _createImageSrcContainer(String src){
      int index = gallerySrc.keys.toList().indexOf(src);
      Map<String,ImageTag> galleryTags = _createGalleryTags(gallerySrc);
      return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: GestureDetector(
          onTap: () => BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
          child: Hero(tag: galleryTags.values.elementAt(index).heroTag,child: Image.network(src, fit: BoxFit.cover,))
        ),
      ),
    );
  }

  Map<String,ImageTag> _createGalleryTags(Map<String, String> gallery){
    Map<String,ImageTag> result = {};
    gallery.forEach((src, type) {
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }

  Widget _createImageFileContainer(File file){
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: Image.file(file, fit: BoxFit.cover,),
      ),
    );
  }

  Widget _createVideoContainer(){
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: Icon(Icons.play_circle_outline),
      ),
    );
  }
}