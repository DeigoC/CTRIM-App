import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/galleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryTabBody extends StatelessWidget {
  final Orientation orientation;
  final Map<String, String> gallerySrc;

  static double pictureSize, paddingSize;
  static String _mode = 'addingPost';
  static BuildContext _context;

  GalleryTabBody({@required this.orientation, this.gallerySrc}) {
    _mode = 'addingPost';
  }

  GalleryTabBody.view({@required this.orientation, @required this.gallerySrc}) {
    _mode = 'viewingPost';
  }

  GalleryTabBody.edit({
    @required this.orientation,
    @required this.gallerySrc,
  }) {
    _mode = 'editingPost';
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _setupSizes();
    if (_mode == 'viewingPost')
      return _buildGalleryViewPost();
    else if (_mode == 'editingPost') return _buildGalleryEditPost();
    return _buildGalleryAddPost();
  }

  void _setupSizes() {
    pictureSize = MediaQuery.of(_context).size.width *
        0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    paddingSize = MediaQuery.of(_context).size.width * 0.01;
    if (orientation == Orientation.landscape) {
      // * 4 blocks accross so 5 paddings accross
      pictureSize = MediaQuery.of(_context).size.width * 0.2375;
      paddingSize = MediaQuery.of(_context).size.width * 0.01;
    }
  }

  Widget _buildGalleryAddPost() {
    return ListView(
      children: [
        FlatButton(
          child: Text('ADD/EDIT'),
          onPressed: () => BlocProvider.of<AppBloc>(_context)
              .add(AppToCreateAlbumEvent(BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox(
          height: 20,
        ),
        Wrap(
          children: BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
            String type = BlocProvider.of<PostBloc>(_context).files[file];
            return type == 'vid'? GalleryItem.file(type: 'vid', file: file)
                : GalleryItem.file(type: 'img', file: file);
          }).toList(),
        )
      ],
    );
  }

  Widget _buildGalleryEditPost() {
    Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    List<Widget> wrapChildren =
    BlocProvider.of<PostBloc>(_context).gallerySrc.keys.map((src) {
      String type = BlocProvider.of<PostBloc>(_context).gallerySrc[src];
        return type == 'vid'? GalleryItem(
          type: 'vid',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap: ()=>null,
        ): GalleryItem(
          type: 'img',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap:()=>null,
        );
    }).toList();

    wrapChildren.addAll(BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
      String type = BlocProvider.of<PostBloc>(_context).files[file];
      return type == 'vid'? GalleryItem.file(type: 'vid', file: file): GalleryItem.file(type: 'img', file: file);
    }).toList());

    return ListView(
      children: [
        FlatButton(
          child: Text('Add/Edit Album'),
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToEditAlbumEvent(BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox( height: 20,),
        Wrap(children: wrapChildren)
      ],
    );
  }

  Widget _buildGalleryViewPost() {
    if (gallerySrc.length == 0) return Center(child: Text('No Images or Videos'),);
   
   Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    return SingleChildScrollView(
      child: Wrap(
        children: gallerySrc.keys.map((src) {
          String type = gallerySrc[src];
          int index = gallerySrc.keys.toList().indexOf(src);
          return type == 'vid'? GalleryItem(
            type: 'vid',
            src: src,
            heroTag: galleryTags[src].heroTag,
            onTap: ()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
          )
          : GalleryItem(
            type: 'img',
            src: src,
            heroTag: galleryTags[src].heroTag,
            onTap:()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
          );
        }).toList(),
      ),
    );
  }

  Widget _createImageSrcContainer(String src) {
    print('--------------------BUILDING SRC IMAGE' + src);
    int index = gallerySrc.keys.toList().indexOf(src);
    Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: GestureDetector(
            onTap: () => BlocProvider.of<AppBloc>(_context)
                .add(AppToViewImageVideoPageEvent(galleryTags, index)),
            child: Hero(
                tag: galleryTags.values.elementAt(index).heroTag,
                child: Image.network(
                  src,
                  fit: BoxFit.cover,
                ))),
      ),
    );
  }

  Map<String, ImageTag> _createGalleryTags(Map<String, String> gallery) {
    Map<String, ImageTag> result = {};
    gallery.forEach((src, type) {
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }

  Widget _createImageFileContainer(File file) {
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: Image.file(
          file,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _createVideoContainer() {
    return Padding(
      padding: EdgeInsets.only(top: paddingSize, left: paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: pictureSize,
        height: pictureSize,
        child: Icon(Icons.play_circle_outline),
      ),
    );
  }
}
