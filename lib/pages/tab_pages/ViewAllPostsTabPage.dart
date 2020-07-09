import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage {
  BuildContext _context;

  void setContext(BuildContext context) => _context = context;

  ViewAllEventsPage(this._context);

  Widget buildFAB() {
    return FloatingActionButton(
      child: Icon(Icons.add, size: 29,),
      onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent()),
      tooltip: 'Add New Post',
    );
  }

  Widget buildBody() {
    /* Post t = PostDBManager.allPosts.last;
    print('----------------------GALLERY LENGTH IS ' + t.gallerySources.length.toString()); */

    BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
    return BlocConsumer<TimelineBloc, TimelineState>(
      listenWhen: (_,state){
        if(state is TimelineNewPostUploadedState) return true;
        return false; 
      },
      listener: (_,state){
        if(state is TimelineNewPostUploadedState) Navigator.of(_context).pop();
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
              child: Container(
                height: 35,
                child: BlocBuilder<TimelineBloc, TimelineState>(
                    condition: (_, state) {
                  if (state is TimelineTagChangedState) return true;
                  return false;
                }, builder: (_, state) {
                  return ListView(
                    key: PageStorageKey<String>('PostsTagList'),
                    scrollDirection: Axis.horizontal,
                    children: BlocProvider.of<TimelineBloc>(_context)
                        .getSelectedTags()
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
              preferredSize: Size.fromHeight(35),
            ),
          ),
          SliverList(
            key: PageStorageKey<String>('AllPostsView'),
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                return PostArticle(
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
