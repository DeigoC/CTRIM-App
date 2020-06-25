import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/models/timelinePost.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostArticle extends StatelessWidget {

  final List<Post> allPosts;
  final List<User> allUsers;
  final TimelinePost timelinePost;
  static BuildContext _context;
  PostArticle({@required this.allPosts, @required this.timelinePost, @required this.allUsers});

  @override
  Widget build(BuildContext context) {
    _context = context;
    Post thisPost = _getPostFromID(timelinePost.postID);
    List<Widget> colChildren =[
      RichText(
        text: TextSpan(
          text: thisPost.title,
          style: TextStyle(fontSize: 26, color: Colors.black),
          children: [
            TextSpan(text: _getAuthorNameAndTagsLine(timelinePost, thisPost),
            style: TextStyle(fontSize: 12))
          ],
        ),
      ),
      SizedBox(height: 8,),
      Text(thisPost.description),
    ];  
    if(thisPost.gallerySources.length != 0){
      colChildren.addAll(_addPostImageWidgets(thisPost));
    }
    colChildren.add(Divider());
    
    
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () => _moveToViewPost(thisPost),
      child: Padding(
        padding: EdgeInsets.only(left:8.0, bottom: 8, right:8 ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: colChildren,
        ),
      ),
    );
  }
  
  List<Widget> _addPostImageWidgets(Post thisPost){
    return [
       SizedBox(height: 8,),
      _buildImagesBox(thisPost),
      SizedBox(height: 8,),
    ];
  }

  String _getAuthorNameAndTagsLine(TimelinePost timelinePost, Post post,){
    String result = '\nBy ';
    User author = _getUserFromID(timelinePost.authorID);
    result += author.forename + ' ' + author.surname[0] + '. ';
    result += timelinePost.getPostDateString();
    result += post.getTagsString();
    return result;
  }

  Post _getPostFromID(String id){
    Post result;
    allPosts.forEach((post) {
      if(post.id.compareTo(id) == 0){
        result = post;
      }
    });
    return result;
  }

  User _getUserFromID(String id){
    User result;
    allUsers.forEach((user) {
      if(user.id.compareTo(id) == 0){
        result = user;
      }
    });
    return result;
  }

  AspectRatio _buildImagesBox(Post post){
    return AspectRatio(
      aspectRatio: 16/9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: _buildImageLayoutChildren(post),
        ),
      ),
    );
  }

  List<Widget> _buildImageLayoutChildren(Post post){
    List<String> imageSrc = post.gallerySources.keys.toList();
    List<String> srcType = post.gallerySources.values.toList();
    Map<String, String> gallerySrc;
    if(imageSrc.length == 4){
      gallerySrc ={
        imageSrc[0]:srcType[0],
        imageSrc[1]:srcType[1],
        imageSrc[2]:srcType[2],
        imageSrc[3]:srcType[3],
      };
      
      return[
        Expanded(
          child: Column(
            children: [
            Expanded(
            child: Hero(
              tag: imageSrc[0],
                          child: Container(
                child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 0),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
              ),
          ),
            ),
        ),
              SizedBox(height: 2,),
             Expanded(
          child: Hero(
            tag: imageSrc[2],
                      child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 2),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[2]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
            ],
          ),
        ),
        SizedBox(width: 2,),
        Expanded(
          child: Column(
            children: [
              Expanded(
          child: Hero(
            tag: imageSrc[1],
                      child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 1),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
              SizedBox(height: 2,),
              Expanded(
          child: Hero(
            tag: imageSrc[3],
                      child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 3),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[3]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
            ],
          ),
        ),

      ];
    }else if(imageSrc.length == 3){
      gallerySrc ={
        imageSrc[0]:srcType[0],
        imageSrc[1]:srcType[1],
        imageSrc[2]:srcType[2],
      };
      return[
        Expanded(
          child: Hero(
            tag: imageSrc[0],
            child: Container(
              child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 0),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
        SizedBox(width: 2,),
         Expanded(
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: imageSrc[1],
                  child: Container(
                    child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 1),),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2,),
              Expanded(
          child: Hero(
            tag: imageSrc[2],
                      child: Container(
              child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 2),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[2]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
            ],
          ),
        ),
      ];
    }else if(imageSrc.length == 2){
      gallerySrc ={
        imageSrc[0]:srcType[0],
        imageSrc[1]:srcType[1],
      };
      return [
        Expanded(
          child: Hero(
            tag: imageSrc[0],
                      child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 0),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
        SizedBox(width: 2,),
        Expanded(
          child: Hero(
            tag: imageSrc[1],
            child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 1),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
      ];
    }
    gallerySrc ={imageSrc[0]:srcType[0],};
    return [
      Expanded(
          child: Hero(
            tag: imageSrc[0],
                      child: Container(
               child: GestureDetector(onTap: () => _moveToViewImageVideo(gallerySrc, 0),),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
              ),
            ),
          ),
        ),
    ];

  }

  void _moveToViewImageVideo(Map<String,String> gallery, int index){
    BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(gallery, index));
  }

  void _moveToViewPost(Post post){
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(post));
  }
}