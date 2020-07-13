import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class ViewUserPage extends StatefulWidget {
  final User user;
  ViewUserPage(this.user);
  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  
  Map<Post,TimelinePost> _userPosts = {};
  ZefyrController _zefyrController;
  FocusNode _focusNode;

  @override
  void initState() {
    _zefyrController = ZefyrController(widget.user.getBodyDocument());
    _focusNode = FocusNode();
    _userPosts = BlocProvider.of<TimelineBloc>(context).getUserPosts(widget.user.id);
    super.initState();
  }

  @override
  void dispose() { 
    _zefyrController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // TODO work on perfecting the appbar 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.all(0),
              title:  Container(
                color: Colors.white,
                width: double.infinity,
              height: 90,
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: -40,
                    child: Hero(
                      tag: '0/'+ widget.user.imgSrc,
                      child: Container(
                        height:100,
                        width: 100,
                        child: GestureDetector(onTap: ()=>BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(
                          {widget.user.imgSrc : ImageTag(src: widget.user.imgSrc, type: 'img')},0
                        )),),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: NetworkImage(widget.user.imgSrc),fit: BoxFit.cover )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.user.forename + '\n' + widget.user.surname, 
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  child: ZefyrScaffold(
                    child: ZefyrEditor(
                      controller: _zefyrController,
                      focusNode: _focusNode,
                      autofocus: false,
                      mode: ZefyrMode.view,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                ),
                Divider(),
              ]),
            ),
          ),
          SliverList(delegate: SliverChildBuilderDelegate((_,index){
            return PostArticle(
              allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
              mode: 'view',
              post: _userPosts.keys.elementAt(index),
              timelinePost: _userPosts.values.elementAt(index),
            );
          },
          childCount: _userPosts.length
          ),),
        ],
      ),
    );
  }
}