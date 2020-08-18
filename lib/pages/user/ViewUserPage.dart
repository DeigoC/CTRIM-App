import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/style.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/socialLinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

class ViewUserPage extends StatefulWidget {
  final User user;
  ViewUserPage(this.user);
  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() { 
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    bool hasImage = widget.user.imgSrc != '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.all(0),
              title:  Container(
                color: BlocProvider.of<AppBloc>(context).onDarkTheme ? DarkSurfaceColor : Colors.white,
                width: double.infinity,
              height: 52,
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
                        child: GestureDetector(
                          child: hasImage ? Container(height: 100,width: 100,color: Colors.transparent,) :
                          widget.user.buildAvatar(context),
                          onTap: (){
                            if(hasImage){
                              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(
                              {widget.user.imgSrc : ImageTag(src: widget.user.imgSrc, type: 'img')},0
                              ));
                            }
                      }),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: hasImage? DecorationImage(
                            image: NetworkImageWithRetry(widget.user.imgSrc),fit: BoxFit.cover ):null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          SliverPadding(
            padding: EdgeInsets.zero,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.user.forename + ' ' + widget.user.surname, 
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                Text(widget.user.role, style: TextStyle(fontStyle: FontStyle.italic,fontSize: 18),textAlign: TextAlign.center,),
                SizedBox(height: 32,),
                Text(
                  'Social Links and Contacts', 
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8,),
                SocialLinksDisplay(widget.user.socialLinks),
                SizedBox(height: 8,),
                Divider(),
              ]),
            ),
          ),
          _buildNewListBody(),
          //_buildPostsList(context),
        ],
      ),
    );
  }

  Widget _buildNewListBody(){
    return FutureBuilder<Map<TimelinePost, Post>>(
      future: null,//BlocProvider.of<TimelineBloc>(context).fetchAllUserPosts(widget.user.id),
      builder: (_,snap){
        SliverChildDelegate result;

        if(snap.hasData){
          result = _buildBodyWithData(snap.data);
        }else if(snap.hasError){
          result = SliverChildListDelegate([
            Center(child: Text('Something went wrong!'),),
          ]);

        }else{
          result = SliverChildListDelegate([
            Center(child: CircularProgressIndicator(),),
          ]);
        }

        return SliverList(delegate: result,);
      },
    );
  }

  SliverChildDelegate _buildBodyWithData(Map<TimelinePost, Post> data){
    data.removeWhere((key, value) => value.deleted);
    if(data.length==0){
      return SliverChildListDelegate([
        Center(child: Text('No Posts made yet!'),),
      ]);
    }
    
    return SliverChildBuilderDelegate(
      (_,index){
        return PostArticle(
          allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
          mode: 'view',
          timelinePost: data.keys.elementAt(index),
          //post: data[data.keys.elementAt(index)],
        );
      },
      childCount: data.length
    );
    

    /* return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_,index){
        return PostArticle(
          allUsers: BlocProvider.of<TimelineBloc>(context).allUsers,
          mode: 'view',
          timelinePost: data.keys.elementAt(index),
          post: data[data.keys.elementAt(index)],
        );
      }
    ); */
  }

}