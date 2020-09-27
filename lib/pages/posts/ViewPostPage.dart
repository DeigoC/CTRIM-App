import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/updatesTabBody.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewPostPage extends StatefulWidget {
  final String postID;
  ViewPostPage(this.postID);
  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _nestedScrollController;
  Post _post;

  List<TimelinePost> _allTimelinePosts = [];
  Location _postLocation;
  PostBloc _postBloc;
  User _authorUser;
  bool _scrollAtBottom = false;

  double _expandedHeight;

  @override
  void initState() {
    _postBloc = PostBloc();
    _tabController = TabController(vsync: this, length: 4);
    _nestedScrollController = ScrollController()..addListener(() {
      if(_nestedScrollController.position.pixels == _nestedScrollController.position.maxScrollExtent){
        if(!_scrollAtBottom){
          setState(() {_scrollAtBottom = true;});
        }
      }else{
        if(_scrollAtBottom){
          setState(() {_scrollAtBottom = false;});
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() { 
    _tabController.dispose();
    _nestedScrollController.dispose();
    super.dispose();
    _postBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _postBloc,
      child: Scaffold(
        floatingActionButton: _post==null ? null:_buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: _buildBody()
      ),
    );
  }

  Widget _buildBody(){
    if(_post!=null) return _buildBodyWithData();
    return FutureBuilder<Post>(
      future: BlocProvider.of<TimelineBloc>(context).fetchPostByID(widget.postID),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = Center(child: CircularProgressIndicator(),);
          _getExpandedHeight().then((expandedHeight){
            setState(() {
              _expandedHeight = expandedHeight;
              _post = snap.data; 
            });
          });
        }else if(snap.hasError){
          result = Center(child: Text('Something went wrong!'),);
        }else{
          result = Center(child: CircularProgressIndicator(),);
        }
        return result;
      },
    );
  }

  Future<double> _getExpandedHeight()async{
    if(Platform.isIOS){
      IosDeviceInfo iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      if(iosDeviceInfo.model.toLowerCase().contains('ipad')){
        print('-------------------------WE ON THE IPAD!');
        return MediaQuery.of(context).size.height * 0.4;
      }
    }
    return MediaQuery.of(context).size.height * 0.33;
  }

  NestedScrollView _buildBodyWithData(){
    return NestedScrollView(
      controller: _nestedScrollController,
      headerSliverBuilder: (_, __) {
        bool hasImage = _post.firstImageSrc != null;
        return [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            actions: [
              BlocBuilder<AppBloc, AppState>(
                condition: (_, state) {
                  if (state is AppCurrentUserLikedPostState) return true;
                  return false;
                },
                builder: (_, state) {
                  bool liked = BlocProvider.of<AppBloc>(context).currentUser.likedPosts.contains(_post.id);
                  return IconButton(
                    tooltip: 'Save/unsave post',
                    icon: liked
                        ? Icon(Icons.favorite,color: Colors.red,)
                        : Icon(Icons.favorite_border),
                    onPressed: () => BlocProvider.of<AppBloc>(context)
                        .add(AppPostLikeClickedEvent(_post)),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage ? Image.network(_post.firstImageSrc, fit: BoxFit.cover,): null,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(_post.title,style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),),
                TabBar(
                  labelColor: BlocProvider.of<AppBloc>(context).onDarkTheme?null:Colors.black87,
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.info_outline),
                      text: 'About',
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_today),
                      text: 'Details',
                    ),
                    Tab(
                      icon: Icon(Icons.photo_library),
                      text: 'Gallery',
                    ),
                    Tab(
                      icon: Icon(Icons.track_changes),
                      text: 'Updates',
                    ),
                  ],
                ),
              ]),
            ),
          )
        ];
      },
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _newDetailTab(),
            GalleryTabBody.view(
              thumbnails: _post.thumbnails,
              gallerySrc: _post.gallerySources),
            _buildUpdatesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(){
    if(!_post.isDateNotApplicable && _post.startDate.isAfter(DateTime.now())){
      if(_scrollAtBottom) return null;
      return BlocBuilder(
        bloc: _postBloc,
        condition: (_,state){
          if(state is PostRemoveViewFABState||state is PostBuildViewFABState){
            return true;
          }
          return false;
        },
        builder: (_,state){
          if(state is PostRemoveViewFABState) return Container();
          return FloatingActionButton.extended(
            onPressed: (){
              _setReminderClick();
            }, 
            label: Text('Set Reminder',style: TextStyle(color: Colors.white),),
            icon: Icon(Icons.calendar_today,color: Colors.white,),
          );
        },
      );
    }
    return null;
  }

  void _setReminderClick(){
    String locationString = "Location's N/A";
    if(_postLocation != null) locationString = _postLocation.getAddressLine();
    else if(_post.locationID == '-1') locationString = "Location's Online";

    Event event = Event(
      title: _post.title,
      description: _post.description,
      location: locationString,
      startDate: _post.startDate,
      endDate: _post.endDate,
      allDay: _post.allDayEvent,
    );
    Add2Calendar.addEvent2Cal(event);
  }
  
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      child: ZefyrTheme(
        data: ZefyrThemeData(defaultLineTheme: LineTheme(textStyle: TextStyle(),padding: EdgeInsets.all(8))), 
        child:  ZefyrView(document: _post.getBodyDoc()),
      ),
    );  
  }

  Widget _buildLocationWidget(){
    if(_post.locationID.compareTo('0')==0){
      return Text('N/A',style: TextStyle(fontSize: 18),textAlign: TextAlign.center,);
    }else if(_post.locationID.compareTo('-1')==0){
      return Text('Online',style: TextStyle(fontSize: 18),textAlign: TextAlign.center,);
    }else if(_postLocation == null){
      BlocProvider.of<TimelineBloc>(context).fetchLocationByID(_post.locationID).then((location){
        setState(() { _postLocation = location;});
      });
      return Center(child: CircularProgressIndicator(),);
    }else{
      return MyFlatButton(
        fontSize: 18,
        label: _postLocation.getAddressLine(),
        onPressed: (){
          BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent(_postLocation));
        },
      );
    }
  }

  Widget _buildUpdatesTab(){
    if(_allTimelinePosts.length==0) {
      BlocProvider.of<TimelineBloc>(context).fetchPostUpdatesData(_post.id).then((timelines){
        setState(() {_allTimelinePosts = timelines;});
      });
      return Center(child: CircularProgressIndicator(),);
    }else if(_authorUser == null){
      BlocProvider.of<TimelineBloc>(context).fetchUserByID(_allTimelinePosts.first.authorID).then((user){
        setState(() {_authorUser = user;});
      });
      return Center(child: CircularProgressIndicator(),);
    }
    
    return PostUpdatesTab(
      post: _post,
      allTimelinePosts: _allTimelinePosts,
      user: _authorUser,
    );
  }
 
  Widget _newDetailTab(){
    List<Widget> slivers =[
       SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: 16,),
            Text('Location',style: TextStyle(fontSize: 24),textAlign: TextAlign.center,),
            _buildLocationWidget(),
            SizedBox(height: 16,),
            Text('Time',style: TextStyle(fontSize: 24),textAlign: TextAlign.center,),
            Text(_post.dateString,style: TextStyle(fontSize: 18),textAlign: TextAlign.center,),
            SizedBox(height: 32,),
          ]),
        )
    ];
    
    if (_post.detailTable.length != 0) {
      slivers.addAll([
        SliverList(
          delegate: SliverChildListDelegate([
            Text(_post.detailTableHeader,style: TextStyle(fontSize: 24),textAlign: TextAlign.center,),
          ]),
        ),
        SliverList(delegate: SliverChildBuilderDelegate(
          (_,index){
             return Container(
              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(_post.detailTable[index]['Leading']),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(_post.detailTable[index]['Trailing']),
                    flex: 2,
                  )
                ],
              ),
            );
          },
          childCount: _post.detailTable.length
        ))
      ]);
    }


    return CustomScrollView(
      slivers: slivers,
    );
  }

}
