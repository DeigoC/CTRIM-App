import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ViewAllEventsPage {
  
  BuildContext _context;
  final ScrollController _scrollController;

  void setContext(BuildContext context) => _context = context;

  ViewAllEventsPage(this._context,this._scrollController);

  Widget buildFAB() {
    if(BlocProvider.of<AppBloc>(_context).currentUser.adminLevel == 0) return null;
    return FloatingActionButton(
      child: Icon(MaterialCommunityIcons.newspaper_plus, size: 29,color: Colors.white,),
      onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent()),
      tooltip: 'New Post',
    );
  }

  Widget buildBody() {
    return BlocConsumer<TimelineBloc, TimelineState>(
      listenWhen: (_,state){
        if(state is TimelineNewPostUploadedState) return true;
        else if(state is TimelineTagChangedState) return true;
        return false; 
      },
      listener: (_,state){
        if(state is TimelineNewPostUploadedState){
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }else if(state is TimelineTagChangedState){
          //_scrollController.jumpTo(_scrollController.position.minScrollExtent);
          _scrollController.animateTo(_scrollController.position.minScrollExtent, 
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        }
      },
      buildWhen: (_, state) {
        if (state is TimelineDisplayFeedState) return true;
        return false;
      },
      builder: (_, state) {
        if (state is TimelineDisplayFeedState) {
          return _buildBodyWithData(state);
        }else{
          var allData = BlocProvider.of<TimelineBloc>(_context).initialPostsData;
          return _buildBodyWithData(allData);
        }
    });
  }

  Widget _buildBodyWithData(TimelineDisplayFeedState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await BlocProvider.of<TimelineBloc>(_context).reloadAllRecords().then((_){
          BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
        });
      },
      child: CustomScrollView(
        controller: _scrollController,
        key: PageStorageKey<String>('ViewAllPostsTab'),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 8,
            //leading: Icon(FontAwesome5Solid.church,color: Colors.white,),
            title: Row(
              children: [
                Icon(FontAwesome5Solid.church,color: Colors.white,),
                SizedBox(width: 24,),
                Text('Posts'),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search by title',
                onPressed: ()=>BlocProvider.of<AppBloc>(_context).add(AppToSearchPostsPageEvent()),
              )
            ],
            floating: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: Container(
                padding: EdgeInsets.only(bottom: 4),
                height: 35,
                child: BlocBuilder<TimelineBloc, TimelineState>(
                    condition: (_, state) {
                  if (state is TimelineTagChangedState) return true;
                  return false;
                }, builder: (_, state) {
                  return ListView(
                    key: PageStorageKey<String>('PostsTagList'),
                    scrollDirection: Axis.horizontal,
                    children: BlocProvider.of<TimelineBloc>(_context).getSelectedTags()
                        .keys
                        .map((tag) {
                      return Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: FilterChip(
                          label: Text(tag),
                          onSelected: (newState) =>
                              BlocProvider.of<TimelineBloc>(_context)
                                  .add(TimelineTagClickedEvent(tag)),
                          selected: BlocProvider.of<TimelineBloc>(_context)
                              .getSelectedTags()[tag],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ),
          SliverList(
            key: PageStorageKey<String>('AllPostsView'),
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                return PostArticle(
                  mode: 'view',
                  allUsers: state.users,
                  post: _getPostFromID(state.timelines[index].postID, state.posts),
                  timelinePost: state.timelines[index],
                );
              },
              childCount: state.timelines.length,
            ),
          ),
        ],
      ),
    );
  }

  Post _getPostFromID(String id, List<Post> allPosts) {
    Post result;
    allPosts.forEach((post) {
      if (post.id.compareTo(id) == 0) {
        result = post;
      }
    });
    return result;
  }
}
