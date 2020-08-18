import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';
import 'package:video_player/video_player.dart';

class GalleryItem extends StatefulWidget {
  
  final Function onTap;
  final String heroTag, src, type;
  final bool isItemAFile;
  final String filePath;
  final Widget child;
  final Map<String,String> thumbnails;

  GalleryItem({
   @required this.onTap,
   @required this.heroTag,
   @required this.src,
    @required this.type,
    @required this.thumbnails,
    this.child
  }):isItemAFile = false, filePath = null;

  GalleryItem.file({
    @required this.type,
    @required this.filePath,
    @required this.thumbnails,
    this.child,
    this.onTap,
  }):isItemAFile = true, src = null, heroTag = null;

  @override
  _GalleryItemState createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> {
  
  double _pictureSize, _paddingSize;
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    /* print('--------------TYPE IS ' + widget.type + '----------------is file: ' + widget.isItemAFile.toString());
    if(widget.type.compareTo('vid')==0 && widget.isItemAFile){
      print('-----------------INITIALISING VIDEO------------');
      _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
      _videoPlayerController.initialize().then((_){ setState(() {});});
    } */
    super.initState();
  }

  @override
  void dispose() { 
    if(_videoPlayerController != null) _videoPlayerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _pictureSize = MediaQuery.of(context).size.width *0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    _paddingSize = MediaQuery.of(context).size.width * 0.01;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // * 4 blocks accross so 5 paddings accross
      _pictureSize = MediaQuery.of(context).size.width * 0.2375;
      _paddingSize = MediaQuery.of(context).size.width * 0.01;
    }

    // ! This has to be done here to avoid times when Items 'overlap'
    if(widget.type.compareTo('vid')==0 && widget.isItemAFile && _videoPlayerController==null){
      _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
      _videoPlayerController.initialize().then((_){ setState(() {});});
    }

    if(widget.isItemAFile) return widget.type=='vid' ?  _buildFileVideoContainer(): _buildFileImageContainer();
    return widget.type=='vid' ?  _buildSRCVideoContainer(): _buildSRCImageContainer();
  }

  Widget _buildSRCImageContainer(){
    return Padding(
     padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Hero(
          tag: widget.heroTag,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _pictureSize,
            height: _pictureSize,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImageWithRetry(widget.src),fit: BoxFit.cover)
            ),
            child: widget.child??Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildSRCVideoContainer(){
    String thumbSrc = widget.thumbnails[widget.src];
    return Padding(
     padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _pictureSize,
          height: _pictureSize,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImageWithRetry(thumbSrc),fit: BoxFit.cover)
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              widget.child??Container(),
              Icon(Icons.play_circle_outline,color: Colors.white,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileImageContainer(){
    return Padding(
      padding:  EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        decoration: BoxDecoration(
          image: DecorationImage(image: FileImage(File(widget.filePath)),fit: BoxFit.cover),
        ),
        child: widget.child??Container(),
      ),
    );
  }

  Widget _buildFileVideoContainer(){
    bool initialised = false;
    if(_videoPlayerController != null){
      initialised = _videoPlayerController.value.initialized;
    }

    return Padding(
      padding:  EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        //color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children:[ 
            initialised ? VideoPlayer(_videoPlayerController):CircularProgressIndicator(),
            Icon(Icons.play_circle_outline, color: Colors.white,),
            widget.child??Container(),
          ]),
      ),
    );
  }
}

class AlbumCoverItem extends StatelessWidget {
  final String src, type, title, itemCount;
  final Function onTap;
  AlbumCoverItem({
    @required this.src,
    @required this.type,
    @required this.onTap,
    this.title,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return type=='vid' ? _buildVideoItem(context) : _buildImageItem(context);
  }

  Widget _buildVideoItem(BuildContext context){
    return Column(
      children: [
        Expanded(
          child: GestureDetector(onTap: onTap, child: Hero(
            tag: ImageTag(src: src, type: type)..heroTag,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                child:Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_outline,color: Colors.white,),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImageWithRetry(src),fit: BoxFit.cover)
                  ),
                )
              ),
            ),
          ),),
        ),
        Text(title,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
        Text(itemCount,style: TextStyle(color:  BlocProvider.of<AppBloc>(context).onDarkTheme 
          ? Colors.white60 : Colors.black.withOpacity(0.6)),),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context){
    ImageTag imageTag = ImageTag(src: src, type: type);
    return Column(
      children: [
        Expanded(
          child: GestureDetector(onTap: onTap, child: Hero(
            tag: imageTag.heroTag,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                   image: DecorationImage(
                    image: NetworkImageWithRetry(src),
                    fit: BoxFit.cover),
                ),
              ),
            ),
          ),),
        ),
        Text(title,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
        Text(itemCount,style: TextStyle(color:  BlocProvider.of<AppBloc>(context).onDarkTheme 
          ? Colors.white60 : Colors.black.withOpacity(0.6)),),
      ],
    );
  }
}