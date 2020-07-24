import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/galleryTabBody.dart';
import 'package:flutter/material.dart';

class ViewPostAlbumPage extends StatelessWidget {
  final Post _post;

  ViewPostAlbumPage(this._post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.35,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.zero,
              title: SizedBox(
                height: MediaQuery.of(context).size.height * 0.252,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _post.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      _getAlbumStatsString(),
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(child:GalleryTabBody.view(
            gallerySrc: _post.gallerySources, 
            thumbnails: _post.thumbnails, 
          ),),
        ],
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
