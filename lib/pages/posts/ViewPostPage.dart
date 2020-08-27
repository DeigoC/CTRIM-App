import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/notificationHandler.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/other/adminCheck.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/updatesTabBody.dart';
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
  ZefyrController _zefyrController;
  FocusNode _fn;
  Post _post;

  List<TimelinePost> _allTimelinePosts = [];
  PostBloc _postBloc;

  @override
  void initState() {
    _postBloc = PostBloc();

    _tabController = TabController(vsync: this, length: 4);
    _fn = FocusNode();
    super.initState();
  }

  @override
  void dispose() { 
    if(_zefyrController != null) _zefyrController.dispose();
    _tabController.dispose();
    _fn.dispose();
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
    if(_post!=null){
      return  _buildBodyWithData();
    }
    return FutureBuilder<Post>(
      future: BlocProvider.of<TimelineBloc>(context).fetchPostByID(widget.postID),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = Center(child: CircularProgressIndicator(),);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() { 
              _post = snap.data; 
              _zefyrController = ZefyrController(_post.getBodyDoc())..addListener(() {
                NotusStyle style =  _zefyrController.getSelectionStyle();
                if(style.contains(NotusAttribute.link)){
                  AppBloc.openURL(style.values.first.value, context);
                }
              });
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

  NestedScrollView _buildBodyWithData(){
    return NestedScrollView(
      headerSliverBuilder: (_, __) {
        bool hasImage = _post.firstImageSrc != null;
        return [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.33,
            actions: [
              AdminCheck().isCurrentUserAboveLvl2(context) ? 
              IconButton(
                tooltip: 'Send Notification',
                icon: Icon(Icons.notifications_active),
                onPressed: (){
                  ConfirmationDialogue().sendNotification(context: context).then((value){
                    if(value){
                      Scaffold.of(_).showSnackBar(SnackBar(
                        content: Text('Notification Sent!'),
                      ));
                      NotificationHandler(context).notifyUsersAboutPost(_post);
                    }
                  });
                },
              ): Container(),
              
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
            //_buildDetailsTab(),
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
              Event event = Event(
                title: _post.title,
                description: _post.description,
                location: BlocProvider.of<TimelineBloc>(context).selectableLocations
                .firstWhere((element) => element.id == _post.locationID)
                .getAddressLine(),
                startDate: _post.startDate,
                endDate: _post.endDate,
                allDay: _post.allDayEvent,
              );
              Add2Calendar.addEvent2Cal(event);
            }, 
            label: Text('Set Reminder',style: TextStyle(color: Colors.white),),
            icon: Icon(Icons.calendar_today,color: Colors.white,),
          );
        },
      );


      /* return FloatingActionButton.extended(
        onPressed: (){
          Event event = Event(
            title: _post.title,
            description: _post.description,
            location: BlocProvider.of<TimelineBloc>(context).selectableLocations
            .firstWhere((element) => element.id == _post.locationID)
            .getAddressLine(),
            startDate: _post.startDate,
            endDate: _post.endDate,
            allDay: _post.allDayEvent,
          );
          Add2Calendar.addEvent2Cal(event);
        }, 
        label: Text('Set Reminder',style: TextStyle(color: Colors.white),),
        icon: Icon(Icons.calendar_today,color: Colors.white,),
      ); */
    }
    return null;
  }
  
  Widget _buildAboutTab() {
    ZefyrEditableText(
      controller: _zefyrController,
      focusNode: _fn,
      autofocus: false,
      imageDelegate: null,
    );

    return ZefyrTheme(
      data: ZefyrThemeData(defaultLineTheme: LineTheme(textStyle: TextStyle(),padding: EdgeInsets.all(8))), 
      child: ZefyrScaffold(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: ZefyrView(document: _zefyrController.document),
        )
      ),
    );  
  }

  Widget _buildLocationWidget(){
    Location l = BlocProvider.of<TimelineBloc>(context).allLocations
    .firstWhere((element) => element.id == _post.locationID);
      
    if(l.id.compareTo('0')==0) return Text('N/A',style: TextStyle(fontSize: 18),textAlign: TextAlign.center,);
    return MyFlatButton(
      fontSize: 18,
      label: l.getAddressLine(),
      onPressed: (){
        BlocProvider.of<AppBloc>(context).add(AppToViewLocationOnMapEvent(l));
      },
    );
  }

  Widget _buildUpdatesTab(){
    if(_allTimelinePosts.length==0){
      BlocProvider.of<TimelineBloc>(context).fetchPostUpdatesData(_post.id).then((timelines){
        setState(() {_allTimelinePosts = timelines;});
      });
      return Center(child: CircularProgressIndicator(),);
    }
    return PostUpdatesTab(_post, _allTimelinePosts);
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
