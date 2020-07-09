import 'dart:io';

import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GalleryItem extends StatefulWidget {
  
  final Function onTap;
  final String heroTag, src, type;
  final bool isItemAFile;
  final File file;

  GalleryItem({
   @required this.onTap,
   @required this.heroTag,
   @required this.src,
    @required this.type,
  }):isItemAFile = false, file = null;

  GalleryItem.file({
    @required this.type,
    @required this.file
  }):isItemAFile = true, src = null, onTap = null, heroTag = null;

  @override
  _GalleryItemState createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> {
  
  double _pictureSize, _paddingSize;
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    if(widget.type=='vid'){
      _videoPlayerController = widget.isItemAFile ? VideoPlayerController.file(widget.file):
       VideoPlayerController.network(widget.src);
      _videoPlayerController.initialize().then((_){
        if(mounted){
          setState(() { });
        }
      });
    }
    super.initState();
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

    if(widget.isItemAFile) return widget.type=='vid' ?  _buildFileVideoContainer(): _buildFileImageContainer();
    return widget.type=='vid' ?  _buildSRCVideoContainer(): _buildSRCImageContainer();
  }

  Widget _buildSRCImageContainer(){
    return Padding(
     padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Hero(
            tag: widget.heroTag,
            child: Image.network(widget.src, fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }

  Widget _buildSRCVideoContainer(){
    return Padding(
      padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
          alignment: Alignment.center,
          children:[ 
            VideoPlayer(_videoPlayerController),
            Icon(Icons.play_circle_outline, color: Colors.white,)
          ]),
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
        child: Image.file(widget.file,fit: BoxFit.cover,),
      ),
    );
  }

  Widget _buildFileVideoContainer(){
    return Padding(
      padding:  EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: Stack(
          alignment: Alignment.center,
          children:[ 
            VideoPlayer(_videoPlayerController),
            Icon(Icons.play_circle_outline, color: Colors.white,)
          ]),
      ),
    );
  }
}

class AlbumCoverItem extends StatefulWidget {
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
  _AlbumCoverItemState createState() => _AlbumCoverItemState();
}

class _AlbumCoverItemState extends State<AlbumCoverItem> {
  
  VideoPlayerController _videoPlayerController;

  @override
  void initState() { 
    super.initState();
    if(widget.type=='vid'){
      _videoPlayerController = VideoPlayerController.network(widget.src);
      _videoPlayerController.initialize().then((_){
        if(mounted){
          setState(() { });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.type=='vid' ? _buildVideoItem() : _buildImageItem();
  }

  Widget _buildVideoItem(){
    return Column(
      children: [
        Expanded(
          child: GestureDetector(onTap: widget.onTap, child: Hero(
            tag: ImageTag(src: widget.src, type: widget.type)..heroTag,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoPlayerController),
                    Icon(Icons.play_circle_outline, color: Colors.white,),
                  ],
                ),
              ),
            ),
          ),),
        ),
        Text(widget.title,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
        Text('(${widget.itemCount})')
      ],
    );
  }

  Widget _buildImageItem(){
    ImageTag imageTag = ImageTag(src: widget.src, type: widget.type);
    return Column(
      children: [
        Expanded(
          child: GestureDetector(onTap: widget.onTap, child: Hero(
            tag: imageTag.heroTag,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                   image: DecorationImage(
                    image: NetworkImage(widget.src),
                    fit: BoxFit.cover),
                ),
              ),
            ),
          ),),
        ),
        Text(widget.title,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
        Text('(${widget.itemCount})')
      ],
    );
  }
}