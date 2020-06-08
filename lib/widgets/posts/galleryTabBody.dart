import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryTabBody extends StatelessWidget {
  
  final Orientation _orientation;
  GalleryTabBody(this._orientation);

  @override
  Widget build(BuildContext context) {
    double pictureSize = MediaQuery.of(context).size.width * 0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    double paddingSize = MediaQuery.of(context).size.width * 0.01;
    if(_orientation == Orientation.landscape){
      // * 4 blocks accross so 5 paddings accross
      pictureSize = MediaQuery.of(context).size.width * 0.2375;
      paddingSize = MediaQuery.of(context).size.width * 0.01;
    }

    return ListView(
      children: [
        FlatButton(child: Text('ADD/EDIT'), onPressed:()=> BlocProvider.of<AppBloc>(context).add(AppToEditAlbumEvent()),),
        SizedBox(height: 20,),
        Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.purple,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.yellow,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: pictureSize,
                height: pictureSize,
                color: Colors.black,
              ),
            ),
          ],
        )
      ],
    );
  }
}