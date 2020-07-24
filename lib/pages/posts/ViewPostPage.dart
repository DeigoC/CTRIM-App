import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/updatesTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewPostPage extends StatefulWidget {
  final Post _post;
  ViewPostPage(this._post);
  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  ZefyrController _zefyrController;
  FocusNode _fn;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 4);
    _zefyrController = ZefyrController(widget._post.getBodyDoc())..addListener(() {
      NotusStyle style =  _zefyrController.getSelectionStyle();
      if(style.contains(NotusAttribute.link)){
        AppBloc.openURL(style.values.first.value, context);
      }
    });
    _fn = FocusNode();
    super.initState();
  }

  @override
  void dispose() { 
    _zefyrController.dispose();
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFAB(),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          bool hasImage = widget._post.firstImageSrc != null;
          return [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.30,
              actions: [
                BlocBuilder<AppBloc, AppState>(
                  condition: (_, state) {
                    if (state is AppCurrentUserLikedPostState) return true;
                    return false;
                  },
                  builder: (_, state) {
                    bool liked = BlocProvider.of<AppBloc>(context).currentUser.likedPosts.contains(widget._post.id);
                    return IconButton(
                      tooltip: 'Save/unsave post',
                      icon: liked
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(Icons.favorite_border),
                      onPressed: () => BlocProvider.of<AppBloc>(context)
                          .add(AppPostLikeClickedEvent(widget._post)),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: hasImage ? Image.network(widget._post.firstImageSrc, fit: BoxFit.cover,): null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(widget._post.title),
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _buildDetailsTab(),
            GalleryTabBody.view(
              thumbnails: widget._post.thumbnails,
              gallerySrc: widget._post.gallerySources),
            PostUpdatesTab(widget._post),
          ],
          //child: _buildTabBody(_selectedTabIndex)
        ),
      ),
    );
  }

  Widget _buildFAB(){
    if(!widget._post.isDateNotApplicable && widget._post.startDate.isAfter(DateTime.now())){
      return FloatingActionButton.extended(
        onPressed: (){
          Event event = Event(
            title: widget._post.title,
            description: widget._post.description,
            location: BlocProvider.of<TimelineBloc>(context).selectableLocations
            .firstWhere((element) => element.id == widget._post.locationID)
            .getAddressLine(),
            startDate: widget._post.startDate,
            endDate: widget._post.endDate,
            allDay: widget._post.allDayEvent,
          );
          Add2Calendar.addEvent2Cal(event);
        }, 
        label: Text('Set Calender Reminder',style: TextStyle(color: Colors.white),),
        icon: Icon(Icons.calendar_today,color: Colors.white,),
      );
    }
    return null;
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
           padding: EdgeInsets.only(left: 8),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Tags:'),
               Wrap(
                spacing: 4,
                children: widget._post.selectedTagsString.map((tag) {
                  return MyFilterChip(
                    label: tag,
                    selected: false,
                    onSelected: (_)=>null,
                  );
                }).toList(),
              ),
             ],
           ),
         ),
         Divider(),
         Expanded(
            child: ZefyrTheme(
             data: ZefyrThemeData(defaultLineTheme: LineTheme(textStyle: TextStyle(),padding: EdgeInsets.all(8))), 
             child: ZefyrScaffold(
               child: ZefyrEditor(
                 focusNode: _fn,
                 autofocus: false,
                 mode: ZefyrMode.select,
                 controller: _zefyrController,
               ),
             ),
           ),
         ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    List<Widget> children = [
      SizedBox(height: 16,),
      Text('Location'),
      Text(BlocProvider.of<TimelineBloc>(context).allLocations
          .firstWhere((element) => element.id == widget._post.locationID)
          .getAddressLine()),
      SizedBox(height: 8,),
      Text('Time'),
      Text(widget._post.dateString),
    ];
    if (widget._post.detailTable.length != 0) {
      children.addAll(_buildDetailListItems());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  List<Widget> _buildDetailListItems() {
    return [
      SizedBox(height: 24,),
      Text(widget._post.detailTableHeader),
      SizedBox(height: 8,),
      Expanded(
        child: ListView.builder(
          itemCount: widget._post.detailTable.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (_, index) {
            return Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide())),
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget._post.detailTable[index]['Leading']),
                    flex: 1,
                  ),
                  Text(' | '),
                  Expanded(
                    child: Text(widget._post.detailTable[index]['Trailing']),
                    flex: 2,
                  )
                ],
              ),
            );
          },
        ),
      ),
    ];
  }
 
}
