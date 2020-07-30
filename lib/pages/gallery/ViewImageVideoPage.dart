import 'package:chewie/chewie.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image/network.dart';
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
  
  Orientation _orientation;
  bool _isZoomedIn = false, _hideAppBar = false;
  double _midScroll = 0;
  ScrollController _scrollController;

  Map<String, VideoPlayerController> _videoControllers = <String, VideoPlayerController>{};
  Map<String, ChewieController> _chewieControllers = {};
 

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
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
       DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _chewieControllers.keys.forEach((src) {
      _chewieControllers[src].dispose();
      _videoControllers[src].dispose();
    });
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      bool continueListening = true;
      if(_orientation != null){
        if(_orientation != orientation){
          // TODO sizes have changed, need to reset the midsize and initial position, need to disable the listeners
          continueListening = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                  _midScroll = _scrollController.position.maxScrollExtent / 2;
                  //_midScroll -= 20;
                  _scrollController.jumpTo(_midScroll);
                  _scrollController = ScrollController(initialScrollOffset: _midScroll);
              });
        });
        }
      }
      _orientation = orientation;


      return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(orientation),
        body: PageView.builder(
          pageSnapping: true,
          physics: _isZoomedIn ? NeverScrollableScrollPhysics() : BouncingScrollPhysics(),
          itemCount: widget.imageSources.keys.length,
          controller: PageController(initialPage: widget.initialPage),
          itemBuilder: (_, index) {
            String src = widget.imageSources.keys.elementAt(index);
            String type = widget.imageSources[src].type;

            return NotificationListener(
              onNotification: (t){
                if(continueListening){
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
                }
                return null;
              },
              child: SingleChildScrollView(
                controller:_scrollController,
                physics: _isZoomedIn ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                child: orientation == Orientation.portrait ? _buildPortraitContainer(type, src)
                : _buildLandscapeContainer(type, src),
                ),
              );
          }),
      );
    });
  }

  Widget _buildPortraitContainer(String type, String src,){
    return InkWell(
      splashColor: Colors.transparent,
      onTap: (){setState(() {_hideAppBar= !_hideAppBar;});},
      child: Container(
        height:  MediaQuery.of(context).size.height + 200,
        alignment: Alignment.center,
        child: (type.compareTo('vid') == 0) ? _buildVideoContainer(src) : _createImagePage(src),
      ),
    );
  }

  Widget _buildVideoContainer(String src){
    if(_chewieControllers[src]==null){
      _videoControllers[src] = VideoPlayerController.network(src);
      _videoControllers[src].initialize().then((_){
        setState(() {
          _chewieControllers[src] = ChewieController(
            videoPlayerController: _videoControllers[src],
            aspectRatio: _videoControllers[src].value.aspectRatio,
            autoPlay: true
          );
        });
      });
     return CircularProgressIndicator();
    }
    
    return Container(
      color: Colors.grey,
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Chewie(controller: _chewieControllers[src],)
      ),
    );
  }

  Widget _buildLandscapeContainer(String type, String src,){
    return InkWell(
      splashColor: Colors.transparent,
      onTap: (){setState(() {_hideAppBar= !_hideAppBar;});},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: _midScroll,),
          AspectRatio(
            aspectRatio: 16/9,
            child: (type.compareTo('vid') == 0) ? _buildVideoContainer(src) : _createImagePage(src),
          ),
          SizedBox(height: _midScroll,),
        ],
      ),
    );
  }

  Widget _buildAppBar(Orientation orientation){
    return PreferredSize(
      preferredSize: AppBar().preferredSize,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: _hideAppBar ? 0:1,
        child: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
      ),
    );
  }

  Widget _createImagePage(String src) {
    return PhotoView(
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
      imageProvider: NetworkImageWithRetry(src),
      tightMode: true,
    );
  }
  
}
