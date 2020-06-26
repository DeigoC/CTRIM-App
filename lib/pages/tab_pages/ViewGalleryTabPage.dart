import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/imageTag.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ViewGalleryPage{

  BuildContext _context;
  void setContext(BuildContext context) => _context = context;
  final TabController _tabController;
  final List<Tab> _myTabs =[
    Tab(icon: Icon(Icons.view_module),),
    Tab(icon: Icon(Icons.folder,))
  ];

  double _pictureSize, _paddingSize;
  Map<DateTime, List<Post>> _allPosts;

  ViewGalleryPage(this._context, this._tabController){
    _allPosts = BlocProvider.of<TimelineBloc>(_context).getPostsForGalleryTab();
  }

  Widget buildAppBar(){
   return AppBar(
      title: Container(
        width: MediaQuery.of(_context).size.width * 0.4,
        child: TabBar(
          controller: _tabController,
          tabs: _myTabs,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          tooltip: 'Search by post title',
          onPressed: ()=> BlocProvider.of<AppBloc>(_context).add(AppToSearchAlbumPageEvent()),
        )
      ],
    );
  }

  Widget buildBody(){
    return TabBarView(
      controller: _tabController,
      children: [
        _timelineView(),
        _ablumView(),
      ],
    );
  }

  Widget _timelineView(){
    return OrientationBuilder(
      builder:(_,orientation){
        _pictureSize = _pictureSize = MediaQuery.of(_context).size.width * 0.32;
        _paddingSize = MediaQuery.of(_context).size.width * 0.01;
        if(orientation == Orientation.landscape){
          // * 4 blocks accross so 5 paddings accross
          _pictureSize = MediaQuery.of(_context).size.width * 0.2375;
          _paddingSize = MediaQuery.of(_context).size.width * 0.01;
        }

        return ListView.builder(
          key: PageStorageKey<String>('TimlineTab'),
          itemCount: _allPosts.keys.length,
          itemBuilder: (_,index){
            DateTime date = _allPosts.keys.toList().reversed.elementAt(index);
            Map<String,String> srcs = {};
            String dateString = DateFormat('dd MMMM yyyy').format(date);
            _allPosts[date].forEach((post) => srcs.addAll(post.gallerySources));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                Text(' ' + dateString, style: TextStyle(fontSize: 28),),
                SizedBox(height: 4,),
                Wrap(
                  children: srcs.keys.map((src){
                    if(srcs[src].compareTo('vid')==0){
                      return _createVideoContainer(src, srcs);
                    }
                      return _createImageContainer(src, srcs);
                  }).toList(),
                ),
              ],
            );
          }
        );
      } 
    );
  }

  Padding _createImageContainer(String src, Map<String,String> gallery){
    Map<String,ImageTag> galleryTags = _createGalleryTags(gallery);
    int pos = gallery.keys.toList().indexOf(src);
    return Padding(
      padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _pictureSize,
        height: _pictureSize,
        child: GestureDetector(
          onTap: (){
            BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, pos));
          },
          child: Hero(
            tag: galleryTags.values.elementAt(pos).heroTag,
            child: Image.network(src, fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }

  Map<String,ImageTag> _createGalleryTags(Map<String, String> gallery){
    Map<String,ImageTag> result = {};
    gallery.forEach((src, type) {
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }

  Padding _createVideoContainer(String src, Map<String,String> gallery){
     return Padding(
      padding: EdgeInsets.only(top: _paddingSize, left: _paddingSize),
      child:  GestureDetector(
        onTap: (){
          int pos = gallery.keys.toList().indexOf(src);
          BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(_createGalleryTags(gallery), pos));
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _pictureSize,
          height: _pictureSize,
          child:Icon(Icons.play_circle_filled, color: Colors.black,size: 60,),
          ),
      )
    );
  }

  Widget _ablumView(){
    List<Post> individualPosts = [];
    _allPosts.values.forEach((listOfPosts) {
      individualPosts.addAll(listOfPosts);
    });

    return GridView.builder(
      key: PageStorageKey<String>('GalleryView'),
      itemCount: individualPosts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), 
      itemBuilder: (_,index){
        Post post = individualPosts[index];
        if(post.gallerySources.values.first == 'vid') return _createVideoAlbumItem(post);
        return _createPictureAlbumItem(post);
      },
    );
  }

  Widget _createPictureAlbumItem(Post post){
     return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(_context).add(AppToViewPostAlbumEvent(post));
            },
            child: Hero(
              tag: post.gallerySources.keys.first,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    image: DecorationImage(image: NetworkImage(post.gallerySources.keys.first), fit: BoxFit.cover)
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
        post.title, 
        textAlign: TextAlign.center, 
        overflow: TextOverflow.ellipsis,
        ),
        Text(post.gallerySources.length.toString()),
      ],
    ); 
  }

  Widget _createVideoAlbumItem(Post post){
    double portSize = MediaQuery.of(_context).size.width * 0.45;
    double paddingSize =  MediaQuery.of(_context).size.width * 0.033;
    
    return Padding(
      padding: EdgeInsets.only(left: paddingSize, bottom: 8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: portSize,
            height: portSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
          SizedBox(height: 8,),
          Container( width: portSize,child: Text(post.title, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)),
          Text(post.gallerySources.length.toString()),
        ],
      ),
    ); 
  }

}