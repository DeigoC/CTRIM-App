import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class PostArticle extends StatelessWidget {
  final Post post;
  final List<User> allUsers;
  final TimelinePost timelinePost;
  bool _isOriginal;
  BuildContext _context;

  PostArticle(
      {@required this.post,
      @required this.timelinePost,
      @required this.allUsers}):_isOriginal = false, _context = null;
       
 
  @override
  Widget build(BuildContext context) {
    _context = context;
    _isOriginal = timelinePost.postType == 'original';

    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () => _moveToViewPost(post),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 0.25),
        )),
        padding: EdgeInsets.all(8),
        child: _isOriginal ? _buildOriginalPost(false) : _buildUpdatePost(),
      ),
    );
  }

  Widget _buildOriginalPost(bool isUpdatePost) {
    List<Widget> colChildren = [
      RichText(
        text: TextSpan(
          text: post.title,
          style:
              TextStyle(fontSize: isUpdatePost ? 22 : 26, color: Colors.black),
          children: [
            TextSpan(
                text: _getAuthorNameAndTagsLine(timelinePost, post),
                style: TextStyle(fontSize: isUpdatePost ? 8 : 12))
          ],
        ),
      ),
    ];
    _addDescription(colChildren);
    _addImages(colChildren);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: colChildren,
    );
  }

  void _addDescription(List<Widget> colChildren) {
    if (post.description.trim().length > 0) {
      colChildren.add(Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          post.description,
          style: TextStyle(fontSize: 16),
        ),
      ));
    }
  }

  void _addImages(List<Widget> colChildren) {
    if (post.gallerySources.length != 0) {
      colChildren.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: PostArticleMediaContainer(
          isOriginal: _isOriginal,
          timelinePost: timelinePost,
          post: post,
        ),
      ));
    }
  }

  Widget _buildUpdatePost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Update: ' + timelinePost.getPostDateString(), style: TextStyle(fontSize: 12)),
        Text(timelinePost.updateLog,style: TextStyle(fontSize: 26),),
        SizedBox(height: 8,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.25),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(8),
          child: _buildOriginalPost(true),
        ),
      ],
    );
  }

  String _getAuthorNameAndTagsLine(TimelinePost timelinePost,Post post,) {
    String result = '\nBy ';
    User author = _getUserFromID(timelinePost.authorID);
    result += author.forename + ' ' + author.surname[0] + '. ';
    result += timelinePost.getPostDateString();
    result += post.getTagsString();
    return result;
  }

  User _getUserFromID(String id) {
    User result;
    allUsers.forEach((user) {
      if (user.id.compareTo(id) == 0) {
        result = user;
      }
    });
    return result;
  }

  void _moveToViewPost(Post post) {
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(post));
  }
}

class PostArticleMediaContainer extends StatefulWidget {
  final Post post;
  final bool isOriginal;
  final TimelinePost timelinePost;
  
  PostArticleMediaContainer({@required this.post, @required this.isOriginal, @required this.timelinePost});
  @override
  _PostArticleMediaContainerState createState() => _PostArticleMediaContainerState();
}

class _PostArticleMediaContainerState extends State<PostArticleMediaContainer> {
  
  VideoPlayerController _videoController;
  Map<String, ImageTag> _gallerySrc ={};

   String _initalPostID;
   bool _initialisedData = false;

   @override
  void initState() {
    _initalPostID = widget.post.id;
    //_initialiseData();
    super.initState();
  }

  @override
  void dispose() { 
    if(_videoController != null) _videoController.dispose();
    super.dispose();
  }

  void _initialiseData(){
    if(widget.post.gallerySources.length !=0 && !_initialisedData){
      String type = widget.post.gallerySources.values.elementAt(0);
      String src = widget.post.gallerySources.keys.elementAt(0);
      if(type =='vid' && _videoController == null){
        _gallerySrc[src] = ImageTag(
          src: src,
          type: type,
          tPostID: widget.isOriginal ? '0' : widget.timelinePost.id
        );
        _videoController = VideoPlayerController.network(widget.post.gallerySources.keys.elementAt(0));
        _videoController.initialize().then((_){
          if(mounted){
            setState(() {
              _initialisedData = true;
            });
          }
        });
      }else{
        int imageNo = 0;
        List<String> srcs = widget.post.gallerySources.keys.toList();
        srcs.sort();

        srcs.forEach((key) {
          if(imageNo != 4 &&  widget.post.gallerySources[key]=='img'){
            _gallerySrc[key] = ImageTag(
              src: key,
              type: widget.post.gallerySources[key],
              tPostID: widget.isOriginal ? '0' : widget.timelinePost.id
            );
            imageNo++;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_initalPostID.compareTo(widget.post.id) != 0){
      // ! Data has changed
      WidgetsBinding.instance.addPostFrameCallback((_) {
         setState(() {
         _videoController = null;
          _initialisedData = false;
          _initalPostID = widget.post.id;
          _gallerySrc.clear();
        });
      });
    }else{
      _initialiseData();
    }
    if(_gallerySrc.length > 1 && _gallerySrc.values.first.type=='vid'){
      _gallerySrc = {_gallerySrc.keys.first:_gallerySrc.values.first};
    }

    return AspectRatio(
      aspectRatio: 16/9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: _buildImageLayoutChildren(),
        ),
      ),
    );
  }
  
  List<Widget> _buildImageLayoutChildren(){
    if (_gallerySrc.length >= 4) {
       return [
        Expanded(
          child: Column(
            children: [
              Expanded(child:_buildMediaSlot(_gallerySrc, 0),),
              SizedBox(height: 2,),
              Expanded( child:_buildMediaSlot(_gallerySrc, 2),),
            ],
          ),
        ),
        SizedBox(width: 2,),
        Expanded(
          child: Column(
            children: [
              Expanded(child:_buildMediaSlot(_gallerySrc, 1),),
              SizedBox( height: 2,),
              Expanded(child:_buildMediaSlot(_gallerySrc, 3),),
            ],
          ),
        ),
      ];
    }else if (_gallerySrc.length == 3){
      return [
       Expanded( child:_buildMediaSlot(_gallerySrc, 0),),
        SizedBox(width: 2,),
        Expanded(
          child: Column(
            children: [
              Expanded( child:_buildMediaSlot(_gallerySrc, 1),),
              SizedBox(height: 2,),
              Expanded( child:_buildMediaSlot(_gallerySrc, 2),),
            ],
          ),
        ),
      ];
    }else if (_gallerySrc.length == 2){
      return[
        Expanded(child:_buildMediaSlot(_gallerySrc, 0),),
        SizedBox(width: 2,),
         Expanded(child:_buildMediaSlot(_gallerySrc, 1),),
      ];
    }
      return [ Expanded(child:_buildMediaSlot(_gallerySrc, 0),), ];
  }

  Widget _buildMediaSlot(Map<String, ImageTag> gallerySrc, int index){
    if(gallerySrc.values.elementAt(index).type=='img') return _buildImageContainer(gallerySrc, index);
    return _buildVideoContainer(gallerySrc, index);
  }

  Widget _buildVideoContainer(Map<String, ImageTag> gallerySrc, int index){
    double iconSize = MediaQuery.of(context).size.width*0.15;
    if(_videoController == null){
      return CircularProgressIndicator();
    }
    return Stack(
      alignment: Alignment.center,
          children:[ 
            Container(
            child: GestureDetector(
            onTap: (){ _moveToViewImageVideo(gallerySrc, index);},
            child: VideoPlayer(_videoController)
          ),
        ),
        Icon(Icons.play_circle_outline, color: Colors.white, size: iconSize,),
          ]
    );
  }

  Hero _buildImageContainer(Map<String, ImageTag> gallerySrc, int index){
    return Hero(
      tag: gallerySrc.values.elementAt(index).heroTag,
      child: Container(
        child: GestureDetector(onTap: ()=>_moveToViewImageVideo(gallerySrc, index),),
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(gallerySrc.keys.elementAt(index),),fit: BoxFit.cover)
        ),
      ),
    );
  }

  void _moveToViewImageVideo(Map<String, ImageTag> gallery, int index) {
    BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(gallery, index));
  }

}
