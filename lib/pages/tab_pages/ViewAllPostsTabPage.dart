import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAllEventsPage{

  BuildContext _context;
  void setContext(BuildContext context) => _context = context;

  List<TimelinePost> _timelines;
  ViewAllEventsPage(this._context);

  Widget buildAppBar(){
    return null;
  }

  FloatingActionButton buildFAB(){
    return FloatingActionButton.extended(
      onPressed: (){
        BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent());
      },
      icon: Icon(Icons.add),
       label: Text('Event'),
      );
  }

  Widget buildBody(){
    Future.delayed(Duration(seconds: 2),(){
      BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
    });

    return BlocBuilder<TimelineBloc, TimelineState>(
      condition: (_,state){
        if(state is TimelineDisplayFeedState) return true;
        return false;
      },
      builder:(_,state){
        if(state is TimelineDisplayFeedState){
          return _buildBodyWithData(state);
        }
        return Center(child: CircularProgressIndicator(),);
      } 
    );
  }

  Widget _buildBodyWithData(TimelineDisplayFeedState state){
    _timelines = state.timelines;
    List<Widget> children = _timelines.map((timelinePost) => PostArticle(
          allPosts: state.posts,
          allUsers: state.users,
          timelinePost: timelinePost,
        )).toList();
    
    return CustomScrollView(
      key: PageStorageKey<String>('ViewAllPostsTab'),
      slivers: [
        SliverAppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search by title',
                onPressed: (){

                },
              )
            ],
            floating: true,
            bottom: PreferredSize(
              child: Container(
                color: Colors.black,
                height: 35,
                child: BlocBuilder<TimelineBloc, TimelineState>(
                  condition: (_,state){
                    if(state is TimelineTagChangedState) return true;
                    return false;
                  },
                  builder:(_,state){
                    return ListView(
                      key: PageStorageKey<String>('PostsTagList'),
                      scrollDirection: Axis.horizontal,
                       children: BlocProvider.of<TimelineBloc>(_context).getSelectedTags().keys.map((tag){
                          return Padding(
                            padding: EdgeInsets.only(left:8.0),
                            child: FilterChip(
                              label: Text(tag), 
                              onSelected: (newState) => BlocProvider.of<TimelineBloc>(_context).add(TimelineTagClickedEvent(tag)),
                              selected: BlocProvider.of<TimelineBloc>(_context).getSelectedTags()[tag],
                            ),
                          );
                        }).toList(),
                    );
                  } 
                ),
              ), 
              preferredSize: Size.fromHeight(35),
            ),
        ),
      
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_,index){
              return children[index];
            },
            childCount: children.length,
          ),
        ),
      ],
    );
  }
}