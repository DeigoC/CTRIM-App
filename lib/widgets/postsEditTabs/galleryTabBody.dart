import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/galleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryTabBody extends StatelessWidget {
  final Orientation orientation;
  final Map<String, String> gallerySrc;
  final Map<String, String> thumbnails;

  static double pictureSize, paddingSize;
  static String _mode = 'addingPost';
  static BuildContext _context;

  GalleryTabBody({@required this.orientation, this.gallerySrc, this.thumbnails}) {
    _mode = 'addingPost';
  }

  GalleryTabBody.view({@required this.orientation, @required this.gallerySrc, @required this.thumbnails}) {
    _mode = 'viewingPost';
  }

  GalleryTabBody.edit({
    @required this.orientation,
    @required this.gallerySrc,
    @required this.thumbnails,
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
        MyRaisedButton(
          label:'ADD/EDIT',
          externalPadding: EdgeInsets.symmetric(horizontal: 8),
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToCreateAlbumEvent(BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox(height: 20,),
        Wrap(
          children: BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
            String type = BlocProvider.of<PostBloc>(_context).files[file];
            return type == 'vid'? GalleryItem.file(type: 'vid', file: file,thumbnails: thumbnails,)
                : GalleryItem.file(type: 'img', file: file,thumbnails: thumbnails,);
          }).toList(),
        )
      ],
    );
  }

  Widget _buildGalleryEditPost() {
    Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    List<String> srcs = gallerySrc.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));

    List<Widget> wrapChildren =srcs.map((src) {
      String type = BlocProvider.of<PostBloc>(_context).gallerySrc[src];
        return type == 'vid'? GalleryItem(
          thumbnails: thumbnails,
          type: 'vid',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap: ()=>null,
        ): GalleryItem(
          thumbnails: thumbnails,
          type: 'img',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap:()=>null,
        );
    }).toList();

    wrapChildren.addAll(BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
      String type = BlocProvider.of<PostBloc>(_context).files[file];
      return type == 'vid'? GalleryItem.file(type: 'vid', file: file,thumbnails: thumbnails,)
      : GalleryItem.file(type: 'img', file: file,thumbnails: thumbnails,);
    }).toList());

    return ListView(
      children: [
        MyRaisedButton(
          label: 'Add/Edit Album',
          externalPadding: EdgeInsets.symmetric(horizontal: 8),
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToEditAlbumEvent(BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox( height: 20,),
        Wrap(children: wrapChildren)
      ],
    );
  }

  Widget _buildGalleryViewPost() {
    print('----------------------BUILDING GALLERY TAB');
    if (gallerySrc.length == 0) return Center(child: Text('No Images or Videos'),);
   
   Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    List<String> srcs = gallerySrc.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Insert Statistics?'),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              children: srcs.map((src) {
                String type = gallerySrc[src];
                int index = srcs.indexOf(src);

                return type == 'vid'? GalleryItem(
                  thumbnails: thumbnails,
                  type: 'vid',
                  src: src,
                  heroTag: galleryTags[src].heroTag,
                  onTap: ()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
                )
                : GalleryItem(
                  thumbnails: thumbnails,
                  type: 'img',
                  src: src,
                  heroTag: galleryTags[src].heroTag,
                  onTap:()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, ImageTag> _createGalleryTags(Map<String, String> gallery) {
    Map<String, ImageTag> result = {};
    List<String> srcs = gallery.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));
    srcs.forEach((src) {
      String type = gallery[src];
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }
}
