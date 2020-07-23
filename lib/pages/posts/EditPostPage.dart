import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/classes/other/updateDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/postsEditTabs/detailsTabBody.dart';
import 'package:ctrim_app_v1/widgets/postsEditTabs/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/postsEditTabs/mainTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostPage extends StatefulWidget {
  final Post _post;
  EditPostPage(this._post);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> with SingleTickerProviderStateMixin {
  PostBloc _postBloc;
  TabController _tabController;
  TextEditingController _tecTitle;

  @override
  void initState() {
    _postBloc = PostBloc.editMode(widget._post);
    _tabController = TabController(vsync: this, length: 4);
    _tecTitle = TextEditingController(text: widget._post.title);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tecTitle.dispose();
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ConfirmationDialogue.leaveEditPage(context: context);
      },
      child: BlocProvider(
        create: (_) => _postBloc,
        child: Scaffold(
          // ? Maybe this could be removed?
          resizeToAvoidBottomPadding: false,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              bool hasImage = _postBloc.newPost.firstImageSrc != null;
              Image postImage = hasImage ? Image.network(_postBloc.newPost.firstImageSrc, fit: BoxFit.cover,):null;
              if(!hasImage){
                hasImage = _postBloc.newPost.firstFileImage != null;
                postImage = hasImage ? Image.file(_postBloc.newPost.firstFileImage,fit: BoxFit.cover,):null;
              }
              
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(background: postImage,),
                  actions: [
                    _buildUpdateButton(),
                    _buildDeleteButton(context),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      MyTextField(
                        label: 'Title',
                        hint: 'e.g. Youth Day Out!',
                        controller: _tecTitle,
                        onTextChange: (newTitle) => _postBloc.add(PostTextChangeEvent(title: newTitle)),
                      ),
                      TabBar(
                        labelColor:BlocProvider.of<AppBloc>(context).onDarkTheme?null:Colors.black87,
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
                          _postBloc.add(PostTabClickEvent(newIndex));
                        },
                      )
                    ]),
                  ),
                )
              ];
            },
            body: BlocListener<TimelineBloc, TimelineState>(
              condition: (_,state){
                if(state is TimelineRebuildMyPostsPageState||
                state is TimelineAttemptingToUploadNewPostState) return true;
                return false;
              },
              listener: (_,state){
                if(state is TimelineRebuildMyPostsPageState){
                 Navigator.of(context).pop();
                 Navigator.of(context).pop();
                 Navigator.of(context).pop();
               }else if(state is TimelineAttemptingToUploadNewPostState){
                 ConfirmationDialogue.uploadTaskStarted(context: context);
               }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  MainTabBody(),
                  PostDetailsTabBody(),
                  GalleryTabBody.edit(
                    thumbnails: _postBloc.newPost.thumbnails,
                    gallerySrc: _postBloc.newPost.gallerySources,
                  ),
                  Center(child: Text('Updates'),)
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    if(widget._post.deleted) return Container();
    return MyRaisedButton(
      externalPadding: EdgeInsets.all(8),
      label: 'Delete',
      isDestructive: true,
      onPressed: () {
        ConfirmationDialogue.deleteRecord(context: context, record: 'Post').then((confirmation) {
          if(confirmation){
            BlocProvider.of<TimelineBloc>(context).add(
              TimelineDeletePostEvent(post: widget._post, uid: BlocProvider.of<AppBloc>(context).currentUser.id));
            Navigator.of(context).pop();
          }
        });
      },
    );
  }

  BlocBuilder _buildUpdateButton() {
    return BlocBuilder<PostBloc, PostState>(
      condition: (previousState, currentState) {
        if (currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_, state) {
        return MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Update',
          onPressed: (state is PostEnableSaveButtonState)? () { _confirmSave();}: null,
        );
      },
    );
  }
  
  void _confirmSave() async {
    await showDialog(
        context: context,
        builder: (_) {
          return UpdateLogDialogue(_postBloc);
        });
  }
}
