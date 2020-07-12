import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/widgets/postsEditTabs/galleryTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewPostPage extends StatefulWidget {
  final Post _post;
  ViewPostPage(this._post);
  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          bool hasImage = widget._post.getFirstImageSrc() != null;
          return [
            SliverAppBar(
              expandedHeight: 200,
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
                background: hasImage
                    ? Image.network(
                        widget._post.getFirstImageSrc(),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(widget._post.title),
                  TabBar(
                    labelColor: Colors.black,
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
                    onTap: (newIndex) {
                      setState(() {
                        _selectedTabIndex = newIndex;
                      });
                    },
                  ),
                ]),
              ),
            )
          ];
        },
        body: _buildTabBody(_selectedTabIndex),
      ),
    );
  }

  Widget _buildTabBody(int selectedIndex) {
    return OrientationBuilder(
      builder: (_, orientation) {
        if (_selectedTabIndex == 0)
          return _buildAboutTab();
        else if (_selectedTabIndex == 1)
          return _buildDetailsTab();
        else if (_selectedTabIndex == 2)
          return GalleryTabBody.view(
              orientation: orientation,
              gallerySrc: widget._post.gallerySources);
        return _buildUpdatesTab();
      },
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: ZefyrView(
            document: widget._post.getBodyDoc(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Tags'),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Wrap(
            spacing: 4,
            children: widget._post.selectedTagsString.map((tag) {
              return Chip(
                label: Text(tag),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    List<Widget> children = [
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

  Widget _buildUpdatesTab() {
    List<TimelinePost> allUpdates = BlocProvider.of<TimelineBloc>(context).getAllUpdatePosts(widget._post.id);
    Map<DateTime, List<TimelinePost>> updatesSortedToLists = {};
    allUpdates.forEach((u) {
      DateTime thisDate = DateTime(u.postDate.year, u.postDate.month, u.postDate.day);
      if(updatesSortedToLists[thisDate] == null){
        updatesSortedToLists[thisDate] = [];
      }
      updatesSortedToLists[thisDate].add(u);
    });

    List<DateTime> sortedDates = updatesSortedToLists.keys.toList();
    sortedDates.sort((a,b) => b.compareTo(a));
    User user = BlocProvider.of<TimelineBloc>(context).allUsers.firstWhere(
      (author) => author.id == allUpdates.last.authorID);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: user.buildAvatar(),
          title: Text(user.forename + ' ' + user.surname[0] + '.'),
          subtitle: Text('Author'),
          onTap: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewUserPageEvent(user)),
          trailing: Container(
            padding: EdgeInsets.all(8),
            child: Text('CONTACT'),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(16),
            ),
          )
        ),
        Divider(),
        Expanded(child: ListView.separated(
          itemCount: sortedDates.length,
          separatorBuilder: (_,index)=>Divider(),
          itemBuilder: (_,index){
            List<TimelinePost> updates = updatesSortedToLists[sortedDates[index]];
            updates.sort((a,b) => b.postDate.compareTo(a.postDate));
            
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(updates.first.getPostDateString(), textAlign: TextAlign.center,),
                    flex: 1,
                  ),
                  Expanded(
                    child: _mapUpdatesLogsToWidgets(updates),
                    flex: 2,
                  )
                ],
              ),
            );
          }
        ),)
      ],
    );
  }

  Column _mapUpdatesLogsToWidgets(List<TimelinePost> updates){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: updates.map((u){
        List<Widget> children = [
          Text(u.getUpdateTime()),
          Text(u.getUpdateString()),
          Divider(),
        ];
        if(updates.indexOf(u) == updates.length - 1){
          children.removeLast();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }).toList(),
    );
  }
}
