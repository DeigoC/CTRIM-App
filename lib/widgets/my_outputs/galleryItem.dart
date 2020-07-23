import 'dart:io';

import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GalleryItem extends StatefulWidget {
  
  final Function onTap;
  final String heroTag, src, type;
  final bool isItemAFile;
  final File file;
  final Widget child;
  final Map<String,String> thumbnails;

  GalleryItem({
   @required this.onTap,
   @required this.heroTag,
   @required this.src,
    @required this.type,
    @required this.thumbnails,
    this.child
  }):isItemAFile = false, file = null;

  GalleryItem.file({
    @required this.type,
    @required this.file,
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
    if(widget.type=='vid'){
      if(widget.isItemAFile){
        _videoPlayerController = VideoPlayerController.file(widget.file);
        _videoPlayerController.initialize().then((_){ setState(() {});});
      }
    }
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
              image: DecorationImage(image: NetworkImage(widget.src),fit: BoxFit.cover)
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
            image: DecorationImage(image: NetworkImage(thumbSrc),fit: BoxFit.cover)
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
          image: DecorationImage(image: FileImage(widget.file),fit: BoxFit.cover),
        ),
        child: widget.child??Container(),
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
            Icon(Icons.play_circle_outline, color: Colors.white,),
            widget.child??Container(),
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

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.type=='vid' ? _buildVideoItem() : _buildImageItem();
  }

  Widget _buildVideoItem(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(onTap: widget.onTap, child: Hero(
            tag: ImageTag(src: widget.src, type: widget.type)..heroTag,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                child:Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_outline,color: Colors.white,),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(widget.src),fit: BoxFit.cover)
                  ),
                )
              ),
            ),
          ),),
        ),
        Text(widget.title,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
        Text('(${widget.itemCount})',textAlign: TextAlign.center),
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