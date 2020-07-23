import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage {
  
  BuildContext _context;
  final ScrollController _scrollController;

  void setContext(BuildContext context) => _context = context;

  ViewAllEventsPage(this._context,this._scrollController);

  Widget buildFAB() {
    return FloatingActionButton(
      child: Icon(Icons.add, size: 29,color: Colors.white,),
      onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent()),
      tooltip: 'Add New Post',
    );
  }

  Widget buildBody() {
    BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
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
      }, builder: (_, state) {
        if (state is TimelineDisplayFeedState) {
          return _buildBodyWithData(state);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
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
            leading: Container(),
            title: Text('Posts'),
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
              preferredSize: Size.fromHeight(40),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 0.5)),
                ),
                height: 40,
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
