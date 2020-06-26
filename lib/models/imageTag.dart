import 'package:flutter/cupertino.dart';

class ImageTag{
  
  String heroTag, type;
  ImageTag({@required String src, this.type, String tPostID = '0'}){
    heroTag = tPostID +'/' + src;
  }
}