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

  Map<String, VideoPlayerController> _videoControllers = <String, VideoPlayerController>{};
  Orientation _orientation;
  bool _videoControlsVisible = false, _isZoomedIn = false;

  double _midScroll = 0;
  ScrollController _scrollController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
       setState(() {
         _midScroll = _scrollController.position.maxScrollExtent / 2;
        _scrollController.jumpTo(_midScroll);
        _scrollController = ScrollController(initialScrollOffset: _midScroll);
       });
    });
    _scrollController = ScrollController();


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
            physics: _isZoomedIn ? NeverScrollableScrollPhysics() : BouncingScrollPhysics(),
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
    return NotificationListener(
      onNotification: (t){
        
        if(t is ScrollNotification){
          // ignore: invalid_use_of_visible_for_testing_member
          // ignore: invalid_use_of_protected_member
          // ignore: invalid_use_of_visible_for_testing_member
          if(_scrollController.position.activity is BallisticScrollActivity){
           _scrollController.animateTo(_midScroll, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          }
        }
        if(t is ScrollEndNotification){
          if(t.metrics.pixels != _midScroll){
            Future.delayed(Duration(microseconds: 10),(){
              _scrollController.animateTo(_midScroll, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            });
          }
          if(t.metrics.atEdge){
            Navigator.of(context).pop();
          }
        }
        return null;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: _isZoomedIn ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(
          
        ),
        child: Container(
          height: MediaQuery.of(context).size.height + 200,
          child: PhotoView(
            heroAttributes: PhotoViewHeroAttributes(tag: widget.imageSources[src].heroTag,),
            scaleStateChangedCallback: (_){
              if(_.index == 0){
                if(_isZoomedIn){
                    setState(() {
                  _isZoomedIn = false;
                });
                }
              }else{
                if(!_isZoomedIn){
                  setState(() {
                    _isZoomedIn = true;
                  });
                }
              }
            },
            loadingBuilder: (_,__){
              return Image.network(src);
            },
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(src),
            tightMode: true,
          ),
          ),
        ),
      );
    
    /* return Center(
      child: Dismissible(
        resizeDuration: null,
        movementDuration: Duration(milliseconds: 300),
        dismissThresholds: {DismissDirection.down:0.3, DismissDirection.up:0.3},
        confirmDismiss: (value) async{
          bool result = false;
          await Future.delayed(Duration(microseconds: 10),(){
            Navigator.of(context).pop();
          });
          return result;
        },
        direction: DismissDirection.vertical,
        key: ValueKey(src),
        child: Hero(
            tag: widget.imageSources[src].heroTag,
            child: PhotoView(
              onTapUp: (context, details, controllerValue){
                print('----------------TAPPED UP?');
              },
              loadingBuilder: (_,__){
                return Image.network(src);
              },
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(src),
              tightMode: true,
            ),
          ),
      ),
    ); */
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
          icon: Icon(Icons.replay_10,size: 40,color: Colors.white,),
          onPressed: () {
            controller.position.then((position) {
              Duration newPosition = position - Duration(seconds: 10);
              controller.seekTo(newPosition);
            });
          },
        ),
        IconButton(
            icon: Icon(Icons.fast_rewind, size: 40, color: Colors.white,),
            onPressed: () {
              controller.seekTo(Duration(seconds: 0, minutes: 0));
            }),
        IconButton(
          icon: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            });
          },
        ),
        IconButton(icon: Icon(Icons.volume_off, size: 40), onPressed: () {},color: Colors.white,),
        IconButton(
          icon: Icon(
            Icons.forward_10,
            size: 40,
            color: Colors.white,
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
