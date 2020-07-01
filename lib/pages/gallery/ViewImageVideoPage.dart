import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewImageVideo extends StatefulWidget {
  final Map<String, ImageTag> imageSources;
  final int initialPage;

  ViewImageVideo({@required this.imageSources, @required this.initialPage});

  @override
  _ViewImageVideoState createState() => _ViewImageVideoState();
}

class _ViewImageVideoState extends State<ViewImageVideo> {
  Map<String, VideoPlayerController> _videoControllers =
      <String, VideoPlayerController>{};
  Orientation _orientation;
  bool _videoControlsVisible = false, _pagePoped = false;

  ScrollController _scrollController;


  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scollListener);
    widget.imageSources.keys.forEach((src) {
      if (widget.imageSources[src].type == 'vid') {
        VideoPlayerController controller = VideoPlayerController.network(src);
        controller.initialize().then((_) {
          setState(() {});
        });
        _videoControllers[src] = controller;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _videoControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      _orientation = orientation;
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _orientation == Orientation.portrait ? AppBar() : null,
        body: PageView.builder(
            pageSnapping: true,
            physics: BouncingScrollPhysics(),
            itemCount: widget.imageSources.keys.length,
            controller: PageController(initialPage: widget.initialPage),
            itemBuilder: (_, index) {
              String src = widget.imageSources.keys.elementAt(index);
              String type = widget.imageSources[src].type;
              if (type.compareTo('vid') == 0) return _createVideoPage(src);
              return _createImagePage(src);
            }),
      );
    });
  }

  Widget _createImagePage(String src) {
   /*  return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child:  Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Hero(
            tag: widget.imageSources[src].heroTag,
            child: PhotoView(
              initialScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(src),
              tightMode: true,
            ),
          ),
        ),
      ),
    ); */

    return Center(
      child: Dismissible(
        movementDuration: Duration(milliseconds: 100),
        dismissThresholds: {DismissDirection.down:0.8},
        confirmDismiss: (value) async{
          bool result = false;
          await Future.delayed(Duration(microseconds: 100),(){
            Navigator.of(context).pop();
          });
          return result;
        },
        direction: DismissDirection.vertical,
        key: ValueKey(src),
        child: Hero(
            tag: widget.imageSources[src].heroTag,
            child: PhotoView(
              initialScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(src),
              tightMode: true,
            ),
          ),
      ),
    );

    /* return Center(
      child: Draggable(
        feedback: Container(
          child: PhotoView(
            imageProvider: NetworkImage(src),
            tightMode: true,
          ),
          width: MediaQuery.of(context).size.width,
        ),
        childWhenDragging: Container(),
        axis: Axis.vertical,
        affinity: Axis.vertical,
        onDraggableCanceled: (_, __) {
          Navigator.pop(context);
        },
        child: Hero(
          child: Image.network(src),
          tag: widget.imageSources[src].heroTag,
        ),
      ),
    ); */
  }

  void _scollListener(){
    /* if(_scrollController.offset > (_scrollController.position.maxScrollExtent + 70)||
    _scrollController.offset < (_scrollController.position.minScrollExtent - 70)){
      /* if(!_pagePoped){
        Navigator.of(context).pop();
        setState(() {
        _pagePoped = true;
      });
      } */

    } */
   
  }

  Widget _createVideoPage(String src) {
    VideoPlayerController thisController = _videoControllers[src];
    if (thisController.value.initialized) {
      if (_orientation == Orientation.portrait)
        return _createPortraitVideoPage(thisController);
      else
        return _createLandscapeVideoPage(thisController);
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Column _createPortraitVideoPage(VideoPlayerController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          child: VideoPlayer(controller),
          aspectRatio: controller.value.aspectRatio,
        ),
        _videoControls(controller),
      ],
    );
  }

  Widget _createLandscapeVideoPage(VideoPlayerController controller) {
    return Stack(alignment: Alignment.center, children: [
      GestureDetector(
        onTap: () => _fullScreenVideoTouched(),
        child: AspectRatio(
          child: VideoPlayer(controller),
          aspectRatio: controller.value.aspectRatio,
        ),
      ),
      Visibility(
        visible: _videoControlsVisible,
        child: _videoControls(controller),
      ),
    ]);
  }

  void _fullScreenVideoTouched() {
    if (_videoControlsVisible) {
      setState(() {
        _videoControlsVisible = false;
      });
    } else {
      setState(() {
        _videoControlsVisible = true;
      });
    }
  }

  Row _videoControls(VideoPlayerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.replay_10,
            size: 40,
          ),
          onPressed: () {
            controller.position.then((position) {
              Duration newPosition = position - Duration(seconds: 10);
              controller.seekTo(newPosition);
            });
          },
        ),
        IconButton(
            icon: Icon(Icons.fast_rewind, size: 40),
            onPressed: () {
              controller.seekTo(Duration(seconds: 0, minutes: 0));
            }),
        IconButton(
          icon: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            });
          },
        ),
        IconButton(icon: Icon(Icons.volume_off, size: 40), onPressed: () {}),
        IconButton(
          icon: Icon(
            Icons.forward_10,
            size: 40,
          ),
          onPressed: () {
            controller.position.then((position) {
              Duration newPosition = position + Duration(seconds: 10);
              controller.seekTo(newPosition);
            });
          },
        ),
      ],
    );
  }
}
