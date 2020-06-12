import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryTabBody extends StatelessWidget {
  
  final Orientation _orientation;
  GalleryTabBody(this._orientation);

  static double pictureSize, paddingSize;

  @override
  Widget build(BuildContext context) {
    pictureSize = MediaQuery.of(context).size.width * 0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    paddingSize = MediaQuery.of(context).size.width * 0.01;
    if(_orientation == Orientation.landscape){
      // * 4 blocks accross so 5 paddings accross
      pictureSize = MediaQuery.of(context).size.width * 0.2375;
      paddingSize = MediaQuery.of(context).size.width * 0.01;
    }

    return ListView(
      children: [
        FlatButton(child: Text('ADD/EDIT'), onPressed:()=> BlocProvider.of<AppBloc>(context).add(AppToEditAlbumEvent(BlocProvider.of<PostBloc>(context))),),
        SizedBox(height: 20,),
        Wrap(
          children: BlocProvider.of<PostBloc>(context).files.keys.map((file){
            String type = BlocProvider.of<PostBloc>(context).files[file];
            return type == 'vid' ? _createVideoContainer() : _createImageContainer(file);
          }).toList(),
        )
      ],
    );
  }

  Widget _createImageContainer(File file){
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