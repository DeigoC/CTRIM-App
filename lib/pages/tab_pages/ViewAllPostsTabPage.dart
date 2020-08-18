import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ViewAllEventsPage {
  
  BuildContext _context;
  final ScrollController _scrollController;
  double _startScrollPixels, _endScrollPixels;
  bool _tagListVisible = true, _animating = false;

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
    return RefreshIndicator(
      onRefresh: () async {
        await BlocProvider.of<TimelineBloc>(_context).reloadAllRecords().then((_){
          BlocProvider.of<TimelineBloc>(_context).add(TimelineFetchAllPostsEvent());
        });
      },
      child: NotificationListener(
        onNotification: (t){
          if(t is ScrollEndNotification){
            if(!_animating){

              _endScrollPixels = t.metrics.pixels;
              double difference = _startScrollPixels - _endScrollPixels,
              tagListSize = 40;

              if(difference < -40) _tagListVisible = false;
              else if(difference >=40 )_tagListVisible = true;

              // * To hide the tag list
              if(difference <= tagListSize-10 && !_tagListVisible && difference >0){
                double position = t.metrics.pixels + difference;
                _animateScroll(position);
              }

               /* print('---------diff is ' + difference.toString());
              if(difference < 0 && difference > -40){
                print('--------------ANIMATE TO Hide?');
                double position = t.metrics.pixels - difference;
                _animateScroll(position);
              } */
             

            }else _animating = false;


          }else if(t is ScrollStartNotification){
            _startScrollPixels = t.metrics.pixels;
          }
          return null;
        },
        child: CustomScrollView(
          controller: _scrollController,
          key: PageStorageKey<String>('ViewAllPostsTab'),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              snap: false,
              pinned: false,
              titleSpacing: 8,
              title: Row(
                children: [
                  Hero(tag:'openningIcon',child: Icon(FontAwesome5Solid.church,color: Colors.white,)),
                  SizedBox(width: 24,),
                  Text('Posts'),
                ],
              ),
              centerTitle: true,
              actions: [
                /* IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Search by title',
                  onPressed: ()=>BlocProvider.of<AppBloc>(_context).add(AppToSearchPostsPageEvent()),
                ) */
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(35),
                child: Container(
                  padding: EdgeInsets.only(bottom: 5),
                  height: 35,
                  child: BlocBuilder<TimelineBloc, TimelineState>(
                      condition: (_, state) {
                    if (state is TimelineTagChangedState) return true;
                    return false;
                  }, builder: (_, state) {
                    return ListView.builder(
                      key: PageStorageKey<String>('PostsTagList'),
                      scrollDirection: Axis.horizontal,
                      itemCount: BlocProvider.of<TimelineBloc>(_context).getSelectedTags().length,
                      itemBuilder:(_,index){
                        String tag = BlocProvider.of<TimelineBloc>(_context).getSelectedTags().keys.elementAt(index);
                        return Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: FilterChip(
                            label: Text(tag),
                            onSelected: (newState) =>
                                BlocProvider.of<TimelineBloc>(_context).add(TimelineTagClickedEvent(tag)),
                            selected: BlocProvider.of<TimelineBloc>(_context).getSelectedTags()[tag],
                          ),
                        );
                      } 
                    );
                  }),
                ),
              ),
            ),
            
            BlocConsumer<TimelineBloc,TimelineState>(
              listenWhen: (_,state){
                if(state is TimelineNewPostUploadedState) return true;
                else if(state is TimelineTagChangedState) return true;
                return false; 
              },
              listener: (_,state){
                if(state is TimelineNewPostUploadedState){
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, 
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }else if(state is TimelineTagChangedState){
                  //_scrollController.jumpTo(_scrollController.position.minScrollExtent);
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, 
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }
              },
              buildWhen: (_, state) {
                if (state is TimelineFeedState) return true;
                else if(state is TimelineNewPostUploadedState) return true;
                else if(state is TimelineLoadingFeedState) return true;
                else if(state is TimelineRebuildFeedState) return true;
                return false;
              },
              builder: (_,state){
                if(state is TimelineLoadingFeedState){
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),),
                    ]),
                  );
                }
                else if(state is TimelineFeedState){
                  return _buildFeedList(state.feedData);
                }
                return _buildFeedList(BlocProvider.of<TimelineBloc>(_context).feedData);
              },
            ),
            //_buildFeedList(feedData),
          ],
        ),
      ),
    );
  }

  SliverList _buildFeedList(List<TimelinePost> feedData){
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          return PostArticle(
            mode: 'view',
            allUsers: BlocProvider.of<TimelineBloc>(_context).allUsers,
            timelinePost: feedData.elementAt(index),
            //post: feedData[tpsSorted.elementAt(index)],
          );
        },
        childCount: feedData.length,
      ),
    );
  }

  void _animateScroll(double position){
    Future.delayed(Duration(microseconds: 10),(){
      _animating = true;
      _scrollController.animateTo(position, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    });
  }
}
