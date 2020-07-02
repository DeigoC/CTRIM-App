import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewPostAlbumPage extends StatelessWidget {
  final Post _post;
  static double _pictureSize, _paddingSize;
  static BuildContext _context;
  final Map<String, ImageTag> _galleryMap;

  ViewPostAlbumPage(this._post) : _galleryMap = _createGalleryTags(_post);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                title: SizedBox(
                  height: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                          tag: _post.id,
                          transitionOnUserGestures: true,
                          child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                _post.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ))),
                      Text(
                        _getAlbumStatsString(),
                        style: TextStyle(fontSize: 10, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildBody(),
      ),
    );
  }

  static Map<String, ImageTag> _createGalleryTags(Post post) {
   Map<String, ImageTag> result = {};
    post.gallerySources.forEach((src, type) {
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }

  Widget _buildBody() {
    return OrientationBuilder(builder: (_, orientation) {
      _pictureSize = MediaQuery.of(_context).size.width *
          0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
      _paddingSize = MediaQuery.of(_context).size.width * 0.01;
      if (orientation == Orientation.landscape) {
        // * 4 blocks accross so 5 paddings accross
        _pictureSize = MediaQuery.of(_context).size.width * 0.2375;
        _paddingSize = MediaQuery.of(_context).size.width * 0.01;
      }
      return SingleChildScrollView(
        child: Wrap(
          children: _post.gallerySources.keys.map((src) {
            String type = _post.gallerySources[src];
            return type == 'vid'
                ? _createVideoContainer()
                : _createImageSrcContainer(src);
          }).toList(),
        ),
      );
    });
  }

  Widget _createImageSrcContainer(String src) {
    int index = _post.gallerySources.keys.toList().indexOf(src);
    return Padding(
      padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: GestureDetector(
            onTap: () => BlocProvider.of<AppBloc>(_context)
                .add(AppToViewImageVideoPageEvent(_galleryMap, index)),
            child: Hero(
                tag: _galleryMap[src].heroTag,
                child: Image.network(
                  src,
                  fit: BoxFit.cover,
                ))),
      ),
    );
  }

  Widget _createVideoContainer() {
    return Padding(
      padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: Icon(Icons.play_circle_outline),
      ),
    );
  }

  String _getAlbumStatsString() {
    int picLengths = 0;
    _post.gallerySources.values.forEach((type) {
      if (type == 'img') picLengths++;
    });
    int vidLengths = _post.gallerySources.values.length - picLengths;
    return '$picLengths images, $vidLengths videos';
  }
}
