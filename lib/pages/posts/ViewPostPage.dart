import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/widgets/posts/galleryTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewPostPage extends StatefulWidget{
  
  final Post _post;
  ViewPostPage(this._post);
  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> with SingleTickerProviderStateMixin{
  
  TabController _tabController;
  int _selectedTabIndex =0;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_,__){
          bool hasImage = widget._post.gallerySources.keys.toList().length != 0;
          return[
            SliverAppBar(
              expandedHeight: 200,
              actions: [
                BlocBuilder<AppBloc, AppState>(
                  condition: (_,state){
                    if(state is AppCurrentUserLikedPostState) return true;
                    return false;
                  },
                  builder: (_,state){
                    bool liked = BlocProvider.of<AppBloc>(context).currentUser.likedPosts.contains(widget._post.id);
                    return IconButton(
                      tooltip: 'Save/unsave post',
                      icon: liked ? Icon(Icons.favorite, color: Colors.red,):Icon(Icons.favorite_border),
                      onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppPostLikeClicked(widget._post)),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: hasImage ? Image.network(widget._post.gallerySources.keys.toList()[0], fit: BoxFit.cover,)
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
                      Tab(icon: Icon(Icons.info_outline), text: 'About',),
                      Tab(icon: Icon(Icons.calendar_today), text: 'Details',),
                      Tab(icon: Icon(Icons.photo_library), text: 'Gallery',),
                      Tab(icon: Icon(Icons.track_changes), text: 'Updates',),
                    ],
                    onTap: (newIndex){
                      setState(() {
                        _selectedTabIndex = newIndex;
                      });
                    },
                  ),
                ]),),
            )
          ];
        },
        body: _buildTabBody(_selectedTabIndex),
      ),
    );
  }

  Widget _buildTabBody(int selectedIndex){
    return OrientationBuilder(
      builder: (_,orientation){
        if(_selectedTabIndex == 0) return _buildAboutTab();
        else if(_selectedTabIndex == 1) return _buildDetailsTab();
        else if(_selectedTabIndex == 2) return GalleryTabBody.view(orientation: orientation, gallerySrc: widget._post.gallerySources);
        return _buildUpdatesTab();
      },
    );
  }

  Widget _buildAboutTab(){
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
            children: widget._post.selectedTagsString.map((tag){
            return Chip(
              label: Text(tag),
            );
          }).toList()
          ,),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(){
    List<Widget> children =[
      Text('Location'),
      Text(BlocProvider.of<TimelineBloc>(context).locations.firstWhere((element) => element.id == widget._post.locationID).addressLine),
      SizedBox(height: 8,),
      Text('Time'),
      Text(widget._post.dateString),
    ];
    if(widget._post.detailTable.length != 0){
      children.addAll(_buildDetailListItems());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  List<Widget> _buildDetailListItems(){
    return[
       SizedBox(height: 24,),
      Text(widget._post.detailTableHeader),
       SizedBox(height: 8,),
      Expanded(
        child: ListView.builder(
          itemCount: widget._post.detailTable.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (_,index){
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide()
                )
              ),
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget._post.detailTable[index][0]),
                    flex: 1,
                  ),
                  Text(' | '),
                  Expanded(
                    child: Text(widget._post.detailTable[index][1]),
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

  Widget _buildUpdatesTab(){
    return Center(child: Text('Updates Tab'),);
  }

}