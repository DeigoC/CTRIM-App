import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/galleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchAlbumsPage extends StatefulWidget {
  @override
  _SearchAlbumsPageState createState() => _SearchAlbumsPageState();
}

class _SearchAlbumsPageState extends State<SearchAlbumsPage> {
  TextEditingController _tecSearch;
  FocusNode _fnSearch;

  @override
  void initState() {
    super.initState();
    _tecSearch = TextEditingController();
    _fnSearch = FocusNode();
  }

  @override
  void dispose() {
    _tecSearch.dispose();
    _fnSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _tecSearch,
          focusNode: _fnSearch,
          autofocus: true,
          onChanged: (newString) => BlocProvider.of<TimelineBloc>(context)
              .add(TimelineAlbumSearchTextChangeEvent(newString)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintText: 'Search albums by Post title',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TimelineBloc, TimelineState>(
      condition: (_, state) {
        if (state is TimelineAlbumSearchState) return true;
        return false;
      },
      builder: (_, state) {
        if (state is TimelineAlbumDisplaySearchResultsState) {
          return _buildBodyFromResults(state.queryResults);
        }
        BlocProvider.of<TimelineBloc>(context)
            .add(TimelineAlbumSearchTextChangeEvent(''));
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildBodyFromResults(List<Post> individualPosts) {
    return GridView.builder(
      itemCount: individualPosts.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, index) {
        Post post = individualPosts[index];
        List<String> gallery = post.gallerySources.keys.toList();
        gallery.sort();

        if (post.gallerySources.values.first == 'vid'){
          String vidSrc = post.gallerySources.keys.first;
           return AlbumCoverItem(
            type: 'vid',
            src: post.thumbnails[vidSrc],
            onTap: ()=> BlocProvider.of<AppBloc>(context).add(AppToViewPostAlbumEvent(post)),
            title: post.title,
            itemCount: post.gallerySources.length.toString(),
          );
        } 
          return AlbumCoverItem(
          type: 'img',
          src: gallery.first,
          onTap: ()=> BlocProvider.of<AppBloc>(context).add(AppToViewPostAlbumEvent(post)),
          title: post.title,
          itemCount: post.gallerySources.length.toString(),
        );
      },
    );
  }

  Widget _createPictureAlbumItem(Post post) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              BlocProvider.of<AppBloc>(context)
                  .add(AppToViewPostAlbumEvent(post));
            },
            child: Hero(
              tag: post.gallerySources.keys.first,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      image: DecorationImage(
                          image: NetworkImage(post.gallerySources.keys.first),
                          fit: BoxFit.cover)),
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

  Widget _createVideoAlbumItem(Post post) {
    double portSize = MediaQuery.of(context).size.width * 0.45;
    double paddingSize = MediaQuery.of(context).size.width * 0.033;

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
          SizedBox(
            height: 8,
          ),
          Container(
              width: portSize,
              child: Text(
                post.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              )),
          Text(post.gallerySources.length.toString()),
        ],
      ),
    );
  }
}
