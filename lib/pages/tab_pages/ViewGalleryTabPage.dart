import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/galleryItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ViewGalleryPage {
  BuildContext _context;
  void setContext(BuildContext context) => _context = context;
  final TabController _tabController;
  final List<Tab> _myTabs = [
    Tab(icon: Icon(Icons.view_module),),
    Tab( icon: Icon(Icons.folder,))
  ];
 
  Map<DateTime, List<Post>> _allPosts;

  //TODO may not need the controller at the end
  ViewGalleryPage(this._context, this._tabController);

  Widget buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Gallery'),
      centerTitle: true,
      bottom: TabBar(
          controller: _tabController,
          tabs: _myTabs,
        ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          tooltip: 'Search by post title',
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToSearchAlbumPageEvent()),
        )
      ],
    );
  }

  Widget buildBody() {
     _allPosts = BlocProvider.of<TimelineBloc>(_context).getPostsForGalleryTab();
    return TabBarView(
      controller: _tabController,
      children: [
        _timelineView(),
        _ablumView(),
      ],
    );
  }

  Widget _timelineView() {
    return OrientationBuilder(builder: (_, orientation) {
      return ListView.builder(
          key: PageStorageKey<String>('TimlineTab'),
          itemCount: _allPosts.keys.length,
          itemBuilder: (_, index) {
            DateTime date = _allPosts.keys.toList().reversed.elementAt(index);
            Map<String, String> srcs = {};
            String dateString = DateFormat('dd MMMM yyyy').format(date);
            _allPosts[date].forEach((post) => srcs.addAll(post.gallerySources));

            Map<String, ImageTag> galleryTags = _createGalleryTags(srcs);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                Text(' ' + dateString,style: TextStyle(fontSize: 28),),
                SizedBox(height: 4,),
                Wrap(
                  children: srcs.keys.map((src) {
                    int pos = srcs.keys.toList().indexOf(src);
                    if (srcs[src].compareTo('vid') == 0) {
                      return GalleryItem(
                        src: src,
                        type: srcs[src],
                        heroTag: galleryTags.values.elementAt(pos).heroTag,
                        onTap: ()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, pos)),
                      );
                    }
                    return GalleryItem(
                        src: src,
                        type: srcs[src],
                        heroTag: galleryTags.values.elementAt(pos).heroTag,
                        onTap: ()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, pos)),
                      );
                  }).toList(),
                ),
              ],
            );
          });
    });
  }
  
  Map<String, ImageTag> _createGalleryTags(Map<String, String> gallery) {
    Map<String, ImageTag> result = {};
    gallery.forEach((src, type) {
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }

  Widget _ablumView() {
    List<Post> individualPosts = [];
    _allPosts.values.forEach((listOfPosts) {
      individualPosts.addAll(listOfPosts);
    });

    return GridView.builder(
      key: PageStorageKey<String>('GalleryView'),
      itemCount: individualPosts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, index) {
        Post post = individualPosts[index];
        if (post.gallerySources.values.first == 'vid'){
          return AlbumCoverItem(
            type: 'vid',
            src: post.gallerySources.keys.first,
            onTap: ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewPostAlbumEvent(post)),
            title: post.title,
            itemCount: post.gallerySources.length.toString(),
          );
        }
        return AlbumCoverItem(
          type: 'img',
          src: post.gallerySources.keys.first,
          onTap: ()=> BlocProvider.of<AppBloc>(_context).add(AppToViewPostAlbumEvent(post)),
          title: post.title,
          itemCount: post.gallerySources.length.toString(),
        );
        //return _createPictureAlbumItem(post);
      },
    );
  }
}
