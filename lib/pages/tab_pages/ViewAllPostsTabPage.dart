import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/models/timelinePost.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage{

  final BuildContext _context;

  List<TimelinePost> _timelines;
  List<Post> _posts;
  List<User> _users;

  ViewAllEventsPage(this._context);

  Widget buildAppBar(){
    return AppBar(
      title: Text('Insert Logo and search icon',),
    );
  }

  FloatingActionButton buildFAB(){
    return FloatingActionButton.extended(
      onPressed: (){
        BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent());
      },
      icon: Icon(Icons.add),
       label: Text('Event'),
      );
  }

  Widget buildBody(){
    Future.delayed(Duration(seconds: 2),(){
      BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
    });

    return BlocBuilder<TimelineBloc, TimelineState>(
      builder:(_,state){
        if(state is TimelineDisplayFeedState){
          _users = state.users;
          _posts = state.posts;
          _timelines = state.timelines;
          return ListView(
            children: _timelines.map((timeLinePost) => _createPostFromTimeline(timeLinePost)).toList(),
        );
        }
        return Center(child: CircularProgressIndicator(),);
      } 
    );

  }

  Widget _createPostFromTimeline(TimelinePost timeline){
    Post thisPost = _getPostFromID(timeline.postID);
    List<Widget> colChildren =[
      RichText(
        text: TextSpan(
          text: thisPost.title,
          style: TextStyle(fontSize: 26, color: Colors.black),
          children: [
            TextSpan(text: _getAuthorNameAndTagsLine(timeline, thisPost),
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
    
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () => _moveToViewPost(thisPost),
      child: Padding(
        padding: EdgeInsets.only(left:8.0, top: 8, right:8 ),
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
      Divider(),
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
    _posts.forEach((post) {
      if(post.id.compareTo(id) == 0){
        result = post;
      }
    });
    return result;
  }

  User _getUserFromID(String id){
    User result;
    _users.forEach((user) {
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
      return[
        Expanded(
          child: Column(
            children: [
              Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
            ),
          ),
        ),
              SizedBox(height: 2,),
             Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[2]), fit: BoxFit.cover)
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
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)
            ),
          ),
        ),
              SizedBox(height: 2,),
              Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[3]), fit: BoxFit.cover)
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
      return [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
            ),
          ),
        ),
        SizedBox(width: 2,),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)
            ),
          ),
        ),
      ];
    }
    return [
      Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)
            ),
          ),
        ),
    ];

  }

  void _moveToViewImageVideo(Map<String,String> gallery, int index){
    BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPage(gallery, index));
  }

  void _moveToViewPost(Post post){
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(post));
  }

}