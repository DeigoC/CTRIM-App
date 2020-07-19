import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
 
  final VideoPlayerController _controller;

  MyVideoPlayer(this._controller);
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> with SingleTickerProviderStateMixin{
  
  VideoPlayerController _videoController;
  AnimationController _animationController;
  bool _showControls = false, _isVideoFinished = false;
  Duration _currentVideoDuration;
  double _videoSliderValue=0;
  AnimatedIconData _animatedIcon = AnimatedIcons.pause_play;


  @override
  void initState() {
    _videoController = widget._controller;
    if(!_videoController.value.initialized){
      _videoController.initialize().then((_){
        setState(() {_videoController.play();});
      });
    }else{
      if(!_videoController.value.isPlaying) _animatedIcon = AnimatedIcons.play_pause;
      _currentVideoDuration = _videoController.value.position;
    }

    _videoController.addListener(_videoListener);


    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  void _videoListener(){
    setState(() {
      _currentVideoDuration = _videoController.value.position;
      if(_videoController.value.position.compareTo(_videoController.value.duration)==0){
        _isVideoFinished = true;
      }

      _videoSliderValue = _videoController.value.position.inSeconds.toDouble();
    });
  }

  @override
  void dispose() { 
    _videoController.removeListener(_videoListener);
    //_videoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (_,orintation){
        if(_videoController.value.initialized){
           return _buildPortrait();
          /* if(orintation == Orientation.portrait) return _buildPortrait();
          return _buildLandscape(); */
        }
        return Center(child: CircularProgressIndicator(),);
      },
    );
  }

  Widget _buildPortrait(){
    return GestureDetector(
      onTap: (){
        setState(() {_showControls = !_showControls;});
      },
      child: Container(
        alignment: Alignment.center,
         child: AspectRatio(
            child: Stack(
              children: [
                VideoPlayer(_videoController),
                 _buildVideoControls(),
              ],
            ),
            aspectRatio: _videoController.value.aspectRatio,
          ),
      ),
    );
  }

  Widget _buildLandscape(){

  }

  Widget _buildVideoControls(){
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: _showControls ? 1:0,
      child: AbsorbPointer(
        absorbing: !_showControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: Colors.black.withOpacity(0.4),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white,),
                  onPressed: (){
                    _videoController.position.then((position) {
                      Duration newPosition = position - Duration(seconds: 10);
                      _videoController.seekTo(newPosition).then((_){
                        if(_isVideoFinished) setState(() {_isVideoFinished = false;});
                      });
                    });
                  },
                ),
                IconButton(
                  icon: _isVideoFinished ? Icon(Icons.replay, color: Colors.white,): AnimatedIcon(
                    icon:_animatedIcon,
                    progress: _animationController,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    if(_isVideoFinished){
                      setState(() {
                        _isVideoFinished = false;
                        _videoController.seekTo(Duration(seconds: 0, minutes: 0));
                        _videoController.play();
                      });
                    }else if(_videoController.value.isPlaying){
                      _videoController.pause();
                      _animationController.forward();
                    }else{
                      _videoController.play();
                      _animationController.reverse();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white,),
                  onPressed: (){
                    _videoController.position.then((position) {
                      Duration newPosition = position + Duration(seconds: 10);
                      _videoController.seekTo(newPosition);
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom:16.0),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackShape: CustomTrackShape(),
                        ),
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                          onChanged: (newValue){
                             setState(() {
                              _videoSliderValue = newValue;
                              _videoController.seekTo(Duration(seconds: newValue.toInt()));
                            });
                          },
                          value: _videoSliderValue,
                          label: _videoSliderValue.toString(),
                          min: 0,
                          max: _videoController.value.duration.inSeconds.toDouble(),
                  ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16,bottom: 8,top: 8),
                      child: Text(_printDuration(_currentVideoDuration) + '/' + _printDuration(_videoController.value.duration),
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    try{
       String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
    }catch(e){}
    return '';
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}