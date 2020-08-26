import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class ViewAllEventsPage {
  
  BuildContext _context;
  final ScrollController _scrollController;

  void setContext(BuildContext context) => _context = context;

  ViewAllEventsPage(this._context,this._scrollController){
    _scrollController.appBar.height += 35;
  }

  Widget buildFAB() {
    if(BlocProvider.of<AppBloc>(_context).currentUser.adminLevel == 0) return null;
    return FloatingActionButton(
      child: Icon(MaterialCommunityIcons.newspaper_plus, size: 29,color: Colors.white,),
      onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToAddPostPageEvent()),
      tooltip: 'New Post',
    );
  }

  Snap buildBody() {
    return Snap(
      controller: _scrollController.appBar,
      child: BlocConsumer<TimelineBloc,TimelineState>(
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
          if (state is TimelineDisplayFilteredFeedState) return true;
          else if(state is TimelineNewPostUploadedState) return true;
          else if(state is TimelineLoadingFeedState) return true;
          else if(state is TimelineRebuildFeedState) return true;
          return false;
        },
        builder: (_,state){
          if(state is TimelineLoadingFeedState){
            return Center(child: CircularProgressIndicator(),);
          }
          else if(state is TimelineDisplayFilteredFeedState){
            return _buildListView(state.feedData);
          }
          return _buildListView(BlocProvider.of<TimelineBloc>(_context).feedData);
        },
      ),
    );
  }

  PreferredSize buildAppBar(){
    return PreferredSize(
      preferredSize: Size.fromHeight(_scrollController.appBar.height-24),
      child: ScrollAppBar(
        automaticallyImplyLeading: false,
        controller: _scrollController,
        centerTitle: true,
        title: Container(
         // color: Colors.blue,
          child: Row(
            children: [
              Hero(tag:'openningIcon',child: Icon(FontAwesome5Solid.church,color: Colors.white,)),
              SizedBox(width: 24,),
              Text('Posts'),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(35),
          child: Container(
            //color: Colors.red,
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
    );
  }

  Widget _buildListView(List<TimelinePost> feedData){
    return RefreshIndicator(
      onRefresh: ()async{
        await BlocProvider.of<TimelineBloc>(_context).processRefresh().then((_){
          BlocProvider.of<TimelineBloc>(_context).add(TimelineRefreshCompletedEvent());
        });
      },
      child: ListView.builder(
        key: PageStorageKey('viewAllPosts'),
        controller: _scrollController,
        itemCount: feedData.length,
        itemBuilder: (_,index){
          return PostArticle(
            mode: 'view',
            allUsers: BlocProvider.of<TimelineBloc>(_context).allUsers,
            timelinePost: feedData.elementAt(index),
            //post: feedData[tpsSorted.elementAt(index)],
          );
        }
      ),
    );
  }
  
}
