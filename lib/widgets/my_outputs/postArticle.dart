
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

// ignore: must_be_immutable
class PostArticle extends StatelessWidget {
  final List<User> allUsers;
  final TimelinePost timelinePost;
  final String mode;
  bool _isOriginal;
  BuildContext _context;

  PostArticle({
    @required this.timelinePost,
    @required this.allUsers,
    @required this.mode,
  });
 
  @override
  Widget build(BuildContext context) {
    _context = context;
    _isOriginal = timelinePost.postType == 'original';

    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: ()=>_performOnTapFunction(),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 0.25, 
          color: BlocProvider.of<AppBloc>(context).onDarkTheme ? Colors.white:Colors.black),
        )),
        padding: EdgeInsets.all(8),
        child: _isOriginal ? _buildOriginalPost(false) : _buildUpdatePost(),
      ),
    );
  }

  Column _buildOriginalPost(bool isUpdatePost) {
    List<Widget> colChildren = [
      RichText(
        text: TextSpan(
          children: [
            _getTitle(timelinePost, isUpdatePost),
            TextSpan(
                text: _getAuthorNameAndTagsLine(timelinePost),
                style: TextStyle(fontSize: isUpdatePost ? 8 : 12,color: BlocProvider.of<AppBloc>(_context).onDarkTheme 
          ? Colors.white60 : Colors.black.withOpacity(0.6)))
          ],
        ),
      ),
    ];
    _addDescription(colChildren);
    _addImages(colChildren);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colChildren,
    );
  }

  void _addDescription(List<Widget> colChildren) {
    if (timelinePost.description.trim().length > 0) {
      colChildren.add(
        Padding(
        padding: EdgeInsets.only(top: 8),
        child:
        Text(
          timelinePost.description,
          style: TextStyle(fontSize: 16),
        ),
      ));
    }
  }

  void _addImages(List<Widget> colChildren) {
    if (timelinePost.gallerySources.length != 0) {
      colChildren.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: PostArticleMediaContainer(
          isOriginal: _isOriginal,
          timelinePost: timelinePost,
        ),
      ));
    }
  }

  Column _buildUpdatePost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UPDATE: ' + timelinePost.getPostDateString(), style: TextStyle(fontSize: 16,color: BlocProvider.of<AppBloc>(_context).onDarkTheme 
          ? Colors.white60 : Colors.black.withOpacity(0.6))),
        Text(timelinePost.updateLog,style: TextStyle(fontSize: 26),),
        SizedBox(height: 8,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.25,
              color: BlocProvider.of<AppBloc>(_context).onDarkTheme ? Colors.white:Colors.black,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(8),
          child: _buildOriginalPost(true),
        ),
      ],
    );
  }

  TextSpan _getTitle(TimelinePost timelinePost, bool isUpdatePost){
    List<InlineSpan> children = [
      TextSpan(text: timelinePost.title),
    ];
    if(timelinePost.postDeleted) children.insert(0, TextSpan(
      text: '[DELETED] ',
      style: TextStyle(fontSize: isUpdatePost ? 22 : 26, color: Colors.red),
    ));
    return TextSpan(
      style: TextStyle(fontSize: isUpdatePost ? 22 : 26, color: BlocProvider.of<AppBloc>(_context).onDarkTheme 
      ? Colors.white : Colors.black),
      children: children,
    );
  }

  String _getAuthorNameAndTagsLine(TimelinePost timelinePost) {
    String result = '\n';
    User author = _getUserFromID(timelinePost.authorID);
    result += author.forename + ' ' + author.surname[0] + '. • ';
    result += timelinePost.getPostDateString();
    result += timelinePost.getTagsString();
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

  void _performOnTapFunction() {
    if(mode.compareTo('view')==0) BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(timelinePost.postID));
    else if(mode.compareTo('edit')==0)  BlocProvider.of<AppBloc>(_context).add(AppToEditPostPageEvent(timelinePost.postID));
  }
}

class PostArticleMediaContainer extends StatefulWidget {
  final bool isOriginal;
  final TimelinePost timelinePost;
  
  PostArticleMediaContainer({@required this.isOriginal, @required this.timelinePost});
  @override
  _PostArticleMediaContainerState createState() => _PostArticleMediaContainerState();
}

class _PostArticleMediaContainerState extends State<PostArticleMediaContainer> {
 
  Map<String, ImageTag> _gallerySrc ={};

   String _initalPostID;
   bool _initialisedData = false;

   @override
  void initState() {
    _initalPostID = widget.timelinePost.postID;
    super.initState();
  }

  void _initialiseData(){
    List<String> srcs = widget.timelinePost.gallerySources.keys.toList();
    srcs.sort();
    _gallerySrc.clear();

    if(widget.timelinePost.gallerySources.length !=0 && !_initialisedData){
      String src = srcs.first;
      String type = widget.timelinePost.gallerySources[src];
      
      if(type =='vid'){
        _gallerySrc[src] = ImageTag(
          src: src,
          type: type,
          tPostID: widget.isOriginal ? '0' : widget.timelinePost.id
        );
      }else{
        int imageNo = 0;

        srcs.forEach((key) {
          if(imageNo != 4 &&  widget.timelinePost.gallerySources[key]=='img'){
            _gallerySrc[key] = ImageTag(
              src: key,
              type: widget.timelinePost.gallerySources[key],
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
    if(_initalPostID.compareTo(widget.timelinePost.id) != 0){
      // ! Data has changed
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted){
           setState(() {
          _initialisedData = false;
          _initalPostID = widget.timelinePost.id;
          _gallerySrc.clear();
        });
         }
      });
      return AspectRatio(
        aspectRatio: 16/9,
        child: Center(child: CircularProgressIndicator(),)
      );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Expanded(child:_buildMediaSlot(0),),
              SizedBox(height: 2,),
              Expanded( child:_buildMediaSlot(2),),
            ],
          ),
        ),
        SizedBox(width: 2,),
        Expanded(
          child: Column(
            children: [
              Expanded(child:_buildMediaSlot(1),),
              SizedBox( height: 2,),
              Expanded(child:_buildMediaSlot(3),),
            ],
          ),
        ),
      ];
    }else if (_gallerySrc.length == 3){
      return [
       Expanded( child:_buildMediaSlot(0),),
        SizedBox(width: 2,),
        Expanded(
          child: Column(
            children: [
              Expanded( child:_buildMediaSlot(1),),
              SizedBox(height: 2,),
              Expanded( child:_buildMediaSlot(2),),
            ],
          ),
        ),
      ];
    }else if (_gallerySrc.length == 2){
      return[
        Expanded(child:_buildMediaSlot(0),),
        SizedBox(width: 2,),
         Expanded(child:_buildMediaSlot(1),),
      ];
    }
      return [ Expanded(child:_buildMediaSlot(0),), ];
  }

  Widget _buildMediaSlot(int index){
    if(_gallerySrc.values.elementAt(index).type=='img') return _buildImageContainer(index);
    return _buildVideoContainer(index);
  }

  Widget _buildVideoContainer(int index){
    String thumbnailSrc = widget.timelinePost.thumbnailSrc;
    return GestureDetector(
      onTap: ()=>_moveToViewImageVideo(index),
      child: Container(
        child: Icon(Icons.play_circle_outline,color: Colors.white,),
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImageWithRetry(thumbnailSrc),fit: BoxFit.cover)
        ),
      ),
    );
  }

  Widget _buildImageContainer(int index){
    final src = _gallerySrc.keys.elementAt(index);
    return Hero(
      tag: _gallerySrc.values.elementAt(index).heroTag,
      child: Container(
        child: GestureDetector(onTap: ()=>_moveToViewImageVideo(index),),
        decoration: BoxDecoration(
          image: DecorationImage(image: _isImageAGif(src) ? NetworkImage(src) : NetworkImageWithRetry(src),fit: BoxFit.cover)
        ),
      ),
    );
  }

  bool _isImageAGif(String src){
    List<String> firstLayer = src.split('2F');
    String itemName = firstLayer.last.split('?').first;
    return itemName.contains('gif');
  } 

  void _moveToViewImageVideo(int index) {
    BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(_gallerySrc, index));
  }

}
