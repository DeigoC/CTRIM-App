import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostArticle extends StatelessWidget {
  final Post post;
  final List<User> allUsers;
  final TimelinePost timelinePost;
  static BuildContext _context;
  static bool _isOriginal;

  PostArticle(
      {@required this.post,
      @required this.timelinePost,
      @required this.allUsers});

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
        child: _buildImagesBox(post),
      ));
    }
  }

  Widget _buildUpdatePost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Update: ' + timelinePost.postDate.toString(),
            style: TextStyle(fontSize: 12)),
        Text(
          timelinePost.updateLog,
          style: TextStyle(fontSize: 26),
        ),
        SizedBox(height: 8,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.75),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(8),
          child: _buildOriginalPost(true),
        ),
      ],
    );
  }

  String _getAuthorNameAndTagsLine(
    TimelinePost timelinePost,
    Post post,
  ) {
    String result = '\nBy ';
    User author = _getUserFromID(timelinePost.authorID);
    result += author.forename + ' ' + author.surname[0] + '. ';
    result += timelinePost.getPostDateString();
    result += post.getTagsString();
    return result;
  }

  AspectRatio _buildImagesBox(Post post) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: _buildImageLayoutChildren(post),
        ),
      ),
    );
  }

  List<Widget> _buildImageLayoutChildren(Post post) {
    List<String> imageSrc = post.gallerySources.keys.toList();
    List<String> srcType = post.gallerySources.values.toList();
    Map<String, ImageTag> gallerySrc;
    if (imageSrc.length == 4) {
      gallerySrc = {
        imageSrc[0]: ImageTag(
            src: imageSrc[0],
            type: srcType[0],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[1]: ImageTag(
            src: imageSrc[1],
            type: srcType[1],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[2]: ImageTag(
            src: imageSrc[2],
            type: srcType[2],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[3]: ImageTag(
            src: imageSrc[3],
            type: srcType[3],
            tPostID: _isOriginal ? '0' : timelinePost.id),
      };

      return [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(0).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 0),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[0]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(2).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 2),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[2]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(1).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 1),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[1]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(3).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 3),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[3]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (imageSrc.length == 3) {
      gallerySrc = {
        imageSrc[0]: ImageTag(
            src: imageSrc[0],
            type: srcType[0],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[1]: ImageTag(
            src: imageSrc[1],
            type: srcType[1],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[2]: ImageTag(
            src: imageSrc[2],
            type: srcType[2],
            tPostID: _isOriginal ? '0' : timelinePost.id),
      };
      return [
        Expanded(
          child: Hero(
            tag: gallerySrc.values.elementAt(0).heroTag,
            child: Container(
              child: GestureDetector(
                onTap: () => _moveToViewImageVideo(gallerySrc, 0),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)),
            ),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(1).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 1),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[1]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: Hero(
                  tag: gallerySrc.values.elementAt(2).heroTag,
                  child: Container(
                    child: GestureDetector(
                      onTap: () => _moveToViewImageVideo(gallerySrc, 2),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageSrc[2]),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (imageSrc.length == 2) {
      gallerySrc = {
        imageSrc[0]: ImageTag(
            src: imageSrc[0],
            type: srcType[0],
            tPostID: _isOriginal ? '0' : timelinePost.id),
        imageSrc[1]: ImageTag(
            src: imageSrc[1],
            type: srcType[1],
            tPostID: _isOriginal ? '0' : timelinePost.id),
      };
      return [
        Expanded(
          child: Hero(
            tag: gallerySrc.values.elementAt(0).heroTag,
            child: Container(
              child: GestureDetector(
                onTap: () => _moveToViewImageVideo(gallerySrc, 0),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)),
            ),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: Hero(
            tag: gallerySrc.values.elementAt(1).heroTag,
            child: Container(
              child: GestureDetector(
                onTap: () => _moveToViewImageVideo(gallerySrc, 1),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imageSrc[1]), fit: BoxFit.cover)),
            ),
          ),
        ),
      ];
    }
    gallerySrc = {
      imageSrc[0]: ImageTag(
          src: imageSrc[0],
          type: srcType[0],
          tPostID: _isOriginal ? '0' : timelinePost.id),
    };
    return [
      Expanded(
        child: Hero(
          tag: gallerySrc.values.elementAt(0).heroTag,
          child: Container(
            child: GestureDetector(
              onTap: () => _moveToViewImageVideo(gallerySrc, 0),
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(imageSrc[0]), fit: BoxFit.cover)),
          ),
        ),
      ),
    ];
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

  void _moveToViewImageVideo(Map<String, ImageTag> gallery, int index) {
    BlocProvider.of<AppBloc>(_context)
        .add(AppToViewImageVideoPageEvent(gallery, index));
  }

  void _moveToViewPost(Post post) {
    BlocProvider.of<AppBloc>(_context).add(AppToViewPostPageEvent(post));
  }
}
