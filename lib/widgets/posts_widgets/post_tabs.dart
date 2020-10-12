import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/galleryItem.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/helpDialogTile.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/viewUserSheet.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/post_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:zefyr/zefyr.dart';

class AboutTabBody extends StatefulWidget {
  AboutTabBody();
  @override
  _AboutTabBodyState createState() => _AboutTabBodyState();
}

class _AboutTabBodyState extends State<AboutTabBody> {
  TextEditingController _tecBody, _tecSubtitle;

  @override
  void initState() {
    super.initState();
    _tecBody = TextEditingController();
    _tecSubtitle = TextEditingController(
        text: BlocProvider.of<PostBloc>(context).postDescription);
  }

  @override
  void dispose() {
    _tecBody.dispose();
    _tecSubtitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PostTagsField(),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        MyTextField(
          controller: _tecSubtitle,
          label: 'Description',
          hint: 'A summary of the post',
          helpText: "The opening paragraph(s). It can be a short summary or an introductory section."
          + "\n\n• NOTE: this is used for the calendar reminder feature.",
          maxLength: 140,
          maxLines: 5,
          onTextChange: (newSubtitle) => BlocProvider.of<PostBloc>(context)
              .add(PostTextChangeEvent(description: newSubtitle)),
        ),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body*',style: TextStyle(fontSize: 18),),
              IconButton(
                icon: Icon(AntDesign.questioncircleo),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (_){
                      return HelpDialogTile(
                        title: 'Body (Required)',
                        subtitle:"The meat and potatoes of the post." 
                        + " Write the core information and don't forget to style it.",
                      );
                    }
                  );
                },
              )
            ],
          ),
        ),
        Divider(thickness: 1, indent: 10, endIndent: 10,),
        BlocBuilder<PostBloc, PostState>(
            condition: (previousState, currentState) {
          if (currentState is PostUpdateBodyState) return true;
          return false;
        }, builder: (_, state) {
          return Container(
              padding: EdgeInsets.all(8),
              child: ZefyrView(document: BlocProvider.of<PostBloc>(context).getEditorDoc())
            );
        }),
        Container(
          padding: EdgeInsets.all(8),
          child: RaisedButton(
            onPressed: () {
              BlocProvider.of<AppBloc>(context).add(AppToPostBodyEditorEvent(BlocProvider.of<PostBloc>(context)));
            },
            child: Text('Edit Body'),
          ),
        ),
      ],
    );
  }
}

class PostDetailsTabBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PostLocationField(),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        PostDateTimeField(),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        DetailTable(),
      ],
    );
  }
}

// ignore: must_be_immutable
class GalleryTabBody extends StatelessWidget {
  Orientation _orientation;
  final Map<String, String> gallerySrc;
  final Map<String, String> thumbnails;

  static double pictureSize, paddingSize;
  static String _mode = 'addingPost';
  static BuildContext _context;

  GalleryTabBody({this.gallerySrc, this.thumbnails}) {
    _mode = 'addingPost';
  }

  GalleryTabBody.view({@required this.gallerySrc, @required this.thumbnails}) {
    _mode = 'viewingPost';
  }

  GalleryTabBody.edit({
    @required this.gallerySrc,
    @required this.thumbnails,
  }) {
    _mode = 'editingPost';
  }

  @override
  Widget build(BuildContext context) {
    _orientation = MediaQuery.of(context).orientation;
    
    _context = context;
    _setupSizes();
    if (_mode == 'viewingPost')
      return _buildGalleryViewPost();
    else if (_mode == 'editingPost') return _buildGalleryEditPost();
    return _buildGalleryAddPost();
  }

  void _setupSizes() {
    pictureSize = MediaQuery.of(_context).size.width *
        0.32; // * 3 accross so 4% width left 0.04/4 = 0.01
    paddingSize = MediaQuery.of(_context).size.width * 0.01;
    if (_orientation == Orientation.landscape) {
      // * 4 blocks accross so 5 paddings accross
      pictureSize = MediaQuery.of(_context).size.width * 0.2375;
      paddingSize = MediaQuery.of(_context).size.width * 0.01;
    }
  }

  Widget _buildGalleryAddPost() {
    return ListView(
      children: [
        MyRaisedButton(
          label:'ADD/EDIT',
          externalPadding: EdgeInsets.symmetric(horizontal: 8),
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToCreateAlbumEvent(
            BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox(height: 20,),
        Wrap(
          children: BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
            String type = BlocProvider.of<PostBloc>(_context).files[file];
            return type == 'vid'? GalleryItem.file(type: 'vid', filePath: file,thumbnails: thumbnails,)
                : GalleryItem.file(type: 'img', filePath: file,thumbnails: thumbnails,);
          }).toList(),
        )
      ],
    );
  }

  Widget _buildGalleryEditPost() {
    Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    List<String> srcs = gallerySrc.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));

    List<Widget> wrapChildren =srcs.map((src) {
      String type = BlocProvider.of<PostBloc>(_context).gallerySrc[src];
        return type == 'vid'? GalleryItem(
          thumbnails: thumbnails,
          type: 'vid',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap: ()=>null,
        ): GalleryItem(
          thumbnails: thumbnails,
          type: 'img',
          src: src,
          heroTag: galleryTags[src].heroTag,
          onTap:()=>null,
        );
    }).toList();

    wrapChildren.addAll(BlocProvider.of<PostBloc>(_context).files.keys.map((file) {
      String type = BlocProvider.of<PostBloc>(_context).files[file];
     

      return type == 'vid'? 
      GalleryItem.file(type: 'vid', 
      filePath: file,
      thumbnails: thumbnails,
      )
      : GalleryItem.file(type: 'img', filePath: file,thumbnails: thumbnails,);
    }).toList());

    return ListView(
      children: [
        MyRaisedButton(
          label: 'Add/Edit Album',
          externalPadding: EdgeInsets.symmetric(horizontal: 8),
          onPressed: () => BlocProvider.of<AppBloc>(_context).add(AppToEditAlbumEvent(BlocProvider.of<PostBloc>(_context))),
        ),
        SizedBox( height: 20,),
        Wrap(children: wrapChildren)
      ],
    );
  }

  Widget _buildGalleryViewPost() {
    if (gallerySrc.length == 0) return Center(child: Text('No Images or Videos'),);
   
   Map<String, ImageTag> galleryTags = _createGalleryTags(gallerySrc);
    List<String> srcs = gallerySrc.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              children: srcs.map((src) {
                String type = gallerySrc[src];
                int index = srcs.indexOf(src);

                return type == 'vid'? GalleryItem(
                  thumbnails: thumbnails,
                  type: 'vid',
                  src: src,
                  heroTag: galleryTags[src].heroTag,
                  onTap: ()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
                )
                : GalleryItem(
                  thumbnails: thumbnails,
                  type: 'img',
                  src: src,
                  heroTag: galleryTags[src].heroTag,
                  onTap:()=>BlocProvider.of<AppBloc>(_context).add(AppToViewImageVideoPageEvent(galleryTags, index)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, ImageTag> _createGalleryTags(Map<String, String> gallery) {
    Map<String, ImageTag> result = {};
    List<String> srcs = gallery.keys.toList();
    srcs.sort((a,b) => a.compareTo(b));
    srcs.forEach((src) {
      String type = gallery[src];
      result[src] = ImageTag(src: src, type: type);
    });
    return result;
  }
}

class PostUpdatesTab extends StatelessWidget {
  
  final Post post;
  final List<TimelinePost> allTimelinePosts;
  final User user;
  
  PostUpdatesTab({
    this.post, 
    this.allTimelinePosts,
    this.user,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            ListTile(
              leading: Hero(child: user.buildAvatar(context),tag:'no more',),
              title: Text(user.forename + ' ' + user.surname[0] + '.'),
              subtitle: Text('Author'),
              onTap: (){
                var controller = showBottomSheet(
                  context: context, 
                  backgroundColor: Colors.transparent,
                  builder: (_){
                    return ViewUserSheet(user);
                });
                BlocProvider.of<PostBloc>(context).add(PostRemoveViewFABEvent());
                controller.closed.then((_) => BlocProvider.of<PostBloc>(context).add(PostBuildViewFABEvent()));
              },
              trailing: Icon(Icons.info),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(top:8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('DATE', textAlign: TextAlign.center,),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text('TIME / UPDATE LOG',textAlign: TextAlign.center,),
                    flex: 2,
                  )
                ],
              ),
            ),
          ]),
        ),
        _buildUpdatesList(),
      ],
    );
  }

  SliverList _buildUpdatesList(){
    Map<DateTime, List<TimelinePost>> updatesSortedToLists = {};
    allTimelinePosts.forEach((u) {
      DateTime thisDate = DateTime(u.postDate.year, u.postDate.month, u.postDate.day);
      if(updatesSortedToLists[thisDate] == null){
        updatesSortedToLists[thisDate] = [];
      }
      updatesSortedToLists[thisDate].add(u);
    });

    List<DateTime> sortedDates = updatesSortedToLists.keys.toList();
    sortedDates.sort((a,b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_,index){
          List<TimelinePost> updates = updatesSortedToLists[sortedDates[index]];
          updates.sort((a,b) => b.postDate.compareTo(a.postDate));
          
          return Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                index == 0 ? SizedBox(height: 16,):Divider(),
                Row(
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
              ],
            ),
          );
        },
        childCount: sortedDates.length),
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
