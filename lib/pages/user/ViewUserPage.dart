import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/socialLinks.dart';
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

  @override
  void initState() {
    _userPosts = BlocProvider.of<TimelineBloc>(context).getUserPosts(widget.user.id);
    super.initState();
  }

  @override
  void dispose() { 
    super.dispose();
  }

  // TODO work on perfecting the appbar 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.all(0),
              title:  Container(
                color: Colors.white,
                width: double.infinity,
              height: 54,
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: -50,
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
                  widget.user.forename + ' ' + widget.user.surname, 
                  style: TextStyle(color: Colors.black, fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                Text(widget.user.role, style: TextStyle(fontStyle: FontStyle.italic,fontSize: 18),textAlign: TextAlign.center,),
                SizedBox(height: 16,),
                Text(
                  'Social Links and Contacts', 
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8,),
                SocialLinksDisplay(widget.user.socialLinks),
                SizedBox(height: 8,),
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